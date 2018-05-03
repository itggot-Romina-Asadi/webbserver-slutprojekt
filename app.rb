class App < Sinatra::Base
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
		((user_id = session[:user_id]).to_s).to_i
		p user_id
		db = SQLite3::Database.new("db/slutprojekt.db")
		groupname = db.execute("SELECT * FROM groups WHERE user_id=?", [user_id])
		slim(:grouplist, locals:{groupname:groupname} )
	end 

	get '/todo' do
		slim(:todo)
	end

	get '/grouppage/:id' do
		((user_id = session[:user_id]).to_s).to_i
		group_id = params[:id].to_i
		db = SQLite3::Database.new("db/slutprojekt.db")
		groupname = db.execute("SELECT name FROM groups WHERE user_id=?", [user_id])
		members = db.execute("SELECT username FROM users WHERE user_id IN (SELECT user_id FROM groups WHERE group_id = ?)", [group_id])
		slim(:grouppage, locals:{group:groupname, users:members, group_id:group_id} )
	end

	get '/members/:id' do
		group_id = params[:id].to_i
		db = SQLite3::Database.new("db/slutprojekt.db")
		groupname = db.execute("SELECT name FROM groups WHERE user_id=?", [user_id])
		members = db.execute("SELECT username FROM users WHERE user_id IN (SELECT user_id FROM groups WHERE group_id = ?)", [group_id])
		p members
		p groupname
		slim(:grouppage, locals:{group:groupname, users:members, group_id:group_id} )
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

	post '/group' do
		((user_id = session[:user_id]).to_s).to_i
		db = SQLite3::Database.new("db/slutprojekt.db")
		groupname = params["name"]
		db.execute("INSERT INTO groups (user_id, name) VALUES (?, ?)", [user_id, groupname])
		redirect('/grouplist')
	end

end