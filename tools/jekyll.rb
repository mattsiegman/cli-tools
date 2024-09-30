##
# common jekyll tools that I wrote. There's probably a better way to do this, but, meh...
module JekyllTools

  ########################
  # constants & defaults #
  DEFAULT_YAML = {
      "layout"     => "wp-post",
      "status"     => "publish",
      "author"     => {
          "display_name" => "Fr. Matt",
          "login" => "mattsiegman",
      },
      "categories" => [],
      "tags"       => [],
  }

  # from jekyll
  YAML_FRONT_MATTER_REGEXP = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m.freeze

  ##################
  # module imports #
  require 'safe_yaml/load'
  #require 'kramdown'
  require 'date'
  require 'pathname'
  require 'htmlentities'

  ######
  # figure out which jekyll directory we're in and then return the 
  # jekyll base directory based on that
  def get_directory_info
      current_path = Pathname.pwd

      base_path, current_dir = current_path.split

      jekyll_dir = current_path
      destination_dir = current_path

      if current_path.join("_posts").directory?
          # in the jekyll directory
          destination_dir = current_path + "_posts"
      elsif base_path.join("_posts").directory?
          # in a subdirectory of jekyll
          jekyll_dir = base_path
          destination_dir = base_path + "_posts"
      # should probably handle the "else" case, but *shrug*
      end

      {
          jekyll: jekyll_dir,
          current: current_path,
          destination: destination_dir,
      }
  end


  # returns a hash (or whatever ruby calls it) of data front "filename"
  # "data" contains the front matter, loaded in via SafeYAML
  # "content" contains the raw content, unparsed by markdown or html
  # "filename" contains the filename
  def get_file_data(filename) 
      file_data = {
          name: filename,
          content: "",
          data: {},
      }

      file_data[:content] = File.read(filename)

      # stole this from jekyll -- how they extract the Front Matter
      if file_data[:content] =~ YAML_FRONT_MATTER_REGEXP
          file_data[:content] = Regexp.last_match.post_match
          file_data[:data] = SafeYAML.load(Regexp.last_match(1))
      end

      # clean ^M from windows files
      file_data[:content].delete!("\cM")

      file_data[:data] ||= {}
      
      file_data
  end

  def print_preview(doc)
      preview = ""

  #    if doc[:name] =~ /\.(md|html)$/
  #        preview = Kramdown::Document.new(doc[:content]).to_latex
  #    else
          preview = doc[:content][0..240]
  #    end

      puts "This is a quick preview of your file:"
      puts preview
  end

  def fill_front_matter(doc, default)
      new_front_matter = default.dup

      doc[:data].keys.each do |k|
          new_front_matter[k] = doc[:data][k]
      end

      new_front_matter['title'] = get_var_from_input("title", new_front_matter, true)
      new_front_matter["categories"] = get_array_from_input("categories", new_front_matter)
      new_front_matter["tags"] = get_array_from_input("tags", new_front_matter)
      new_front_matter['author']['display_name'] = get_var_from_input("display_name", new_front_matter['author'])
      new_front_matter['author']['login'] = get_var_from_input("login", new_front_matter['author'])

      working_date = nil

      until working_date
          working_date = new_front_matter["date"]

          if !working_date and doc[:name] =~ /(?<date>\d{4}-\d{2}-\d{2})/
              working_date = Regexp.last_match(:date).strip
          end
          
          working_date = get_var_from_input("date", {"date" => working_date})
          
          begin
              new_front_matter["date"] = Date.parse(working_date)
          rescue ArgumentError
              working_date = nil
              new_front_matter["date"] = nil
              puts "Invalid date format."
          end
      end

      new_front_matter
  end

  def generate_filename(doc)
      date_string = doc[:data]["date"].strftime('%Y-%m-%d')
      title_string = doc[:data]["title"].gsub(/[^\w\-]+/, '-')
      extension = "md"
      if doc[:name] =~ /\.(?<ext>\w+)$/
          extension = Regexp.last_match(:ext)
      end

      "#{date_string}-#{title_string}.#{extension}".downcase
  end

  def trim_date_line(doc)
      content = doc[:content]
      if content =~ /^(?<front_lines>\W*#{Regexp.quote(doc[:data]["date"].strftime('%Y-%m-%d'))})\s+/m
          print "Remove front lines [#{Regexp.last_match(:front_lines)}] (y/[n])? "
          answer = STDIN.gets.chomp
          if answer == "y" or answer == "yes"
              content = Regexp.last_match.post_match
          end
      end

      content
  end

end
