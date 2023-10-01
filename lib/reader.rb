# frozen_string_literal: true

require_relative "reader/version"

module Reader
  class Error < StandardError; end  

  class InDir # scans a directory and makes OutText files
    
    attr_reader :path, :ext, :raw_list, :files

    def initialize (path, ext, chdir  = false)
      @path = path
      @extension = ext
      @raw_list = Hash.new
      @files = Array.new

      @change_directory = chdir
      # Note: If you want to set an Absolute Path to read from, you must set @change_directory to TRUE
      
      _adjust_directory
      _make_raw_list
      _create_OTFs
      _restore_directory
    end

    def _adjust_directory
      @original_directory = Dir.pwd
      @temp_directory = @path
      Dir.chdir if @change_directory
      @temp_directory = Dir.pwd
    end

    def _restore_directory 
      Dir.chdir(@original_directory) if @change_directory
    end

    def _wildcard (file)
      @extension == "*" && !File.directory?("#{@path}/#{file}")
    end

    def _make_raw_list
      ind = 0
      Dir.entries(@path).each { |e|
          if e.include?(".#{@extension}") || _wildcard(e)
            @raw_list[ind] = e 
            ind += 1
          end
        }
    end

    def _create_OTFs
      @raw_list.each_value  { |v|
        @files << OutText.new("#{path}/#{v}", @extension)
      }
    end

    #_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
    # * User Methods * 
    def list (show_ID = false)
      show = ["List of .#{@extension} files in #{@change_directory ? "#{@temp_directory}/#{@path}" : @path}"]

      @raw_list.each { |k, v|
          show << "#{k}.#{" #{files[k] if show_ID} #{v}"}"
        }

      show << ""
      show
    end

    def file (file_name)
      @files[@raw_list.key(file_name)]
    end
  
  end #end class InDir
  
  

  class OutText # reads a file and creates an output text
    
    attr_accessor :comment_char, :join_char, :text, :auto_set
    attr_reader   :original
  
    def initialize (path, ext = "otf")
      @path         = path
      @extension    = ext
      @extension = "" if ext == "*"
      @original     = File.open(@path).readlines
      @text         = @original
      @comment_char = "//"
      @join_char    = ""
      @auto_set     = true #this will automatically change the join_char if certain methods are used
      _read
    end

    def write (path = "#{@path}.#{@extension}")
      File.write(path, @text.join(join_char))
    end

    def reset
      @text = @original
    end
    #_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
    # * Configurations * 

    def remove_comments(type = @comment_char)
      @text.reject! { |s| s.include?(type) }
    end

    def remove_newlines
      @text.reject! { |s| s == "\n" }
    end
    
    def split_words
      #  Brief: This method devides the text using spaces
      @text.map! { |e| e.split(' ') }
      @text.flatten!
      @join_char = "\n" if @auto_set
    end

    def split_punct
      #  Brief: This method divides into words and separates punctuation
      @text.map! { |e| e.scan(/[\w'-]+|[[:punct:]]/) }
      @join_char = "\n" if @auto_set
    end

    def split_char
      #  Brief: This method devides text into characters
      @text.map! { |e| e.split('') }
      @text.flatten!
      @join_char = "\n" if @auto_set
    end
  end #end class OutText
end

