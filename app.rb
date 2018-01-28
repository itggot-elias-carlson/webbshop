require_relative './model/model.rb'

class App < Sinatra::Base

	enable :sessions
	include TodoDB

	get('/') do
		slim(:index, locals:{user: session[:user], error: session[:error]})
	end

	get('/login') do
		slim(:login, locals:{user: session[:user], error: session[:error]})
	end

	get('/register') do
		slim(:register, locals:{user: session[:user], error: session[:error]})
	end

	get('/shop') do
		session[:user] = {"id"=>1, "name"=>"test", "email"=>nil, "password"=>"$2a$10$SRXb1zAYFQOBpjHm.A8zceKr/mRkOI.QJiT7N4duD6m20j6A2lwtm", "account_type"=>nil, 0=>1, 1=>"test", 2=>nil, 3=>"$2a$10$SRXb1zAYFQOBpjHm.A8zceKr/mRkOI.QJiT7N4duD6m20j6A2lwtm", 4=>nil}
		articles = get_articles()
		carts = get_carts(session[:user]["id"])
		p carts
		slim(:shop, locals:{user: session[:user], articles: articles, carts: carts})
	end

	post('/register') do
		username = params[:username]
		password = params[:password]
		password_confirmation = params[:password_confirmation]

		user = get_user(username)

		if user == nil
			if password != password_confirmation
				session[:error] = "Passwords don't match."
				redirect('/')
			else 
				create_user(username, password)
				redirect('/login')
			end
		else
			session[:error] = "Username already exists."
			redirect('/')
		end
	end

	post('/login') do
		username = params[:username]
		password = params[:password]

		user = get_user(username)

		if user
			if BCrypt::Password.new(user["password"]) == password
				session[:user] = user
				# session[:user_id] = user["id"]
				redirect('/shop')
			else
				session[:error] = "Wrong username or password."
				redirect('/login')
			end
		else
			session[:error] = "Wrong username or password."
			redirect('/login')
		end
	end    

	post('/add_to_cart') do
		article_id = params[:article_id]
		user_id = session[:user]["id"].to_s

		add_to_cart(article_id, user_id)
		redirect('/shop')
	end
end