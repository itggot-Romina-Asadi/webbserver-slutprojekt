class App < Sinatra::Base

	get '/' do
		slim(:index)
	end

	get '/signin' do
		slim(:signin)
	end

	get '/signup' do
		slim(:signup)
	end

	get '/mypage' do
		slim(:mypage)
	end

	get '/group' do
		slim(:members)
	end

	get '/todo' do
		slim(:todo)
	end

	get '/error' do
		slim(:error, locals:{msg:session[:message]})
	end

	post '/signin' do
		db = SQLite3::Databse.new("slutprojekt.db")
		username = params["username"]
		password = params["password"]
		user_id = db.execute("SELECT user_id FROM signin WHERE username='#{username}'")
		password_digest = db.execute("SELECT password FROM signin WHERE username='#{username}'").join
		password_digest = BCrypt::Password.new(password_digest)
	end

end           
