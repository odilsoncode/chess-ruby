require_relative 'setup'
require_relative 'player'
require_relative 'ai_computer_player'
require_relative 'chessboard'
require 'colorize'

class ChessGame
    attr_accessor :option
    def initialize
        @chessboard = ChessBoard.new
        @option = "1"
        @player_human_1 = nil
        @player_human_2 = nil
        @player_human_3 = nil
        @player_ai_1 = nil
        @player_ai_2 = nil
        @player_ai_3 = nil
    end

    def play(option = @option)
        @option = option
        if option == "1"
            human_vs_human
        elsif option == "2"
            human_vs_ai
        else
            ai_vs_ai
        end
    end

    def human_vs_human
        if @player_human_1.nil?
            puts "Player-1 What is your name?"
            name1 = gets.chomp
            @player_human_1 = Player.new(name1, "white")
    
            puts "Okay, #{@player_human_1.name}, the white pieces have been assigned to you"
        end
    
        if @player_human_2.nil?
            puts "Player-2 What is your name?"
            name2 = gets.chomp
            @player_human_2 = Player.new(name2, "black")
    
            puts "Okay, #{@player_human_2.name}, the black pieces have been assigned to you"
            setup(@chessboard)
        end
        
        current_player = @player_human_1
        do_break = false
        loop do
            @chessboard.display
            current_player.show_captured_piece
            puts "It's #{current_player.name}'s turn"
            puts "Choose the piece you want to move. eg(d1)"
            answer_1 = gets.chomp
            if answer_1 == "s"
                puts "What is the name to save your progress on?"
                name = gets.chomp
                file = open("chessgame_data/#{name}.txt", 'w')
                file.write Marshal.dump(self)
                file.close
                puts "Your progress has been saved!".light_green
                return
            elsif answer_1 == "q"
                puts "Are you sure that you want to qui?[y/n]"
                confirmation = gets.chomp
                if confirmation == "y"
                    puts "You quit the game".light_red
                    return
                end
            elsif answer_1.length != 2
                puts "Invalid input".light_red
                puts "Your position should be two characters length".light_blue
                sleep(3)
                redo
                
            elsif (("a".."h").to_a.include?(answer_1[0]) && ("1".."8").to_a.include?(answer_1[1]))
                array_index_positions = convert(answer_1)
                
                @chessboard.active_piece = @chessboard.data[array_index_positions[0]][array_index_positions[1]]
                
                if @chessboard.active_piece.nil?
                    puts "This square doesn't have any #{current_player.piece_color} piece \nPlease try again".light_blue
                    sleep(3)
                    redo
                elsif @chessboard.active_piece.color != current_player.piece_color
                    puts "WARNING, You can't move this piece".light_red
                    @chessboard.active_piece = nil
                    sleep(3)
                    redo
    
                elsif @chessboard.active_piece.allowed_moves.empty?
                    puts "You can't move this piece anywhere".light_blue
                    puts "Please choose another one".light_blue
                    sleep(3)
                    redo
    
                else    
                    @chessboard.display
                    puts "#{current_player.name}'s captured pieces:"
                    puts current_player.captured_pieces.map { |piece| piece.symbol }.join(" ").colorize(background: :cyan)
                    loop do
                        puts "Choose the position you want to move your piece to"
                        new_position = gets.chomp
                        if new_position == "s"
                            puts "What is the name to save your progress on?"
                            name = gets.chomp
                            file = open("chessgame_data/#{name}.txt", 'w')
                            file.write Marshal.dump(self)
                            file.close
                            puts "Your progress has been saved!".light_green
                            return
                        elsif new_position == "q"
                            puts "Are you sure that you want to qui?[y/n]"
                            confirmation = gets.chomp
                            if confirmation == "y"
                                puts "You quit the game".light_red
                                return
                            end
                        elsif new_position.length != 2
                            puts "Invalid input".light_red
                            puts "Your position should be two characters length".light_blue
                            redo
                        elsif (("a".."h").to_a.include?(new_position[0]) && ("1".."8").to_a.include?(new_position[1]))
                            array_indexes_of_new_positions = convert(new_position)
    
                            # Check if the position of the choosed piece is included inside the active_piece's attack_moves
                            if @chessboard.active_piece.attack_moves.include?(array_indexes_of_new_positions)
                                the_attacked_piece = @chessboard.data.dig(array_indexes_of_new_positions[0], array_indexes_of_new_positions[1])
    
                                if the_attacked_piece.class.name == "King"
                                    do_break = true 
                                    puts "CHECKMATE".light_green
                                    puts "Congratulations #{current_player.name}, you win!!!".light_green
                                    break
                                end
            
    
    
                                # Capture the enemy's piece
                                @chessboard.remove(the_attacked_piece)
                                the_attacked_piece.position = nil
                                current_player.captured_pieces << the_attacked_piece
    
                                #remove the active piece with old position
                                @chessboard.remove(@chessboard.active_piece)
    
                                # Add the active piece to the new position
                                @chessboard.active_piece.position = array_indexes_of_new_positions
                                @chessboard.add(@chessboard.active_piece)
                                @chessboard.active_piece = nil
                                
                                break
    
                            # Check if the position of the choosed piece is included inside the active_piece's allowed_moves
                            elsif @chessboard.active_piece.allowed_moves.include?(array_indexes_of_new_positions)
    
                                #remove the active piece with old position
                                @chessboard.remove(@chessboard.active_piece)
                                # Add the active piece with the new position
                                @chessboard.active_piece.position = array_indexes_of_new_positions
                                @chessboard.add(@chessboard.active_piece)
                                @chessboard.active_piece = nil
                                break
                            else
                                puts "WARNING, you can't move this piece there".light_red
                                sleep(3)
                                redo
                            end
                        else
                            puts "Invalid input".light_red
                            puts "Your position should be composed of a letter between 'a' and 'h' and a digit between '1' and '8'".light_blue
                            sleep(3)
                            redo
                        end
                    end
                end
            else
                puts "Your position should be composed of a letter between 'a' and 'h' and a digit between '1' and '8'".light_blue
                sleep(3)
                redo
                
            end
            break if do_break
            current_player == @player_human_1 ? current_player = @player_human_2 : current_player = @player_human_1
        end
    end


    def human_vs_ai
        if @player_human_3.nil?
            puts "Player-1 What is your name?"
            name1 = gets.chomp
            @player_human_3 = Player.new(name1, "white")
    
            @player_ai_3 = AI.new("Alexa", "black")
        
    
            puts "Okay, #{@player_human_3.name}, the white pieces have been assigned to you"
            
            sleep(3)
            puts "You'll be playing with a AI called 'Alexa', the black pieces have been assigned to her"
            puts "Good luck!!"
            sleep(6)
            
            setup(@chessboard)
        end
        
    
        current_player = @player_human_3
        do_break = false
        loop do
            @chessboard.display
            current_player.show_captured_piece
            puts "It's #{current_player.name}'s turn"
            puts "Choose the piece you want to move. eg(d1)"
            if current_player.class.name == "Player"
                answer_1 = gets.chomp
            else
                sleep(2)
                answer_1 = current_player.choose_a_piece_to_move(@chessboard)
            end

            if answer_1 == "s"
                puts "What is the name to save your progress on?"
                name = gets.chomp
                file = open("chessgame_data/#{name}.txt", 'w')
                file.write Marshal.dump(self)
                file.close
                puts "Your progress has been saved!".light_green
                return
            elsif answer_1 == "q"
                puts "Are you sure that you want to qui?[y/n]"
                confirmation = gets.chomp
                if confirmation == "y"
                    puts "You quit the game".light_red
                    return
                end
            
            elsif answer_1.length != 2
                puts "Invalid input".light_red
                puts "Your position should be two characters length".light_blue
                sleep(3)
                redo
                
            elsif (("a".."h").to_a.include?(answer_1[0]) && ("1".."8").to_a.include?(answer_1[1]))
                array_index_positions = convert(answer_1)
                
                @chessboard.active_piece = @chessboard.data[array_index_positions[0]][array_index_positions[1]]
                
                if @chessboard.active_piece.nil?
                    puts "This square doesn't have any #{current_player.piece_color} piece \nPlease try again".light_blue
                    sleep(3)
                    redo
                elsif @chessboard.active_piece.color != current_player.piece_color
                    puts "WARNING, You can't move this piece".light_red
                    @chessboard.active_piece = nil
                    sleep(3)
                    redo
                elsif @chessboard.active_piece.allowed_moves.empty?
                    puts "You can't move this piece anywhere".light_blue
                    puts "Please choose another one".light_blue
                    sleep(3)
                    redo
    
                else    
                    @chessboard.display
                    current_player.show_captured_piece
                    loop do
                        puts "Choose the position you want to move your piece to"
                        if current_player.class.name == "Player"
                            new_position = gets.chomp
                        else
                            sleep(3)
                            new_position = current_player.choose_a_position_to_move(@chessboard.active_piece)
                        end
                        if new_position == "s"
                            puts "What is the name to save your progress on?"
                            name = gets.chomp
                            file = open("chessgame_data/#{name}.txt", 'w')
                            file.write Marshal.dump(self)
                            file.close
                            puts "Your progress has been saved!".light_green
                            return
                        elsif new_position == "q"
                            puts "Are you sure that you want to qui?[y/n]"
                            confirmation = gets.chomp
                            if confirmation == "y"
                                puts "You quit the game".light_red
                                return
                            end
                        elsif new_position.length != 2
                            puts "Invalid input".light_red
                            puts "Your position should be two characters length".light_blue
                            redo
                        elsif (("a".."h").to_a.include?(new_position[0]) && ("1".."8").to_a.include?(new_position[1]))
                            array_indexes_of_new_positions = convert(new_position)
    
                            # Check if the position of the choosed piece is included inside the active_piece's attack_moves
                            if @chessboard.active_piece.attack_moves.include?(array_indexes_of_new_positions)
                                the_attacked_piece = @chessboard.data.dig(array_indexes_of_new_positions[0], array_indexes_of_new_positions[1])
    
                                if the_attacked_piece.class.name == "King"
                                    do_break = true 
                                    puts "CHECKMATE".light_green
                                    puts "Congratulations #{current_player.name}, you win!!!".light_green
                                    break
                                end
            
    
                                # Capture the enemy's piece
                                @chessboard.remove(the_attacked_piece)
                                the_attacked_piece.position = nil
                                current_player.captured_pieces << the_attacked_piece
    
                                #remove the active piece with old position
                                @chessboard.remove(@chessboard.active_piece)
    
                                # Add the active piece to the new position
                                @chessboard.active_piece.position = array_indexes_of_new_positions
                                @chessboard.add(@chessboard.active_piece)
                                @chessboard.active_piece = nil
                                
                                break
    
                            # Check if the position of the choosed piece is included inside the active_piece's allowed_moves
                            elsif @chessboard.active_piece.allowed_moves.include?(array_indexes_of_new_positions)
    
                                #remove the active piece with old position
                                @chessboard.remove(@chessboard.active_piece)
                                # Add the active piece with the new position
                                @chessboard.active_piece.position = array_indexes_of_new_positions
                                @chessboard.add(@chessboard.active_piece)
                                @chessboard.active_piece = nil
                                break
                            else
                                puts "WARNING, you can't move this piece there".light_red
                                sleep(3)
                                redo
                            end
                        else
                            puts "Invalid input".light_red
                            puts "Your position should be composed of a letter between 'a' and 'h' and a digit between '1' and '8'".light_blue
                            sleep(3)
                            redo
                        end
                    end
                end
            else
                puts "Your position should be composed of a letter between 'a' and 'h' and a digit between '1' and '8'".light_blue
                sleep(3)
                redo
                
            end
            break if do_break
            current_player == @player_human_3 ? current_player = @player_ai_3 : current_player = @player_human_3
        end
    end


    def ai_vs_ai
        
        if @player_ai_1.nil?
            @player_ai_1 = AI.new("Siri", "white")
            puts "Hello, my name is #{@player_ai_1.name}, and i'll play with the white pieces"
            sleep(3)
        end
        if @player_ai_2.nil?
            @player_ai_2 = AI.new("Alexa", "black")
        
            
            puts "Hello, my name is #{@player_ai_2.name}, and i'll play with the black pieces"
            sleep(3)
            setup(@chessboard)
            puts "Let's start playing chess right now".light_blue
        end
        
        current_player = @player_ai_1
        do_break = false
        loop do
            @chessboard.display
            current_player.show_captured_piece
            puts "It's #{current_player.name}'s turn"
            sleep(1)
            answer_1 = current_player.choose_a_piece_to_move(@chessboard)
    
            array_index_positions = convert(answer_1)
            @chessboard.active_piece = @chessboard.data[array_index_positions[0]][array_index_positions[1]]
            
         
            @chessboard.display
            current_player.show_captured_piece
            loop do
                new_position = current_player.choose_a_position_to_move(@chessboard.active_piece)
                sleep(1)
                array_indexes_of_new_positions = convert(new_position)
                # Check if the position of the choosed piece is included inside the active_piece's attack_moves
        
                if @chessboard.active_piece.attack_moves.include?(array_indexes_of_new_positions)
                    the_attacked_piece = @chessboard.data.dig(array_indexes_of_new_positions[0], array_indexes_of_new_positions[1])
    
                    if the_attacked_piece.class.name == "King"
                        do_break = true 
                        puts "CHECKMATE".light_green
                        puts "Congratulations #{current_player.name}, you win!!!".light_green
                        break
                    end
    
    
                    # Capture the enemy's piece
                    @chessboard.remove(the_attacked_piece)
                    the_attacked_piece.position = nil
                    current_player.captured_pieces << the_attacked_piece
    
                    #remove the active piece with old position
                    @chessboard.remove(@chessboard.active_piece)
    
                    # Add the active piece to the new position
                    @chessboard.active_piece.position = array_indexes_of_new_positions
                    @chessboard.add(@chessboard.active_piece)
                    @chessboard.active_piece = nil
                    
                    break
    
                # Check if the position of the choosed piece is included inside the active_piece's allowed_moves
                elsif @chessboard.active_piece.allowed_moves.include?(array_indexes_of_new_positions)
    
                    #remove the active piece with old position
                    @chessboard.remove(@chessboard.active_piece)
                    # Add the active piece with the new position
                    @chessboard.active_piece.position = array_indexes_of_new_positions
                    @chessboard.add(@chessboard.active_piece)
                    @chessboard.active_piece = nil
                    break
                else
                    puts "WARNING, you can't move this piece there".light_red
                    redo
                end
            end
           break if do_break
            current_player == @player_ai_1 ? current_player = @player_ai_2 : current_player = @player_ai_1
        end
    end


    # convert player inputs to arrays locgic
    def convert(input)
        input_array = input.split("")
        dict_alpha = {
            :a => 0,
            :b => 1,
            :c => 2,
            :d => 3,
            :e => 4,
            :f => 5,
            :g => 6,
            :h => 7
        }
        dict_digit = {
            1 => 7,
            2 => 6,
            3 => 5,
            4 => 4,
            5 => 3,
            6 => 2,
            7 => 1,
            8 => 0
        }
        return [dict_digit[input_array[1].to_i], dict_alpha[input_array[0].to_sym]]
        
    end

end

data = "chessgame_data"
Dir.mkdir(data) unless File.exist? data
