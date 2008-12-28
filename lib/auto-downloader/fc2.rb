require 'auto-downloader'

module AutoDownloader
  class Fc2 < AutoDownloader
    # opts : options[:url, :min]
    def initialize(opts)
      if(
        if(opts[:url].respond_to?(:shift))#配列の場合
          s=opts[:url].each do |s|
            all_ok = true
            all_ok &&= (/http:\/\/(.+?).blog\d+?.fc2.com/ =~ s) #全てtrueならば all_ok == true のまま
          end
        else
          /http:\/\/(.+?).blog\d+?.fc2.com/ =~ opts[:url] #直接Stringが渡された場合
        end
      )
        #@blogname = $1
        #@pattern = %r@(http://blog-imgs-\d+?\.fc2\.com/#{@n[0,1]}/#{@n[1,1]}/#{@n[2,1]}/#{@n}/[^s]+?\.(jpg|gif|png))@
        @url = opts[:url]
        @pattern = %r@(http://blog-imgs-\d+?\.fc2\.com/\w/\w/\w/[^/]+?/[^/]+?[^s]\.(jpg|gif|png))@
        @min = opts[:min]
      else
        raise "Not FC2 : #{opts[:url]} "
      end
    end
  end
end
