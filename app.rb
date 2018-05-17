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
		groupname = get_groupname(user_id)
		slim(:grouplist, locals:{groupname:groupname} )
	end 

	get '/todo' do
		slim(:todo)
	end

	get '/grouppage/:id' do
		user_id = session[:user_id]
		group_id = params[:id].to_i
		groupname = get_groupname(user_id)
		members = get_members(group_id)
		username = get_username(user_id)
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
		username = params["username"]
		password = params["password"]
		user_id = get_user_id(username)
		password_digest = get_password(username)
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
		username = params["username"]
		password = params["password"]
		password2 = params["password2"]
		password_digest = BCrypt::Password.create("#{password}")
		usernames = get_usernames(username)
		if username.length > 3
			if password == password2 && password.length > 0
				if usernames.include?([username])
					session[:message] = "The username is unavailable"
					redirect('/error')
				else
					create_user(username, password_digest)
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
		groupname = params["name"]
		create_group(user_id, groupname)
		redirect('/grouplist')
	end

end