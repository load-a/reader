# Reader

A gem for importing source code into your program.

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/reader`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Usage

This gem takes source code files and converts them into arrays that can more easily be used and maipulated by your program. 

The intended use for this gem is to import source code files as plaintext arrays, so that the user or their program can more conveniently manipulate and read them. For example, say you're building a parser for Java files. A normal way of importing them into your program could look something like this:

```ruby
source_path = ARGV[0]

source_files = Dir.entries(source_path)
source_files.map! { |e|
        e if e =~ /(.java)/ || e =~ /(.class)/
    }

source_code = source_files.each { |e|
        File.open("#{source_path}/#{e}").readlines
    }
```

With this gem, the whole process (and more) has been condensed into this:

``` ruby
source_code = Reader::Chapter.new("Java Files", "../source", ".java", ".class")
```

### Basic Uses
Its primary usage is importing directory files using the `Chapter` class. When initiated, this class scans the given directory for all files with the given extension(s). It then turns each into a `Page` object, and store them in an array. Each object can be interacted with individually in various ways.

### Chapter Class
This is the primary class of this gem, but it is not the most fundemental unit. This class takes a `name`, a `path`, and one or more `extensions` and creates an array of `Page` objects of all matching files. Each Chapter can be thought of as a single folder or directory, although you may want to create multiple chapters with different criteria from the same directory. Chapters are created as shown below:
```ruby
Reader::Chapter.new("NAME", "PATH", "EXTENSION1", "EXTENSION2" ) # one or more extensions can be passed
```

The `name` parameter is a String. Names are required but they do not have to be unique (although it is highly recommended they are). Names are useful for conveniently reffering to a `Reader` object in a way the other objects will recognize. For example, a Page in a Chapter can be called _by name_ using the `file` method.

The `path` parameter is also a String and is also required. This is the string used to find the given directory. By default, this class asssumes relative paths, althoug absolute paths can be called by putting a backslash at its the beginning. This gem will expand the provided path to use as a basis for all of its operations. So passing `".."` could result in the gem looking for `Users/username/folder`. The home abbreviation `~` is recognized by some Ruby methods and not others, so it is recommended that the user avoid using it.

Finally, `extensions` can be multiple Strings of the format `".extension"`. This class looks for these by calling Ruby's `File.extname`, method. When given a file with multiple extensions, only the last one will be considered the _true_ extension. 
```ruby
File.extname("something.rb.txt") # => name is "something.rb", ext is ".txt"
```

### Page Class
Each file a Chapter object imports is converted first into a `Page` object. The Page class then converts its file into a text array. Each Page has properties such as `name`, `full_name`, `text`, `size`, etc. All of these are derived from the actual file Ruby finds on the machine and not any user input. Therefore, a Page is only initiated with its filepath. Pages can be manually created by calling:
```ruby
Reader::Page.new("PATH")
```
Creating them this way may be preferable when only a few files need to be imported. Pages can be manually `add`ed to existing Chapters.

### Text Manipulation
As states, this gem was designed for importing source code, which would then be used in a parser or other kind of analysis program. Therefore, Page objects come with a number of built-in methods for modifying their text. The most important ones are the "split" and the "remove" methods. As their names imply, the "split" methods divide the text into seperate elements based on certain criteria: words, punctuation or characters. The "remove" methods can be used to remove comments and newlines. A full list of each class's methods is included at the end of this section. All of these changes effect the object's `text` property, but the `original` read is preserved. The `text` can also be `reset` to its original form.

### Definition Class
There is a fourth class included in this gem called `Definition`. Its purpose is to provide the user with diagnostic information about a given path. This information includes `extname`, the current working directory, the type of item the path leads to (file or directory; all others are considered unimportant for the purposes of this gem), the actual path Ruby is searching for, file information, directory children, etc. This is so that the user can more thoroughly understand and debug any paths they intend to use. Because it is a class (and not a method, as it was originally designed) the user can extract various bits of information directly from the path provided. The presentation has been formatted for easier reading.

```ruby
Reader::Definition.new("PATH").show_info # => will print a list of information to the console (formatted for an 80 column display)
```

### Albums
The `Album` class is an optional feature implemented in case the user wanted a built-in way to manage multiple Chapter objects. It is a container for Chapters in the same way Chapters are containers for Pages. They can be added to or removed from the Album as the user desires. It can be initialized with existing Chapters, but this is optional. A `name` is the only required parameter.


### Classes and Methods

#### Page Class
**Attributes:**
_(Read Only)_
- name
> The filename without the extension
- full_name
> The filename with the extension
- path
- extension
- write_protection 
> The `write` method writes to its own `path` by default. `write_protection` is set to _false_ so that it doesn't overwrite the existing file. Can be permanently toggeled through `change_ protections`, or temporarily by passing `force_overwrite: true` into the `write` call.
- size
> The original filesize, in bytes.
- original
> the original read
_(Accessable)_
- text
> The edited text.
_(Accessible via Method Call)_
- edited?
> Returns _true_ or _false_ based on whether the `text` has been edited.

**Methods**
- info
> Formatted text containing basic Page info.
- write(PATH\*, FORCE_OVERWRITE\*)
- reset
- change_protection(CHANGE_TO\*)
- remove_comments(COMMENT_CHAR\*)
- remove_newlines
- split_words
- split_punct
- split_char


#### Chapter Class
**Attributes**
_(Read Only)_
- name
- path
- extensions
> A list of currently recognized extensions.
- pages
> The list of page objects.

**Methods**
- add(FILENAME-OR-PAGE_OBJECT)
- remove(PAGE.NAME)
- info
- show_full_directory
- show_list
- file(FILENAME)
> Use this to call a file by name, rather than index.


#### Album
**Attributes**
_(Read Only)_
- name
_(Accessible via Method Call)_
- chapters

**Methods**
- add(CHAPTER_OBJECT)
- remove(CHAPTER.NAME)


#### Definition
**Attributes**
_(Read Only)_
- path
- full_name
- directory
- extension
- type

**Methods**
- show_general_info
- show_directory_info
- show_file_info
- show_info
> Shows all available info for the given path. This should be the default info method.

\* All "show" methods print automatically



## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/load-a/reader.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
