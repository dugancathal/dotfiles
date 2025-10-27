def pretty_print_table(headers, data)
  # 1. Determine maximum width for each column
  num_columns = headers.length
  
  # Initialize max widths with header lengths
  col_widths = headers.map(&:length) 

  data.each do |row|
    row.each_with_index do |cell, i|
      cell_s = cell.to_s
      # Update max width if current cell is wider
      col_widths[i] = [col_widths[i], cell_s.length].max
    end
  end
  
  # Add padding (e.g., 2 spaces on each side)
  padded_widths = col_widths.map { |w| w + 4 } 
  
  # Helper for creating a separator line
  separator = "+" + padded_widths.map { |w| "-" * w }.join("+") + "+"
  
  # 2. Print Header and Separator
  puts separator
  header_line = "|"
  headers.each_with_index do |header, i|
    # Center-align headers
    header_line += " #{header.center(col_widths[i])} |" 
  end
  puts header_line
  puts separator
  
  # 3. Print Data Rows
  data.each do |row|
    data_line = "|"
    row.each_with_index do |cell, i|
      cell_s = cell.to_s
      # Left-align data cells
      data_line += " #{cell_s.ljust(col_widths[i])} |" 
    end
    puts data_line
  end
  
  # 4. Print Footer Separator
  puts separator
end

