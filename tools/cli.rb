##
# stuff for CLI that I wrote. There's probably a better way to do this, but, meh...
module CLITools

  ########################
  # constants & defaults #

  ##################
  # module imports #
  require 'safe_yaml/load'
  #require 'kramdown'
  require 'date'
  require 'pathname'
  require 'htmlentities'

  ######
  # subs
  def get_cli_draft_paths(directory_info)
      files = ARGV

      if files.length < 1
          fail "filename(s) required as argument"
      end

      output = []
      errors = []
      files.each do |file|
          file_path = Pathname.new(file)
          unless file_path.exist? and file_path.file?
              errors << "File must exist: #{file_path.to_s}"
              next
          end

          pn = directory_info[:current] + file_path
          dir, basename = pn.split
          if dir.to_s =~ /^#{Regexp.quote(directory_info[:destination].to_s)}/
              errors << "#{file_path.to_s} is already posted."
              next
          end

          output << file_path
      end

      if errors.length > 0
          puts errors.join("\n")
          fail "Cannot continue..."
      end

      output
  end

  def make_nice_name(name)
      name.gsub(/[^A-Za-z0-9]/, ' ')
  end

  # probably should rework this so it doesn't say "for post" in it
  def get_var_from_input(item_name, current, required = false)
      rval = nil
      nice_name = make_nice_name(item_name).capitalize

      until rval
          unless current[item_name] and current[item_name] != ""
              print "#{nice_name} for post: "
          else
              print "#{nice_name} for post [#{current[item_name]}]:"
          end

          input = STDIN.gets.strip
          rval = current[item_name].to_s
          if input != ""
              rval = input
          end

          if required and (rval == "" or not rval)
              rval = nil
              puts "#{nice_name} is required."
          end
      end

      rval
  end

  # probably should rework this so it doesn't say "Post" in it
  def get_array_from_input(item_name, current)
      items = []
      items_cleaned = []

      unless current[item_name].length > 0
          puts "Post #{item_name}, seperated by ';': "
          items = STDIN.gets.chomp.split(/;/)
      else
          puts "Post #{item_name}, seperated by ';' [#{current[item_name]}]: "
          items = STDIN.gets.chomp.split(/;/)
          unless items.length > 0
              items_cleaned = current[item_name]
          end
      end

      html_encoder = HTMLEntities.new
      items.each do |item|
          item.strip!
          next if item == ""
          items_cleaned.push(html_encoder.encode(item))
      end

      items_cleaned
  end

end
