require 'sinatra'
require 'aws/ses'

configure do
  enable :logging
  set :ses, AWS::SES::Base.new(:access_key_id => 'AKIAJKCSLTTTQDBOB5KQ', 
                               :secret_access_key => '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')
end

post '/' do
  begin
    settings.ses.send_email :to        => ['sales@precinstr.com'],
                            :source    => %Q{"#{params[:from]}" <sales@precinstr.com>},
                            :reply_to  => params[:from],
                            :subject   => params[:subject],
                            :text_body => params[:message]
 
    redirect request.referrer.split('?').first + '?sent=true'
  rescue
    redirect request.referrer.split('?').first + '?message=<strong>There was a problem...</strong><br>Are you sure you entered a valid email address?'
  end
end
