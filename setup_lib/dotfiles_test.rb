require "minitest/autorun"
require_relative "./dotfiles"

class TestClatter < Minitest::Test
  def test_clatter_getter_setter
    klass = Class.new do
      extend ClassConf
      clatter :attr_a
    end

    assert_nil klass.attr_a

    klass.attr_a = "foo"

    assert_equal "foo", klass.attr_a
  end

  def test_clatter_default
    klass = Class.new do
      extend ClassConf
      clatter :attr_a, default: 'foo'
    end

    assert_equal "foo", klass.attr_a
  end

  def test_clatter_with_attr
    klass = Class.new do
      extend ClassConf
      clatter :attr_a, default: 'foo'
    end

    was_executed = false
    klass.with_attr_a("bar") do
      was_executed = true
      assert_equal "bar", klass.attr_a
    end

    assert was_executed
  end

  def test_clatter_with_attr_restores_after_block
    klass = Class.new do
      extend ClassConf
      clatter :attr_a, default: 'foo'
    end

    klass.with_attr_a("bar") { }

    assert_equal "foo", klass.attr_a
  end

  def test_clatter_with_attr_restores_after_exception
    klass = Class.new do
      extend ClassConf
      clatter :attr_a, default: 'foo'
    end

    assert_raises(RuntimeError) { klass.with_attr_a("bar") { raise "boom" } }
    assert_equal "foo", klass.attr_a
  end
end

class TestDotfilesOsName < Minitest::Test
  def test_os_name_linux
    assert_equal "linux", Dotfiles.os_name("linux-gnu")
  end

  def test_os_name_mac
    assert_equal "mac", Dotfiles.os_name("darwin23.0.0")
  end

  def test_os_name_unsupported_raises
    assert_raises(RuntimeError) { Dotfiles.os_name("windows-msvc") }
  end
end

module WithTempProject
  module_function
  def children_of(dir) = dir.children.map(&:basename).map(&:to_s)

  def with_tmp_proj(*paths, **dirs)
    Dir.mktmpdir do |dest_dir|
      Dir.mktmpdir do |src_dir|
        src = Pathname(src_dir)

        Array(paths).flatten.each { src.join(_1).write(src) }
        dirs.each do |dir, children|
          nested = src.join(dir.to_s)
          nested.mkdir

          Array(children).each do |child|
            nested.join(child).write(src)
          end
        end

        yield(src, Pathname(dest_dir))
      end
    end
  end
end

class TestDotfilesMerge < Minitest::Test
  include WithTempProject

  def test_merge_install_copies_dotfiles
    with_tmp_proj(%w[zshrc zshenv]) do |src, dest|
      Dotfiles::MergeInstallation.new.call(to: dest, from: src)

      assert_includes children_of(dest), ".zshrc"
      assert_includes children_of(dest), ".zshenv"
    end
  end

  def test_merge_install_creates_symlinks_for_new_files
    with_tmp_proj(%w[zshrc]) do |src, dest|
      Dotfiles::MergeInstallation.new.call(to: dest, from: src)

      assert dest.join(".zshrc").symlink?, "expected .zshrc to be a symlink"
    end
  end

  def test_merge_install_does_not_overwrite_existing_file_with_symlink
    with_tmp_proj(%w[zshrc]) do |src, dest|
      dest.join(".zshrc").write("existing content\n")
      Dotfiles::MergeInstallation.new.call(to: dest, from: src)

      refute dest.join(".zshrc").symlink?, "expected .zshrc to remain a regular file"
    end
  end

  def test_merge_install_appends_when_file_exists
    with_tmp_proj(%w[zshrc]) do |src, dest|
      src.join("zshrc").write("# ===dotfiles===\n\nnew\ncontent\n")
      dest.join(".zshrc").write("already exists\nwith\nsome\ncontent\n")

      Dotfiles::MergeInstallation.new.call(to: dest, from: src)

      assert_includes children_of(dest), ".zshrc"
      assert_equal dest.join(".zshrc").read, <<~TXT
        already exists
        with
        some
        content
        # ===dotfiles===

        new
        content
      TXT
    end
  end

  def test_merge_install_ignores_pre_merged_files
    with_tmp_proj(%w[zshrc]) do |src, dest|
      src.join("zshrc").write("# ===dotfiles===\n\nnew\ncontent\n")
      dest.join(".zshrc").write("already exists\n")

      Dotfiles::MergeInstallation.new.call(to: dest, from: src)
      Dotfiles::MergeInstallation.new.call(to: dest, from: src)

      assert_equal dest.join(".zshrc").read, <<~TXT
        already exists
        # ===dotfiles===

        new
        content
      TXT
    end
  end

  def test_merge_install_ignores_regardless_of_comment_style
    with_tmp_proj(%w[nvimrc.lua]) do |src, dest|
      src.join("nvimrc.lua").write("-- ===dotfiles===\n\nnew\ncontent\n")
      dest.join(".nvimrc.lua").write("already exists\n")

      Dotfiles::MergeInstallation.new.call(to: dest, from: src)
      Dotfiles::MergeInstallation.new.call(to: dest, from: src)

      assert_equal dest.join(".nvimrc.lua").read, <<~TXT
        already exists
        -- ===dotfiles===

        new
        content
      TXT
    end
  end

  def test_merge_install_ignores_specified_files
    with_tmp_proj(%w[zshrc Gemfile LICENSE]) do |src, dest|
      Dotfiles::MergeInstallation.new.call(
        to: dest,
        from: src,
        ignore: %w[Gemfile LICENSE]
      )

      refute_includes children_of(dest), ".Gemfile"
      refute_includes children_of(dest), ".LICENSE"
    end
  end

  def test_merge_install_links_directories
    with_tmp_proj(zsh: %w[aliases]) do |src, dest|
      Dotfiles::MergeInstallation.new.call(to: dest, from: src)

      assert_includes children_of(dest), ".zsh"
      assert_includes children_of(dest.join(".zsh")), "aliases"
    end
  end

  def test_merge_install_links_directory_children_when_parent_exists
    with_tmp_proj(zsh: %w[aliases]) do |src, dest|
      dest.join(".zsh").mkdir
      Dotfiles::MergeInstallation.new.call(to: dest, from: src)

      assert_includes children_of(dest), ".zsh"
      assert_includes children_of(dest.join(".zsh")), "aliases"
    end
  end
end

class TestDotfilesDirectInstall < Minitest::Test
  include WithTempProject

  def test_direct_install_symlinks_new_files
    with_tmp_proj(%w[zshrc zshenv]) do |src, dest|
      Dotfiles::DirectInstallation.new.call(to: dest, from: src)

      assert dest.join(".zshrc").symlink?
      assert dest.join(".zshenv").symlink?
    end
  end

  def test_direct_install_overwrites_existing_file_with_symlink
    with_tmp_proj(%w[zshrc]) do |src, dest|
      dest.join(".zshrc").write("old content\n")
      Dotfiles::DirectInstallation.new.call(to: dest, from: src)

      assert dest.join(".zshrc").symlink?, "expected existing file to be replaced by symlink"
    end
  end

  def test_direct_install_backs_up_existing_file_before_overwrite
    with_tmp_proj(%w[zshrc]) do |src, dest|
      dest.join(".zshrc").write("old content\n")
      Dotfiles::DirectInstallation.new.call(to: dest, from: src)

      assert dest.join(".zshrc.bak").exist?, "expected a .bak backup of the original file"
      assert_equal "old content\n", dest.join(".zshrc.bak").read
    end
  end

  def test_direct_install_overwrites_existing_symlink
    with_tmp_proj(%w[zshrc zshenv]) do |src, dest|
      # first install creates symlinks
      Dotfiles::DirectInstallation.new.call(to: dest, from: src)
      # second install should not raise and symlinks should still point at src
      Dotfiles::DirectInstallation.new.call(to: dest, from: src)

      assert dest.join(".zshrc").symlink?
      assert_equal src.join("zshrc").realpath, dest.join(".zshrc").realpath
    end
  end

  def test_direct_install_does_not_back_up_existing_symlinks
    with_tmp_proj(%w[zshrc]) do |src, dest|
      # first install — no backup expected since there was nothing there
      Dotfiles::DirectInstallation.new.call(to: dest, from: src)
      # second install — still no backup; it was already a symlink, not a real file
      Dotfiles::DirectInstallation.new.call(to: dest, from: src)

      refute dest.join(".zshrc.bak").exist?, "expected no backup when overwriting a symlink"
    end
  end

  def test_direct_install_ignores_specified_files
    with_tmp_proj(%w[zshrc Gemfile LICENSE]) do |src, dest|
      Dotfiles::DirectInstallation.new.call(
        to: dest,
        from: src,
        ignore: %w[Gemfile LICENSE]
      )

      refute_includes children_of(dest), ".Gemfile"
      refute_includes children_of(dest), ".LICENSE"
    end
  end

  def test_direct_install_symlinks_directories
    with_tmp_proj(zsh: %w[aliases]) do |src, dest|
      Dotfiles::DirectInstallation.new.call(to: dest, from: src)

      assert_includes children_of(dest), ".zsh"
      assert dest.join(".zsh").symlink?, "expected directory to be symlinked directly"
    end
  end

  def test_direct_install_recurses_when_parent_directory_exists
    with_tmp_proj(zsh: %w[aliases]) do |src, dest|
      dest.join(".zsh").mkdir
      Dotfiles::DirectInstallation.new.call(to: dest, from: src)

      assert_includes children_of(dest.join(".zsh")), "aliases"
    end
  end
end

