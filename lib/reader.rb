# frozen_string_literal: true
# use `+` to unfreeze

require_relative "reader/version"

module Reader
	class Error < StandardError
		class BadInitialization < Error; end
		class NoEnt < Error; end
		class WrongArgumentType < Error; end
	end  

	#________________________________________
	# - Methods - 
	class Definition # holds various information about a path
		
		attr_reader	:path, :full_name, :directory, :extension, :type

		def initialize (path)
			raise Reader::Error::BadInitialization.new("Definition class initialized with wrong type of argument [#{path.class}]. ") if path.class != String
			raise Reader::Error::BadInitialization.new("Definition class initialized with empty string.") if path.empty?

			@path = path.strip

			@name     			= File.basename(@path)
			@full_name			= File.expand_path(@path)
			@extension      = File.extname(@path)
			@directory     	= File.dirname(@path)
			@absolute_path	= File.absolute_path(@path)
			@type						= File.exist?(@path) ? File.ftype(@path) : "not found"
			@is_absolute		= File.absolute_path?(@path)	

			@saved_dir			= Dir.pwd

			@divider = "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
			@border = ("__" * 40)
		end	

		def _border
			puts @border
		end

		def show_header
			[
				"#{" " * 34} Verifying",																												# centers title
				"#{@path.length < 80 ? "#{" " * ((80 - @path.length)/2)}#{@path}" : @path}",		# centers path title unless path is > 80
				@divider, 
				"  Working Directory is: #{_handle_spacing(@saved_dir, 56, 52)} ",		# shows the last 52 characters if greater than 56
				"  Expanded `path` is: 	#{ _handle_spacing(@full_name, 56, 52) } ",
			].each { |e| puts e }
		end

		def show_general_info
			[ #header and general info
				"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -General Information", 
				"  Base Name: 		\"#{ _handle_spacing(@name, 56, 51) }\"",
				"  Directory Name: 	\"#{ _handle_spacing(@directory, 56, 51) }\"",  
				"  Extension Name: 	\"#{ _handle_spacing(@extension, 56, 51) }\"", 
				"  Status: 		#{@type.upcase}", 
				"  Searching for:   	(#{@is_absolute ? "Absolute" : "Relative"})",
				"  #{@absolute_path}"
			].each { |e| puts e }	
		end

		def _handle_spacing (object, max, scope)
			scope = -scope if scope > 0
			"#{ object.length > max ? "...#{object[scope..]}" : object}"
		end

		def show_directory_info
			Dir.chdir(@full_name) {
				puts "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -Directory Information"
				puts "  Children:"
				Dir.children(Dir.pwd).sort.each_with_index { |c, i| if File.owned?(c) then puts "    #{i}.	#{c}" else puts "    #{i}.	-NOT OWNED-" end } 
			}
		end

		def show_file_info
			# puts File.dirname(expanded)
			Dir.chdir(@directory) {
				[
					"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - File Information",
					"  Owned by current user?:  	#{File.owned?(@name)}",
					"  Readable?:       		#{File.readable?(@name)}",
					"  Writable?:       		#{File.writable?(@name)}",
					"  Executable?:       		#{File.executable?(@name)}",
					"  Size (bytes):    		#{File.size?(@name)}",
				].each { |e| puts e }
			}
		end

		def _warning
			[
				"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ",
				"* WARNING: `~` will not be expanded in some File or Dir class methods.   	*",
				"*      	   Use `File.expand_path(PATH)` to expand this path manually.	    	*",
			].each { |e| puts e }
		end

		def show_info
			_border
			show_header
			show_general_info
			show_directory_info if File.directory?(@full_name)
			show_file_info if @type == "file"
			_warning if path.start_with?("~")
			_border
		end
	end #end class PathFinder
	
		class Page # the actual text files
		# example call: 
		# iroha = Reader::Page.new("../test_file.txt")
		attr_reader   :original, :path, :extension, :name, :write_protection, :size, :full_name
		attr_accessor :text

		def self.attributes()
			[:original, :path, :extension, :name, :write_protection, :path, :size, :text, :full_name]
		end

		def initialize (path) 
			# Note: This object assumes a relative path from the current working directory
			#    - This will be sorted out in Chapter class
			path.strip!
			@name 					= File.basename(path, ".*")
			@full_name      = File.basename(path) 
			@path  					= File.expand_path(path)
			@directory      = File.dirname(path)
			@extension      = File.extname(path)

			@comment_char = "//"
			@join_char 		= "" 		# the character used to join the text together if it was broken up
			@auto_set 		= true 	# automatically reformats text after any of the split methods are called

			@original 				= File.readlines(@path)	# always reads from the full path
			@size							= File.size?(@path) || 0
			@text 						= @original.dup
			@write_protection = true  # protects the real file from being overwritten
		end

		def _convert_size (size)
			return "#{(size * 8).to_i} bits" if size < 1.125
			return "#{(size /= 1000000000000000.0).round(2)} pb" if size >= 1000000000000000
			return "#{(size /= 1000000000000.0).round(2)} tb" if size >= 1000000000000
			return "#{(size /= 1000000000.0).round(2)} gb" if size >= 1000000000
			return "#{(size /= 1000000.0).round(2)} mb" if size >= 1000000
			return "#{(size /= 1000.0).round(2)} kb" if size >= 1000
			"#{size.round(2)} bytes"
		end

		#________________________________________
		# - Informantion - 
		def info (small = false)
			# Note: NAME  SIZE   DIR  EDITED?
			#   - format this further in Chapter (including which entity calls `puts`)
			# 	- `small` is to accomodate list indexing (see Chapter.list)
			name_len 	= 17
			size_len 	= 9
			dir_len 	= small ? 30 : 38
			dir_off		= small ? -25 : 33

			base_str 	= "| #{ @full_name.length > name_len ? "...#{@full_name[-13..]}" : @full_name }"
			size_str 	= _convert_size(@size)
			dir_str 	= "#{ @directory.length > dir_len ? "...#{@directory[-25..]}" : @directory}"

			base_str + (" " * (name_len - base_str.length)) + 
			" | " + 
			size_str + (if size_str.length < size_len then (" " * (9 - size_str.length)) else "" end) +
			" | " +
			dir_str + (" " * (dir_len - dir_str.length)) + 
			" | " +
			"#{self.edited?}	|" 
		end

		def edited? 
			@text != @original
		end
		#________________________________________
		# - I/O - 
		def write (path: @path, force_overwrite: false)
			#  Brief: This method writes to the current path, or one provided as an arguement.
			#         Appends `.rdr` if write_protection is enabled.
			@text = @text.lines if @text.is_a? String

			path = "#{path}.reader" if !force_overwrite || !@write_protection
			File.write(path, @text.join(@join_char))
		end
		#________________________________________
		# - Editing - 
		def reset
			@text = @original
		end

		def change_protection (val = !@write_protection)
			#  Brief: This method toggles write_protection be default. Can be set manually.
			@write_protection = val
		end

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
	end #end class Page

	
	class Chapter # contains Page objects; default class

		attr_reader  :name, :path, :extensions, :pages

		def initialize (chapter_name, path, *extension)      
			@name = chapter_name
			@path = File.expand_path(path)
			@extensions = extension; @extension = @extensions;
			@pages = [] #the actual objects

			Dir.each_child(@path) { |c| add(c) if @extensions.any? { |e| File.extname(c) == e || (File.file?(c) && e == ".*")} } 
			
		end

		def add (filename)
			if filename.class == String
				addition = "#{@path}/#{filename}"
				return "** Error in chapter `#{@name}#add(#{filename})`: Invalid filename **" if !File.exist?(addition)
				@pages << Reader::Page.new(addition)
				@extensions << File.extname(addition) if !@extensions.include?(File.extname(addition))
			elsif filename.class == Reader::Page
				@pages << filename
				@extensions << filename.extension
			else
				raise Reader::Error::WrongArgumentType.new("#{@name}.add() - Invalid parameter type. [#{filename.class}]")
			end
		end

		def remove (page)
			@pages.reject! { |f| f.name == page}
		end

		def method_missing (m, *args, &block)
			res = (@pages.detect { |file| file.name.downcase == "#{m}" }) 
			raise Reader::Error::NoEnt.new("Error: no #{m} Page in #{@name} Chapter") if res.nil?
			res
		end

		def info 
			# Note: NAME  SIZE   DIR  EDITED?
			#   - format this further in Chapter (including which entity calls `puts`)
			name_len 	= 17
			size_len 	= 9
			dir_len 	= 38

			name_str 	= " #{ @name.length > name_len ? "...#{@name[-13..]}" : @name }"
			size_str 	= @pages.length.to_s
			dir_str 	= "#{ @path.length > dir_len ? "...#{@path[-35..]}" : @path}"

			name_str + (" " * (name_len - name_str.length)) + 
			" | " + 
			size_str + (if size_str.length < size_len then (" " * (9 - size_str.length)) else "" end) +
			" | " +
			dir_str #+ (" " * (dir_len - dir_str.length)) <- commented out for now
		end

		def show_full_directory
			Dir.children(@path).each_with_index { |e, i|
					puts "#{i}.	#{e}"
				}
		end

		def show_list
			@pages.each_with_index { |e, i|
					puts "#{i}.	#{e.info(true)}"
				}
		end

		def file (filename)
			@pages.detect { |file| file.full_name == "#{filename}" }
		end

		def __show(attribute = :name)
			# Note: THIS METHOD DOES NOT WORK
			# 	- The double underscore is to hopefully prevent accidental uses and will be removed if I can ever get this to work.
			#		- I cannot figure out why calling e.attribute throws an error. 
			
			raise Reader::Error::WrongArgumentType.new("Error in #{@name}.show(#{attribute}): invlaid attribute type [#{attribute.class}].") if attribute.class != String
			attribute = attribute.to_sym
			raise Reader::Error::WrongArgumentType.new("Error in #{@name}.show(#{attribute}): invlaid attribute.") if !Reader::Page.attributes.include?(attribute)

			@pages.each_with_index { |e, i|
					"#{i}.	#{e.attribute}"
				}
		end
		
	end #end class Chapter

	
	class Album # contains Chapter object; is available for convenience but is not necessary

		attr_reader  :name

		def initialize (name, *chapters) 
			raise Reader::Error::BadInitialization.new("Album initialized with invalid parameter. [#{chapters.find { |c| c.class != Reader::Chapter}.class }]") if chapters.any? { |f| f.class != Reader::Chapter}

			@exts = []
			@name = name
			@chapters = []

			chapters.each { |e|
					@chapters << e
				}
		end

		def add (chapter)
			raise Reader::Error::WrongArgumentType.new("#{@name}.add() - Invalid parameter type. [#{chapter.class}]") if chapter.class != Reader::Chapter
			@chapters << chapter
		end

		def chapters
			puts "Chapters in #{@name} Album"
			@chapters.each_with_index { |e, i|
					puts "#{i}.	#{e.name}"
				}
		end

		def remove (chapter)
			@chapters.reject! { |f| f.name == chapter}
		end

		def method_missing (m, *args, &block)
			res = (@chapters.detect { |file| file.name.downcase == "#{m}" }) 
			raise Reader::Error::NoEnt.new("Error: no #{m} Chapter in #{@name} Binder") if res.nil?
			res
		end

	end #end class Album

end