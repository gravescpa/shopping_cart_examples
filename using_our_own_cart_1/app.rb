require 'sinatra'
require 'rubygems'
require 'tilt/erb'
require 'pg'

load "./local_env.rb" if File.exists?("./local_env.rb")

db_params = {
   host: 'joe123.cpdneptoktvs.us-west-2.rds.amazonaws.com',
   port:'5432',
   dbname:'joe123',
   user:'joe1mck',
   password:'bubbadog',    
}

db = PG::Connection.new(db_params)

set :sessions, 
  key: ENV['sessionkey'],
  domain:  ENV['domain'],
  path: '/',
  expire_after: 3600,
  secret: ENV['sessionsecret']

def get_order_total()
  order_total = 0.0

    if session[:cart]
      session[:cart].each do |item|
        order_total += item["total"]
      end
    end
  session[:ordertotal] = order_total
end

get '/' do
    @title = 'Shopping Cart'
    erb :index
end

get '/coolstuff' do
    @title = 'Shopping Cart'
    erb :coolstuff
end

post '/coolstuff' do
    @title = 'Shopping Cart'
    erb :product_details, :locals => {:product_info => product_info, :size_price => size_price}
end

post '/product_details' do
    url = params[ :url]
    
    size_price = db.exec("SELECT size, price FROM products2 WHERE product_url = '#{url}' ORDER BY size ASC  ")
    
    product_info = db.exec("SELECT product_name, product_description, order_information, product_url, personalization FROM products2 WHERE product_url = '#{url}' LIMIT 1")
    
    erb :product_details, :locals => {:product_info => product_info, :size_price => size_price}
end

get '/shop_cart' do
    @title = 'Shopping Cart'
    session[:cart] ? cart = session[:cart] : cart = []
    get_order_total()
     
    erb :shop_cart, :locals => {:cart => cart, :ordertotal => session[:ordertotal], :name => "",:price => "",
                                :quantity => "",:size => "",:line1 => "",:line2 => "",:line3 => "", :line4 => "", :url => ""}
end

post '/add_to_cart' do
    @title = 'Shopping Cart'
    
    session[:cart] ||= []
        session[:cart] ? cart = session[:cart] : cart = []

    name = params[:productName]
    description = params[:productDescription]
    url = params[:productURL]
    size = params[:size]
    quantity = params[:quantity].to_i
    price = params[:price].to_f
    line1 = params[:line1]
    line2 = params[:line2]
    line3 = params[:line3]
    line4 = params[:line4]
    total = quantity * price
        
    session[:cart].push({"productname" => name, "description" => description, "url" => url, "size" => size,
                         "quantity" => quantity, "price" => price,"total" => total, "line1" => line1,
                         "line2" => line2, "line3" => line3, "line4" => line4})

    erb :shop_cart, :locals => {:cart => cart, :ordertotal => session[:ordertotal], :name => name ,:price => price,
                                :quantity => quantity,:size => size,:line1 => line1,:line2 => line2,:line3 => line3,
                                :line4 => line4, :url => url}
end


post '/update_cart' do
    session[:cart].each_with_index do |shoppingcart_item, cart_index|
        #item_index = params[index].to_i
        i = cart_index.to_s.to_sym
        quantity = params[i].to_i
        price =session[:cart][cart_index]["price"]
        total = quantity * price
        session[:cart][cart_index]["quantity"] = quantity
        session[:cart][cart_index]["total"] = total
    end
    redirect '/shop_cart'
end

post '/remove_from_cart' do
    index = params[:index].to_i
    session[:cart].delete_at(index)
    redirect '/shop_cart'
end

get '/checkout1_prefilled' do
    @title = 'Checkout Step1'
    #"Session email is #{session[:email]}"
   #"Session cart is #{session[:cart]}"
   if session[:email] != nil
      customerinfo = db.exec("SELECT * FROM users WHERE email='#{session[:email]}'")
      erb :checkout1_prefilled, :locals => {:cart => session[:cart],:ordertotal => session[:ordertotal], 
                                            :customerinfo => customerinfo}

  else
      erb :checkout1_prefilled, :locals => {:cart => session[:cart],:ordertotal => session[:ordertotal]}

  end
end

get '/checkout2' do
    @title = 'Checkout Step2'
    erb :checkout2, :locals => {:cart => session[:cart],:ordertotal => session[:ordertotal]}
end

get '/checkout3' do
    @title = 'Checkout Step3'
    erb :checkout3, :locals => {:cart => session[:cart],:ordertotal => session[:ordertotal]}
end

get '/checkout4' do
    @title = 'Checkout Step4'
    session[:cart] = []
    erb :checkout4, :locals => {:cart => session[:cart],:ordertotal => session[:ordertotal],:delivery_method => delivery_method}
end

post '/checkout1' do
    @title = 'Checkout Step1'
    session[:customerinfo] ||= []
   
    
   erb :checkout1, :locals => {:cart => session[:cart],:ordertotal => session[:ordertotal],:customerinfo => customerinfo}

end
post '/checkout2' do
    @title = 'Checkout Step2'
    firstname = params[:firstname]
    lastname = params[:lastname]
    company = params[:company]
    street = params[:street]
    city = params[:city]
    state = params[:state]
    zip = params[:zip]
    phone=params[:phone]
    email = params[:email]
     session[:cart2] = []
     session[:cart2].push({"firstname" => firstname, "lastname" => lastname, "company" => company, "street" => street,
                           "city" => city , "state" => state, "zip" => zip, "phone" => phone, "email" => email})
     
    erb :checkout2,:locals => {:cart => session[:cart],:customerinfo => session[:customerinfo],
                               :ordertotal => session[:ordertotal],:cart2 => session[:cart2]}
  end



post '/checkout4' do
    @title = 'Checkout Step4'
    order_date = Time.now
    delivery_method = params[:delivery_method]
    payment_method = params[:payment_method]
    order_number = '2'
    delivery_method = params[:delivery_method]
    db.exec("INSERT INTO users(fname,lname,address,city,state,zipcode,phone,email) 
            VALUES ('#{session[:cart2][0]['firstname']}','#{session[:cart2][0]['lastname']}','#{session[:cart2][0]['street']}',
                    '#{session[:cart2][0]['city']}','#{session[:cart2][0]['state']}','#{session[:cart2][0]['zip']}',
                    '#{session[:cart2][0]['phone']}','#{session[:cart2][0]['email']}')")
       
      session[:cart].each do |m|

     
          db.exec ("INSERT INTO orders (product_name,quantity,line1,line2,line3,line4,unit_price,total_price,order_date,delivery_method,payment_method,order_number) 
                    VALUES ('#{m['productname']}','#{m['quantity']}','#{m['line1']}','#{m['line2']}','#{m['line3']}','#{m['line4']}',
                    '#{m['price']}','#{m['total']}','#{order_date}','#{delivery_method}','#{payment_method}','#{session[:cart2][0]['lastname']} #{order_date}')" )
      end
    erb :checkout4,:locals => {:cart => session[:cart],:cart2 => session[:cart2],:ordertotal => session[:ordertotal],:delivery_method => delivery_method}
end

get '/receipt' do
    @title = 'Receipt'
   
    erb :receipt,:locals => {:cart => session[:cart],:cart2 => session[:cart2],:ordertotal => session[:ordertotal],:message =>"Thanks for your order, here is a receipt you can print for your records."}
  
end

get '/paypal' do
session[:cart] ? cart = session[:cart] : cart = []
    get_order_total()
  erb :paypal, :locals => {:ordertotal => session[:ordertotal],:cart => cart}

end