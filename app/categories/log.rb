module Kernel
  def error(type, data={})
    _message(:error, type, data)
  end

  def log(type, data={})
    _message(:log, type, data)
  end

  private
  def _message(type, level, data={})
    date = NSDate.now.string_with_format(:iso8601)
    case RUBYMOTION_ENV
    when 'test'
      puts "[#{date}][#{type}][#{level}]: #{data.inspect}"
    when 'development'
      mp date: date,
         type: type,
         level: level,
         data: data
    else
      File.open(log_file, 'a') {|file| file << "[#{date}][#{type}][#{level}]: #{data.inspect}\n"}
    end
  end

  def log_file
    file ||= begin
      date = NSDate.now
      five_days = date - 5.days

      log_dir = "/Library/Logs/HSTracker".home_path
      Dir.mkdir(log_dir) unless Dir.exists?(log_dir)

      Dir.glob("#{log_dir}/*.log").each do |file|
        # old logs
        base_name = File.basename(file)
        components = base_name.gsub(/\.log/, '').split('-')
        file_date = NSDate.from_components(year: components[0], month: components[1], day: components[2])
        file_size = File.size(file)

        if file_size > 10000000 || file_date < five_days || base_name =~ /^be\.michotte\.hstracker /
          File.delete(file)
        end
      end

      "/Library/Logs/HSTracker/#{date.date_array.join('-')}.log".home_path
    end
  end
end
