require './xml_parser.rb'

class XmlApp < Sinatra::Base
  get '/' do
    erb :index
  end

  post '/' do
    ParseXml.new(params['file1'][:tempfile], params['file1'][:filename]).do_work_son

    redirect "/success/#{params['file1'][:filename]}"
  end

  post '/download' do
    send_file("./#{params[:filename]}")
    erb :index
  end

  get '/success/:filename' do
    @filename = "#{params[:filename]}"
    erb :success
  end

  not_found do
    erb :error
  end
end
