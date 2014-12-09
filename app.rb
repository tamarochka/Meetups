require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'
require "pry"

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

get '/' do
  @titles = Meetup.all

  erb :index
end

get '/add' do
  if signed_in?
    erb :add
  else
    authenticate!
  end
end

post '/add' do

  meetup_name = params['meetup_name']
  meetup_description = params['meetup_description']
  meetup_location = params['meetup_location']

  Meetup.create(name: meetup_name, description: meetup_description,location: meetup_location)

  redirect '/'
end


get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."


  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end

get '/:id' do
  id = params["id"]
  @meetup = Meetup.find(id)
  
  if signed_in?
    if Registration.where({user_id: current_user.id, meetup_id: id}).count == 0
      erb :show
    else
      erb :delete
    end
  else
    erb :show
  end
end

post '/join/:id' do

  if signed_in?

    id = params['id']
    user = current_user
    Registration.create(user_id: user.id, meetup_id: id)
    flash[:notice] = "You've registered for a meetup!."

    redirect '/'
  else
    authenticate!
  end
end

# delete '/registrations/:id'
post '/delete/:id' do
  id = params['id']
  user = current_user
# binding.pry
  a = Registration.where({user_id: user.id, meetup_id: id}).destroy_all

  flash[:notice] = "You are no longer registered for a meetup."

  redirect '/'
end

post '/comment/:id' do

  if signed_in?

    id = params['id']
    user = current_user
    Comment.create(user_id: user.id, meetup_id: id, comment_body: params['meetup_comment'])
    flash[:notice] = "Thank you for your comment!"

    redirect '/'
  else
    authenticate!
  end
end
