require 'sinatra'
require 'aws/ses'

configure do
  enable :logging
  set :ses, AWS::SES::Base.new(:access_key_id => ENV['ACCESS_KEY'], 
                               :secret_access_key => ENV['SECRET_KEY'])
end

get '/ping' do
  'pong'
end

get '/debug' do
    settings.ses.send_email :to        => ["cannikinn@gmail.com"],
                            :source    => %Q{"debug" <sales@#{params[:domain] || 'precinstr.com'}>},
                            :reply_to  => 'sales@precinstr.com',
                            :subject   => 'Email successful.',
                            :text_body => 'Email was sent (obviously)'

    "ok"
end

post '/' do
  begin
    settings.ses.send_email :to        => ["sales@#{params[:domain] || 'precinstr.com'}"],
                            :source    => %Q{"#{params[:from]}" <sales@#{params[:domain] || 'precinstr.com'}>},
                            :reply_to  => params[:from],
                            :subject   => params[:subject],
                            :text_body => params[:message]
 
    redirect request.referrer.split('?').first + '?sent=true'
  rescue => e
    puts e.inspect
    redirect request.referrer.split('?').first + '?message=<strong>There was a problem...</strong><br>Are you sure you entered a valid email address?'
  end
end
