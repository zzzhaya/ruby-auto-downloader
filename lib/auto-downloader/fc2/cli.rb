require 'optparse'
require 'auto-downloader/fc2'

module Fc2
  class CLI
    def self.execute(stdout, arguments=[])
      #出力同期
      stdout.sync=true

      options = {
        :path     => "#{Dir.pwd}",
        :min      => 20,
      }
      mandatory_options = %w(  )

      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          Crawl FC2 blog and download all images.

          Usage: #{File.basename($0)} [options] TargetURL

          Options are:
        BANNER
        opts.separator ""
        opts.on("-p", "--path=PATH", String,
                "Directory to save images",
                "Default: current directory") { |arg| options[:path] = arg }
        opts.on("-m", "--min=NUMBER", String,
                "Save all images in TargetURL ",
                "if it has at least NUMBER images",
                "Default: 20"){|arg| option[:min] = arg.to_i }
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)

        if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
          stdout.puts opts; exit
        end

        if(arguments == [])
          puts "Target URL is required"
          stdout.puts opts; exit
        else
          options[:url] = arguments
        end
      end

      path = options[:path]

      # do stuff
      Dir.chdir(path) do
        app = AutoDownloader::Fc2.new(options)
        app.run
      end
    end
  end
end
