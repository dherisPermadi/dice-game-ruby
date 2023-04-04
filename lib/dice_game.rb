class DiceGame
  # default array of contents
  def self.data_clear
    @game_in_play = true
    @total_player, @total_dice = 0
    @evaluation_players = []
    @round = 1
  end

  def self.play_game(total_player, total_dice)
    @total_player = total_player.to_i
    @total_dice = total_dice.to_i

    # input validation
    if @total_player < 1 || @total_dice < 1
      puts "The value of Total Player or Total Dice is incorrect. The value must be more than 0!"
    else
      self.run_game
    end
  end

  def self.run_game
    return puts "Game Finish. Player #{@total_player} wins." if @total_player == 1

    # create array players
    players = [*0..@total_player - 1]

    #initialize evaluation_players
    players.each { |index| @evaluation_players[index] = { 'number' => index + 1, 'dice' => @total_dice, 'result' => [], 'new_result' => [], 'point' => 0, 'additional_dice' => 0 } }

    puts "Player = #{@total_player}, Dice = #{@total_dice}"
    # loop game rounds
    while @game_in_play == true do
      puts "==============================================="
      puts "Round #{@round}:"
      # generate each player dice
      @evaluation_players.each do |player|

        # skip if player has no dice
        if player['dice'] > 0
          #generate dice
          player['result'] = []
          player['new_result'] = []
          player['additional_dice'] = 0
          player['dice'].times { player['result'].push(rand(1..6)) }
        end

        puts "- Player ##{player['number']} (#{player['point']}) : #{player['result'].join(", ")}"
      end
      self.evaluation
      self.display_evaluation
      @round += 1
    end
    #find winner
    winner = @evaluation_players.sort_by{|player| -player['point'] }.first

    return puts "Game finish, Player #{winner['number']} wins."
  end

  def self.evaluation
    @evaluation_players.each do |player|
      # add point if got 6
      if player['result'].include?(6)
        player['point'] += player['result'].count(6)
        player['dice'] -= player['result'].count(6)
        player['result'].delete(6)
        player['new_result'].delete(6)
      end
        
      # stop playing
      if player['dice'] != 0 && player['result'].count == 0
        player['dice'] = 0
      end

      # move dice if has 1
      if player['result'].include?(1) && !self.one_left?
        self.move_dice(player['number'], player['result'].count(1))
        player['dice'] -= player['result'].count(1)
        player['result'].delete(1)
        player['new_result'].delete(1)
      end
    end
  end

  def self.display_evaluation
    puts "After Evaluation :"
    @evaluation_players.each do |player|
      player['dice'] += player['additional_dice']
      player['new_result'] = player['result']
      player['new_result'].fill(1, player['new_result'].size, player['additional_dice']) if player['dice'] > 0
      puts "- Player ##{player['number']} (#{player['point']}) : #{player['new_result'].join(", ")}"

      @game_in_play = false if self.one_left?
    end
  end

  def self.move_dice(old_player, total)
    next_player = (old_player == @total_player) ? 0 : old_player

    if @evaluation_players[next_player]['dice'] > 0
      @evaluation_players[next_player]['additional_dice'] = total
    else
      other_players = @evaluation_players.select {|player| player['dice'] > 0 && player['number'] > next_player && player['number'] != @total_player }
  
      @evaluation_players[other_players[0]['number'] - 1]['additional_dice'] = total if other_players.count > 0
    end
  end

  def self.one_left?
    @evaluation_players.select {|player| player['dice'] == 0}.count == @total_player - 1
  end
end

DiceGame.data_clear
puts "Input the total player :"
total_player = gets.chomp
puts "Input the total dice :"
total_dice = gets.chomp
DiceGame.play_game(total_player, total_dice)