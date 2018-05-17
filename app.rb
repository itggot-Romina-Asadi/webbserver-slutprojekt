class App < Sinatra::Base

	require_relative 'module.rb'
	include Database
	enable :sessions

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

	get '/logout' do
		session.clear
		redirect('/')
	end

	get '/group' do
		slim(:groups)
	end

	get '/grouplist' do
		user_id = session[:user_id]
		db = SQLite3::Database.new("db/slutprojekt.db")
		groupname = db.execute("SELECT * FROM groups WHERE user_id=?", [user_id])
		slim(:grouplist, locals:{groupname:groupname} )
	end 

	get '/todo' do
		slim(:todo)
	end

	get '/grouppage/:id' do
		user_id = session[:user_id]
		group_id = params[:id].to_i
		db = SQLite3::Database.new("db/slutprojekt.db")
		groupname = db.execute("SELECT name FROM groups WHERE user_id=?", [user_id])
		members = db.execute("SELECT username FROM users WHERE user_id IN (SELECT user_id FROM groups WHERE group_id = ?)", [group_id])
		username = db.execute("SELECT username FROM users WHERE user_id = ?", [user_id]).join
		if members.include?([username])
			slim(:grouppage, locals:{group:groupname, users:members, group_id:group_id})
		else
			session[:message] = "You're not a member of this group"
			redirect('/error')
		end
	end

	get '/error' do
		slim(:error, locals:{msg:session[:message], direction:session[:direction]})
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
		usernames = db.execute("SELECT username FROM users")
		p usernames
		p [username]
		p usernames.include?([username])
		if username.length > 3
			if password == password2 && password.length > 0
				if usernames.include?([username])
					session[:message] = "The username is unavailable"
					redirect('/error')
				else
					db.execute("INSERT INTO users (username, password) VALUES (?,?)", [username, password_digest])
					redirect('/signin')
				end
			else
				session[:message] = "Password unavailable"
				redirect('/error')
			end
		else
			session[:message] = "The username is too short"
			redirect('/error')
		end
	end

	post '/group' do
		user_id = session[:user_id]
		db = SQLite3::Database.new("db/slutprojekt.db")
		groupname = params["name"]
		db.execute("INSERT INTO groups (user_id, name) VALUES (?, ?)", [user_id, groupname])
		redirect('/grouplist')
	end

end