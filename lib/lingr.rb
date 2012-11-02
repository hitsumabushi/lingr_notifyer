#
# LingrのAPIを扱うためのライブラリ
#

require 'open-uri'
require 'net/http'
require 'uri'
require 'json'

class Lingr
  URL_BASE = 'http://lingr.com/api/'
  URL_BASE_OBSERVE = 'http://lingr.com:8080/api/'

  def initialize(user, pass, app_key=nil, proxy={})
    @user=user
    @pass=pass
    @post_proxy=proxy
    @app_key={:app_key => app_key}
    if proxy == false
      @get_proxy={:proxy => false}
    elsif proxy == true || proxy == {}
      @get_proxy={:proxy => true}
    else
      @get_proxy={:proxy_http_basic_authentication => proxy.values}
    end
    @counter=0
    @user_agent={'User-Agent' => 'ruby lingr(hitsumabushi)'}
  end

  # セッションの作成。返り値で成功したかわかる
  def create_session
    data = self.post('session/create',
                     { 'user' => @user, 'password' => @pass })
    if data
      @session  = data['session']
      @nickname = data['nickname']
    end
    return data
  end

  def get_rooms
    data = self.get('user/get_rooms', \
                    { 'session' => @session })
    @rooms = data['rooms'] if data
    return data
  end

  def subscribe(room=false, reset='true')
    if !false
      room = (@rooms).join(',')
    end
    data = self.post('room/subscribe', \
                     { 'session' => @session,\
                       'room' => room,\
                       'reset' => reset })
    @counter = data['counter'] if data
    return data
  end
  def observe
    data = self.get('event/observe', \
                    {'session' => @session, 'counter' => @counter})
    @counter = data['counter'] if data.include?('counter')
    return data
  end
  def say(room, text)
    data = self.post('room/say', \
                     {'session' => @session,\
                      'room' => room,\
                      'nickname' => @nickname,\
                      'text' => text})
    return data
  end

  # Post method
  def post(path, params)
    options = (params.merge(@app_key)).merge(@user_agent)
    uri = URI.parse(get_url(path))
    http = Net::HTTP::Proxy(@post_proxy['host'], @post_proxy['port'], @post_proxy['proxy_user'], @post_proxy['proxy_pass']).post_form(uri, params)
    #http = Net::HTTP.post_form(uri, params)
    return self.loads(http.body)
  end

  def get(path, params)
    options = @get_proxy.merge(@user_agent)
    params = params.merge(@app_key)
    uri = URI.parse(self.get_url(path + '?' + hashed_param_get(params)))
    return self.loads(uri.read(options))
  end

  # JSON をパースしてエラーが起きてないか見る
  def loads(json)
    data = JSON.parse(json)
    if data['status'] == 'ok'
      return data
    else
      puts 'error'
      puts data
    end
  end

  # pathを受け取って、URLを表す文字列を返す
  def get_url(path)
    url = URL_BASE
    if path == 'event/observe'
      url = URL_BASE_OBSERVE
    end
    return url + path
  end

  # Hash を受け取って、GET の時に使えるよう&でつなぐ
  def hashed_param_get(param)
    return param.map{|k, v| URI.encode(k.to_s) + '=' + URI.encode(v.to_s)}.join('&')
  end

  def stream
    self.create_session
    self.get_rooms
    self.subscribe
    while true
      obj = self.observe
      if obj.include?('events')
        p obj['events']
        return obj['events']
      end
    end
  end
end

