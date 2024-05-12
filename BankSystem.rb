module My_Logger
    def self.log_info(timestamp, message)
        log(timestamp, 'info', message)
    end

    def self.log_warning(timestamp, message)
        log(timestamp, 'warning', message)
    end

    def self.log_error(timestamp, message)
        log(timestamp, 'error', message)
    end

    def self.log(timestamp, log_type, message)
        File.open('app.log','a') do |file|
            file.puts "#{timestamp} -- #{log_type} -- #{message}"
        end
    end
end

  class User
    attr_accessor :name, :balance

    def initialize(name, balance)
      @name = name
      @balance = balance
    end
  end

  class Transaction
    attr_reader :user, :value

    def initialize(user, value)
      @user = user
      @value = value
    end
  end

  class Bank
    def initialize()
      raise "#{self.class} is abstract" if self.class == Bank
    end
    
    def process_transactions (t_array, &callback)
        raise "Method #{__method__} is abstract, please override this method"
    end
  end

  class CBABank < Bank
    include My_Logger
    attr_accessor :bank_users

    def initialize(users)
        @bank_users=users
      end

    def process_transactions (t_array, &callback)
        message = ''

        t_array.each do |transaction|
            message << "User #{transaction.user.name} transaction with value #{transaction.value}, "
        end

        My_Logger.log_info(Time.now, "Processing Transactions #{message}...")

        t_array.each do |transaction|
            if(@bank_users.include?(transaction.user))
                new_balance = transaction.user.balance + transaction.value;
                transaction.user.balance = new_balance

                if(new_balance<0)  
                    raise "Not enough balance"              
                elsif(new_balance==0)
                    My_Logger.log_warning(Time.now, "#{transaction.user.name} has 0 balance")  
                    callback.call('success',transaction)    
                else
                    My_Logger.log_info(Time.now, "User #{transaction.user.name} transaction with value #{transaction.value} succeeded")
                    callback.call('success',transaction)                    
                end
            else
                raise "#{transaction.user.name} not exist in the bank!!"                 
            end
          rescue => e
            My_Logger.log_error(Time.now,"User #{transaction.user.name} transaction with value #{transaction.value} failed with message #{e.message}")
            callback.call("failure", transaction)
        end

    end
  end

  
  users = [
    User.new("Ali", 200),
    User.new("Peter", 500),
    User.new("Manda", 100)
  ]
  
  out_side_bank_users = [
    User.new("Menna", 400),
  ]
  
  transactions = [
    Transaction.new(users[0], -20),
    Transaction.new(users[0], -30),
    Transaction.new(users[0], -50),
    Transaction.new(users[0], -100),
    Transaction.new(users[0], -100),
    Transaction.new(out_side_bank_users[0], -100)
  ]

  callback = ->(status, transaction) do
    case status
    when "success"
      puts "Call endpoint for success of User #{transaction.user.name} transaction with value #{transaction.value}"
    when "failure"
      reason = transaction.user.balance < 0 ? "Not enough balance" : "#{transaction.user.name} not exist in the bank!!"
      puts "Call endpoint for failure of User #{transaction.user.name} transaction with value #{transaction.value} with reason #{reason}"
    end
  end

  bank = CBABank.new(users)
  bank.process_transactions(transactions, &callback) 

 


