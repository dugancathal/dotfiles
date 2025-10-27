require "minitest/autorun"
require_relative "./dotfiles"

class TestDotfiles < Minitest::Test
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
end

class TestDotfilesMerge < Minitest::Test
  def test_merge_install_copies_dotfiles
    with_tmp_proj(%w[zshrc zshenv]) do |src, dest|
      Dotfiles::MergeInstallation.new.call(to: dest, from: src)

      assert_includes children_of(dest), ".zshrc"
      assert_includes children_of(dest), ".zshenv"
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

  private

  def source_path = Pathname(File.expand_path("..", __dir__))

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

