require 'sinatra'
require_relative 'lib/state'
require_relative 'lib/features'
require_relative 'lib/slack_deploy'

class MyApp < Sinatra::Base
  get '/' do
    erb :index, locals: { state: State.new }
  end

  get '/features' do
    @features = Features.new
    @sorted_features = @features.all.sort_by { |f| %w[confused shipping ok].index(f.state) }
    erb :features
  end

  post '/slack-webhook' do
    payload = JSON.parse(params.fetch('payload'))
    puts "payload: #{payload}"

    Thread.new do
      slack_message_body = SlackDeploy.new.step_2.to_json
      x = HTTP.post(payload.fetch('response_url'), body: slack_message_body)
      puts x.status
    end

    {}.to_json
  end
end
