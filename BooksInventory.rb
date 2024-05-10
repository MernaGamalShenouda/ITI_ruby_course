class Book
    attr_accessor :book_title, :author_name, :book_array
    attr_reader :isbn

    def initialize()
      @book_title = ''
      @author_name = ''
      @isbn = ''
      @more = 'yes'
    end

    def isbn= (isbn)
        if isbn == ''
          raise ArguementError.new("Must have an ISBN number")
        end
        @isbn = isbn
    end
    
    def ask
      puts 'Name of book'
      @book_title=gets.chomp
      puts 'Book ISBN'
      @isbn=gets.chomp
      puts 'Author of the book'
      @author_name=gets.chomp
      puts 'Do you want add more book'
      @more=gets.chomp.capitalize

      return {isbn:@isbn, book_title:@book_title, author_name:@author_name};
    end

    def more_book?
      @more == 'No'
    end
  
  end


  class Inventory
    attr_accessor :book_array

    def initialize()
        @book_array=[]
      end

      def answers_start
        books = Book.new()
        until books.more_book?
          myBook = books.ask
          add_arr(myBook)
        end
    
      end

      def add_arr(book)
        book_array << book
        book = book[:isbn] + ',' + book[:book_title] +',' + book[:author_name] + "\n" 
        File.open("Books.csv", 'a')  { |file| file.write(book) }
      end

      def addFromFile (array)
        @isbn=array[0]
        @book_title=array[1]
        @author_name=array[2]
        return {isbn:@isbn, book_title:@book_title, author_name:@author_name};
    end
  
      def book_list
        @book_array.each do |item|
          puts "ISBN: #{item[:isbn]}, Name: #{item[:book_title]}, Author: #{item[:author_name]}"
        end
      end

      def book_delete(d_isbn)
        @book_array.delete_if{|x| x[:isbn] == d_isbn}
        File.open("Books.csv", 'w')  { |file| file.write("isbn,title,author_name\n") }
        @book_array = @book_array.each do |book|
            book = book[:isbn] + ',' + book[:book_title] +',' + book[:author_name]
            File.open("Books.csv", 'a')  { |file| file.write(book) }
        end
      end

      def mainMenu

        while true
        puts "\n What would you like to do?
          1: List Books
          2: Add new book
          3: Remove book by ISBN
          4: End"
        
        case gets.strip
        when "1"
            book_list
        when "2"
            answers_start   
        when "3"
            puts 'Enter the ISBN of the book you want to delete'
            d_isbn=gets.chomp
            book_delete(d_isbn)
            puts "Book of ISBN #{d_isbn} Deleted Successfully"
        else
          break
        end
      end
    end

    end

      inventory = Inventory.new()

      File.open("Books.csv") do |file|
        inventory.book_array << file.drop(1)
        .map { |line| {isbn:line.split(',')[0], book_title:line.split(',')[1], author_name:line.split(',')[2]}}
      end
    
    inventory.book_array = inventory.book_array[0];
    inventory.addFromFile(inventory.book_array)
    inventory.mainMenu


