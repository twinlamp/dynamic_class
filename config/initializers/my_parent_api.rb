require 'httparty'
apis = YAML.load_file('apis.yml')
apis.each do |api|
  klass = Class.new(api['parent_class'].constantize) do
    define_singleton_method :run do
      times_retried = 0
      begin
        resp = HTTParty.get(api['url'], timeout: api['max_timeout'])
        json = JSON.parse(resp.response.body) if resp
      rescue Net::ReadTimeout => error
        if times_retried < api['max_retries']
          times_retried += 1
          puts "Failed to get #{api['url']}, retry #{times_retried}/#{api['max_retries']}"
          retry
        else
          puts "Failed to get #{api['url']} in #{api['max_retries']} attempts"
          next
        end
      end
      if json
        instance = api['parent_class'].constantize.new
        api['parameter_map'].each do |k, v|
          instance.send("#{v}=", json[k])
        end
        instance.save
      end
    end
  end

  Object.const_set(api['api_class'], klass)
end