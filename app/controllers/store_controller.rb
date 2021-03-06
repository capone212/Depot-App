class StoreController < ApplicationController
  before_filter :find_cart , :except => :empty_cart  

  def paypal_url(return_url)
    values = {
      :business =>  'sidpig_1278847745_biz@hotmail.com' ,
      :cmd => '_cart' ,
      :upload => 1 ,
      :return => return_url ,
      :invoice => id 
    }
    cart_items.each_with_index do |item ,index| 
      values.merge!({
        "amount_#{index+1}" => item.unit_price ,
        "item_name_#{index+1}" => item.product.name ,
        "item_number_#{index+1}" => item.id ,
        "quantity_#{index+1}" => item.quantity 
      })
    end
    "https://www.sandbox.paypal.com/cgi-bin/webscr?"+values.map {|k,v| "#{k}=#{v}"}.join("&")
  end  
   

  def index
     @products=Product.find_products_for_sale
   #  @cart = find_cart
  end

  def add_to_cart
     product = Product.find(params[:id])
    # @cart = find_cart
     @current_item = @cart.add_product(product)
     respond_to do |format|
       format.js if request.xhr?
       format.html  { redirect_to_index }
     end
     rescue ActiveRecord::RecordNotFound
     logger.error("Attempt to access invalid product #{params[:id]}")
     redirect_to_index("Invalid Product")
  end
     
  def empty_cart
    session[:cart]=nil
    redirect_to_index
  end
  
  def redirect_to_index(msg=nil)
    flash[:notice]=msg
    redirect_to :action =>'index'
  end

  def checkout
    # @cart = find_cart
     if @cart.items.empty? 
        redirect_to_index("The cart is empty ")
    else 
       @order = Order.new
    end 
  end  


 def save_order 
   #@cart = find_cart
   @order = Order.new(params[:order])
   @order.add_line_items_from_cart(@cart)
   if @order.save 
       session[:cart] = nil 
       redirect_to_index("Thank you for your order")
   else 
   render :action => 'checkout'
  end
 end   



   
#private

  def find_cart
   @cart = (session[:cart] ||= Cart.new)   

# unless session[:cart]
    #   session[:cart] = Cart.new
    #end
    #session[:cart]
  end

  protected 
  
  def authorize 
  end  



end
