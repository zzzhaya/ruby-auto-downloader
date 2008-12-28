$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'open-uri'
require 'kconv'
require 'date'

module AutoDownloader
  class AutoDownloader
    attr_reader :url, :pattern, :min
    def initialize()
      @url
      @pattern#拾う画像URLのパターン
      @min    #画像の数が@min以下ならば画像はとらない
    end

    def run()
      if @url.respond_to?(:shift) #@urlがArray(複数)なら
        while url = @url.shift
          save url
        end
      else
        save @url
      end
    end

    private
    # downloaded_images = save(url)
    # url : String url all images in which will be downloaded
    # return : Array downloaded images
    def save(url)
      downloaded_images = Array.new
      source = URI.parse(url).read
      images = source.scan(@pattern)

      if @min and @min > 0 and images.size < @min
        puts "FEW IMAGES : #{source.base_uri} の画像数が指定された#{@min}を下回りました : ", images.join(', ')
        raise
      end

      #日付+ディレクトリ名をタイトルに。
      if /<title>([^\/\\]*?)<\/title>/ =~ source and $1!='' 
        if(Kconv.guess($1) == Kconv::ASCII)
          savedir = $1.kconv(Kconv::UTF8,  Kconv::EUC) #半角カナがあるとASCIIと間違えがちなので、EUC-JPに決め打ち。こうしないと文字が化ける。
        else
          savedir = $1.toutf8
        end
        savedir = Date::today.to_s + savedir
        Dir.mkdir(savedir) unless File.exist?(savedir)
      else
        raise "not appropirate title : #{source.base_uri}のタイトルが不適切です"
      end

      Dir.chdir(savedir) do
        images.each do |_image|
          image_url = URI.parse( _image.respond_to?(:shift) ? _image.shift : _image ) #String#scan(@pattern)は、@patternの正規表現に()があったら配列を、無かったら文字列を返す。もし()を使うなら、URLパターン全体を()でくくって下さいな
          savefile = File.basename(image_url.path)
          unless File.exists? savefile
            begin
              open(savefile, 'wb') do |_save|
                print "downloading #{image_url.to_s} from #{savedir}"
                _save.write(image_url.read)
                print "done\n"
              end
            rescue
              puts "; Error saving #{image_url.to_s} from #{savedir} : #{$!}"
            end
          else
            puts "exists #{image_url.to_s} from #{savedir}"
          end
          downloaded_images.push(image_url.to_s)
        end
      end

      return downloaded_images
    end

  end
end
