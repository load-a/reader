# frozen_string_literal: true
# use `+` to unfreeze

require_relative "reader/version"

module Reader
	class Error < StandardError

		class BadInitialization < Error; end
	end  

	#________________________________________
	# - Methods - 
	class Verifier # holds various information about a path
		
		attr_reader	:path, :full_name, :pwd, :base_name, :dir_name, :extension, :type

		def initialize (path)
			raise Reader::Error::BadInitialization.new("PathFinder class initialized with wrong type of argument [#{path.class}]. ") if path.class != String
			raise Reader::Error::BadInitialization.new("PathFinder class initialized with empty string.") if path.empty?

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

		def self.pwd
			Dir.pwd
		end

		def border
			puts @border
		end

		def header
			[
				"#{" " * 34} Verifying",																												# centers title
				"#{@path.length < 80 ? "#{" " * ((80 - @path.length)/2)}#{@path}" : @path}",		# centers path title unless path is > 80
				@divider, 
				"  Working Directory is: #{_handle_spacing(@saved_dir, 56, 52)} ",		# shows the last 52 characters if greater than 56
				"  Expanded `path` is: 	#{ _handle_spacing(@full_name, 56, 52) } ",
			].each { |e| puts e }
		end

		def general_info
			[ #header and general info
				"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -General Information", 
				"  Base Name: 		\"#{ _handle_spacing(@name, 56, 51) }\"",
				"  Directory Name: 	\"#{ _handle_spacing(@directory, 56, 51) }\"",  
				"  Extension Name: 	\"#{ _handle_spacing(@extension, 56, 51) }\"", 
				"  Status: 		#{@type.upcase}", 
				"  Searching for:   	(#{@is_absolute ? "Absolute" : "Relative"})",
				"  #{@absolute_path}"
			].each { |e| puts e }
	1	end

		def _handle_spacing (object, max, scope)
			scope = -scope if scope > 0
			"#{ object.length > max ? "...#{object[scope..]}" : object}"
		end

		def directory_info
			Dir.chdir(@full_name) {
				puts "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -Directory Information"
				puts "  Children:"
				Dir.children(Dir.pwd).sort.each_with_index { |c, i| if File.owned?(c) then puts "    #{i}.	#{c}" else puts "    #{i}.	-NOT OWNED-" end } 
			}
		end

		def file_info
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

		def warning
			[
				"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ",
				"* WARNING: `~` will not be expanded in some File or Dir class methods.   	*",
				"*      	   Use `File.expand_path(PATH)` to expand this path manually.	    	*",
			].each { |e| puts e }
		end

		def show_info
			border
			header
			general_info
			directory_info if File.directory?(@full_name)
			file_info if @type == "file"
			warning if path.start_with?("~")
			border
		end


	end #end class PathFinder
	
	

	def self.verify_path (path)
		# Brief: This method takes a path (string) as input and prints diagnostic information about it
		#         Use this to get insight as to what the computer sees when your path is sent through 
		#         various File and Dir methods
		# Note: Absolute paths start with `/` and this method handles them
		path.strip!
		return puts "** ERROR in method `verify_path`: No path to verify.			**" if path == ""
		return puts "** ERROR in method `verify_path`: wrong argument type. [#{path.class} != String] **" if path.class != String
		#_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
		# * Initial Variables [don't use during chdir] * 
		expanded      = File.expand_path(path)
		pwd           = Dir.pwd
		base_name     = File.basename(path)
		dir_name      = File.dirname(path)
		ext           = File.extname(path)
		is_dir        = File.directory?(path)
		is_file       = File.file?(path)
		#_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
		# * Printing and Logic * 
		puts ("__" * 40)
		[ #header and general info
			"#{" " * 34} Verifying",                                                                  # centers title
			"#{path.length < 80 ? "#{" " * ((80 - path.length)/2)}#{path}" : path}",                  # centers path title unless path is > 80
			"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ", 
			"  Working Directory is: #{ pwd.length > 56 ? "...#{pwd[-52..]}" : pwd} ",                # shows the last 52 characters if greater than 56
			"  Expanded `path` is: 	#{ expanded.length > 56 ? "...#{expanded[-52..]}" : expanded} ",
			"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -General Information", 
			"  Base Name: 		\"#{ base_name.length > 56 ? "...#{base_name[-51..]}" : base_name}\"",
			"  Directory Name: 	\"#{ dir_name.length > 56 ? "...#{dir_name[-51..]}" : dir_name}\"",  
			"  Extension Name: 	\"#{ext}\"", 
			"  Status: 		#{if is_dir then "DIRECTORY" elsif is_file then "FILE" else "NOT FOUND" end}", 
			"  Searching for:   	(#{File.absolute_path?(path) ? "Absolute" : "Relative"})",
			"  #{File.absolute_path(path)}"
		].each { |e| puts e }

		# If path is directory, list relevant info
		if File.directory?(expanded)
			Dir.chdir(expanded) {
				puts "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -Directory Information"
				puts "  Children:"
				Dir.children(Dir.pwd).sort.each_with_index { |c, i| if File.owned?(c) then puts "    #{i}.	#{c}" else puts "    #{i}.	-NOT OWNED-" end } 
				}
			end

		# If path is file list relevant info
		if File.file?(expanded)
			# puts File.dirname(expanded)
			Dir.chdir(File.dirname(expanded)) {
				[
					"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - File Information",
					"  Owned by current user?:  	#{File.owned?(base_name)}",
					"  Readable?:       		#{File.readable?(base_name)}",
					"  Writable?:       		#{File.writable?(base_name)}",
					"  Executable?:       		#{File.executable?(base_name)}",
					"  Size (bytes):    		#{File.size?(base_name)}",
				].each { |e| puts e }
			}
		end


		if path.start_with?("~")
			[
				"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ",
				"* WARNING: `~` will not be expanded in some File or Dir class methods.   	*",
				"*      	   Use `File.expand_path(PATH)` to expand this path manually.	    	*",
			].each { |e| puts e }
		end
		puts ("__" * 40)
	end #end verify_path

	#________________________________________
	# - Classes - 
	class Import # the actual text files
		# example call: 
		# iroha = Reader::Import.new("../test_file.txt")
		attr_reader   :original, :path, :ext, :name, :write_protection, :path, :size
		attr_accessor :text, :base_name, :full_name

		def initialize (path) 
			# Note: This object assumes a relative path from the current working directory
			#    - This will be sorted out in Folder class
			path.strip!
			@name 					= File.basename(path, ".*")
			@full_name      = File.basename(path) 
			@path  					= File.expand_path(path)
			@dir_name       = File.dirname(path)
			@ext            = File.extname(path)

			@comment_char = "//"
			@join_char 		= "" 		# the character used to join the text together if it was broken up
			@auto_set 		= true 	# automatically reformats text after any of the split methods are called

			@original 				= File.readlines(@path)	# always reads from the full path
			@size							= File.size?(@path) || 0
			@text 						= @original.dup
			@write_protection = true  # protects the real file from being overwritten
		end

		def convert_size (size)
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
			#   - format this further in Folder (including which entity calls `puts`)
			# 	- `small` is to accomodate list indexing (see Folder.list)
			name_len 	= 17
			size_len 	= 9
			dir_len 	= small ? 30 : 38
			dir_off		= small ? -25 : 33

			base_str 	= "| #{ @full_name.length > name_len ? "...#{@full_name[-13..]}" : @full_name }"
			size_str 	= convert_size(@size)
			dir_str 	= "#{ @dir_name.length > dir_len ? "...#{@dir_name[-25..]}" : @dir_name}"

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
	end #end class Import

	
	class Folder # contains Import objects; default class

		attr_reader  :name, :path, :extensions, :imports

		def initialize (folder_name, path, *ext)      
			@name = folder_name
			@path = File.expand_path(path)
			@extensions = ext
			@imports = [] #the actual objects
			@table = []

			Dir.each_child(@path) { |c| add(c) if @extensions.any? { |e| File.extname(c) == e || (File.file?(c) && e == ".*")} } 
			
		end

		def add (filename)
			addition = "#{@path}/#{filename}"
			return "** Error in folder `#{@name}#add(#{filename})`: Invalid filename **" if !File.exist?(addition)
			@imports << Reader::Import.new(addition)
			@table << filename
			@extensions << File.extname(addition) if !@extensions.include?(File.extname(addition))
		end

		def method_missing (m, *args, &block)
			@imports.detect { |file| file.name == "#{m}" } || "Error: no #{m} Import in #{@name} Folder"
		end

		def info 
			# Note: NAME  SIZE   DIR  EDITED?
			#   - format this further in Folder (including which entity calls `puts`)
			name_len 	= 17
			size_len 	= 9
			dir_len 	= 38

			name_str 	= " #{ @name.length > name_len ? "...#{@name[-13..]}" : @name }"
			size_str 	= @imports.length.to_s
			dir_str 	= "#{ @path.length > dir_len ? "...#{@path[-35..]}" : @path}"

			name_str + (" " * (name_len - name_str.length)) + 
			" | " + 
			size_str + (if size_str.length < size_len then (" " * (9 - size_str.length)) else "" end) +
			" | " +
			dir_str #+ (" " * (dir_len - dir_str.length)) <- commented out for now
		end

		def full_directory
			Dir.children(@path).each_with_index { |e, i|
					puts "#{i}.	#{e}"
				}
		end

		def list
			@imports.each_with_index { |e, i|
					puts "#{i}.	#{e.info(true)}"
				}
		end

		def file (filename)
			@imports.detect { |file| file.full_name == "#{filename}" }
		end
		
	end #end class Folder

	
	class Collection # contains Folder object; is available for convenience but is not necessary

		attr_accessor  :all

		def initialize (name) 
			@all = []
			@paths = path
			@exts = ext

			add(path, ext) if path != "" && ext != ""
		end

		def add (folder, ext)
		end

		def remove (folder)
		end

		def _update
		end

		def list
			"Folders in #{@name} collection:"
		end
	end #end class Collection

end

#________________________________________
# - TESTING - 
path = +"~/reader"
Reader.verify_path(path)
# g = Reader::Folder.new("test_folder", ".", ".rb")
# puts g.extensions.to_s
# puts g.info
# g.list
# puts g.iroha.info

ver = Reader::Verifier.new(path)

ver.show_info

# def assign_val (val)
# 	raise Reader::Error::WrongValueError.new("LKJLKJ") if val > 4
# 	puts val
# end

# begin
# 	assign_val(5)
# rescue Reader::Error::WrongValueError => e
# 	puts e
# 	puts $@
# end
#### Dir.each_child(path) { |child| code } 0725
