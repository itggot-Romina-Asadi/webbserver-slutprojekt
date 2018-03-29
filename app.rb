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
		db = SQLite3::Database.new("db/slutprojekt.db")
		username = params["username"]
		password = params["password"]
		user_id = db.execute("SELECT user_id FROM users WHERE username='#{username}'")
		password_digest = db.execute("SELECT password FROM users WHERE username='#{username}'").join
		password_digest = BCrypt::Password.new(password_digest)
		if password_digest == password
			session[:username] = username
			session[:user_id] = user_id
			redirect('/mypage')
		else
			redirect('/')
		end
	end

	post '/signup' do
		db = SQLite3::Database.new("db/slutprojekt.db")
		username = params["username"]
		password = params["password"]
		password2 = params["password2"]
		password_digest = BCrypt::Password.create("#{password}")
		if username.length > 0 
			if password == password2 && password.length > 0
				begin
					db.execute("INSERT INTO users (username, password) VALUES (?,?)", [username, password_digest])
				rescue 
					session[:message] = "The username is unavailable"
					redirect('/error')
				end
				redirect('/signin')
			else
				session[:message] = "Password unavailable"
				redirect('/error')
			end
		else
			sesson[:message] = "The username is unavailable"
			redirect('/error')
		end
	end

end