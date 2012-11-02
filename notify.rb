require 'libnotify'
require_relative '.lib/lingr'
require_relative './setting'

# lingr の設定
lingr_conf = {
  :user    => Lingr_user,
  :pass    => Lingr_password,
  :app_key => {},
    # You don't have to modify, if you don't use app_key.
    # Default : {}
  :proxy   => {}
    # If you want to connect lingr via proxy.
    # In default setting, use $http_proxy server.
    # List of Hash keys :
    # 'host'
    # 'port'
    # 'proxy_user'
    # 'proxy_pass' 
}

# notify の設定
Notify_conf = {
  :summary    => "lingr",
  :body       => "",
  :timeout    => 2.5,
  :urgency    => :normal,
  :append     => false,
  :transient  => true,
  :icon_path  => Linger_icon_path
}

def send_elem_notify(e, notify_conf=Notify_conf)
  if e.has_key?('message')
    m = e['message']
    if m.has_key?('icon_url')
      i = m['icon_url']
    else
      i = notify_conf['icon_path']
    end
  end
  notify = notify_conf
  notify[:summary] = m['speaker_id']
  notify[:body] = m['text']
  # notify はリモート url 指定できない
  # そのうち、リモートから画像取ってキャッシュするようにしたい
  #notify[:icon_path] = i
  Libnotify.show(notify)
end

conf = lingr_conf.values

lingr = Lingr.new(conf[0], conf[1], conf[2], conf[3])
elem = {}
stream = lingr.stream
enum_stream = stream.each
  while true
    begin
      elem = enum_stream.next
      send_elem_notify(elem)
    rescue
      sleep(60)
      stream = lingr.stream
      enum_stream = stream.each
      next
    end
end
