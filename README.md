# Reader

TODO: Delete this and the text below, and describe your gem

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/reader`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Usage

Importing a Directory
Create a variable and set it to a new InDir object. Pass in the path and the desired file extension (no dot) as arguments.
``` ruby
my_stuff = Reader::InDir.new("Stuff", "my")
# This uses a relative address. If the current directory is "Mine", this looks for the "Stuff" folder in that directory.

your_stuff = Reader::InDir.new("library/Yours/stuff", "yr", true) 
# To use an absolute address, set a path from the Home directory and include TRUE as a third argument. 
# This sets a flag telling the class to adjust its directory during initialization.

any_stuff = Reader::InDir.new("stuff", "*")
# Passing in a wildcard (*) will import any files in the directory
```

The InDir class has four instance vairiables: `path` (the original path used to initialize the object), `ext` (the original file extension), `raw_list` (a hash containing a numbered list of the extracted filenames) and `files` (an array containing the OutText objects, ordered in the same way as the `list` and `raw_list`). These can only be read. Additionally it has two methods: `.list(show_IDs)` which returns an array containing a formatted version of the `raw_list`,  and `.file(name)` which can be used to access a OutText object by name. `.list` accepts an optional boolean argument, which when set to TRUE also includes object IDs. `.file` takes the filename you want as a string.

`.list` Example
```ruby
puts my_stuff.list # =>     list of .my files in Stuff
#                           0. code.my
#                           1. notes.my

```

`.file` example
``` ruby
puts my_stuff.file("code.my").text # => puts "Hello World!"
# This makes it easy to use an OutText object without creating a new variable.
```

Outputing Text
When the InDir is created it cycles through its directory and extracts files with its extension. It then creates OutText objects, which copy the files' texts into themselves. These new objects can be operated on as regular arrays by accessing the `text` instance variable. The OutText class also has a few additional methods: `.remove_comments(comment_char)`, `.remove_newlines`, `.split_words`, `.split_punct` and `split_char`. These are pretty much self-explanatory. `.remove_comments` defaults to "//" if no argument is passed. (This is because this gem was created to parse different language texts.) The `split_` methods break each line of text into: words (separated by spaces), punctuation (like words but each punctuation is also separated), and characters, respectively. These three methods also change the `join_char` automatically to "\n" so that each separation takes up its own line.

There are several instance variables which can be accessed. These are `original` (the original read of the text), `text` (the text with all adjustments made), `comment_char` (defaults to "//"), `join_char` (the character used to `.join` each separation made; defaults to "", nothing), and `auto_set` (a boolean value that tells the `split_` methods to reformat the text after making their adjustments; defaults to TRUE). All of these can be manually accessed, except for `original` which can only be read.

Finally, there are two other methods to talk about. These are `write(path)` and `.reset`. `.write` will write the `text` to a file, which defaults to the objects path and extension. This can be manually changed by passing the desired path (including filename and extension) into the method call. This method only accepts relative paths from the current working directory. `.reset` will reset the `text` to match the `original`. 

It is possible--but not recommended--to create OutText objects directly, without using an InDir object. If the user chooses to do this, they should be aware that a `path` is required (though there is no option to use an absolute path), and that an `extension` is optional but it will default to ".otf". This is to protect any files from being overwritten in case `.write` was called improperly.

```ruby
output = Reader::OutText.new("./output.txt")
output.write # => output.txt.otf
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/reader.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
