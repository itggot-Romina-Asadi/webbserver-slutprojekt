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

end           
