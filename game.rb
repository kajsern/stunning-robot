
class Game
  public
  def to_float(odds)
    string = odds.split("/")
    #some odds are represented as a single digit and not a fraction
    if string[1] != nil
      return string[0].to_f/string[1].to_f
    else
      return string[0].to_f
    end
  end
  
  def initialize(odds_1,odds_2,odds_3,name_1,name_2)
    @a_odds = to_float(odds_1)
    @b_odds = to_float(odds_2)
    @c_odds = to_float(odds_3)
    @comp_1 = name_1
    @comp_2 = name_2
    @a_text_odds = odds_1
    @b_text_odds = odds_2
    @c_text_odds = odds_3
    @potential = 0
    @A = 100
    @breakdown = ""
  end
  
  def to_print
    puts @comp_1
    puts @comp_2
    puts @a_text_odds
    puts @b_text_odds
    puts @c_text_odds
    puts ""
  end
  
  def success?
    test_1 = @a_odds-((@b_odds+@c_odds+2)/(@b_odds*@c_odds-1))>0
    test_2 = 1/(1+@a_odds) + 1/(1+@b_odds) + 1/(1+@c_odds) < 1
    if test_1 != test_2
      puts "BIG PROBLEM"
      self.to_print
      puts "return of test_1" + (@a_odds-((@b_odds+@c_odds+2)/(@b_odds*@c_odds-1))).to_s
      puts "return of test_2" + (1/@a_odds + 1/@b_odds + 1/@c_odds).to_s

    end
    return test_1
  end

  def find_integers_in(start, finish)
    integer = start.ceil
    all_ints=[]
    while integer<finish
      if integer.between?(start,finish)
        all_ints.push(integer)
      end
      integer += 1
    end
    return all_ints
  end
  
  def set_potential
    best_return = 0
    b_best = 0
    c_best = 0
    a_bet = @A
    b_bet_lower = a_bet*(@c_odds + 1)/(@b_odds*@c_odds - 1)
    b_bet_higher = a_bet*(@a_odds + 1)/(@b_odds + 1)
    c_bet_lower = 0
    c_bet_higher = 0
    b_integers = self.find_integers_in(b_bet_lower, b_bet_higher)

    #spanisdh teams somehow not calculated correctly
    
    #this is only a solution for first line. Need also check second ineq.

    b_integers.each do |b_step|

      c_bet_lower = (a_bet+b_step)/@c_odds
      c_bet_higher = (@b_odds*b_step - a_bet)
      c_integers = find_integers_in(c_bet_lower,c_bet_higher)
      c_integers.each do |c_step|

        if a_bet*@a_odds + b_step*@b_odds + c_step*@c_odds - 2*(a_bet + b_step + c_step) > best_return
          best_return = a_bet*@a_odds + b_step*@b_odds + c_step*@c_odds - 2*(a_bet + b_step + c_step)
          b_best = b_step
          c_best = c_step
        end
      end
    end
    @a_bet = a_bet
    @b_bet = b_best
    @c_bet = c_best
    @potential = best_return/(a_bet+b_best+c_best)
  end
  
  def get_potential
    return @potential
  end
  
  def bets_breakdown
    @breakdown += @comp_1.to_s + " vs. " + @comp_2.to_s + "</p>"
    
    @breakdown += "Bets:</br>"
    @breakdown += @a_bet.to_s + "</br>" + @b_bet.to_s + "</br>" + @c_bet.to_s + "</br></br>"
    @breakdown += "Odds: </br>"
    @breakdown +=  @a_text_odds + "</br>" + @b_text_odds + "</br>" + @c_text_odds + "</br></br>"
    @breakdown +=  @comp_1.to_s+" wins: Win " + (@a_bet*@a_odds).to_s + ", paid "+ (@b_bet+@c_bet).to_s + "</br>"
    @breakdown +=  "Draw: Win " + (@b_bet*@b_odds).to_s + ", paid "+ (@a_bet+@c_bet).to_s + "</br>"
    @breakdown +=  @comp_2.to_s+" wins: Win " + (@c_bet*@c_odds).to_s + ", paid "+ (@a_bet+@b_bet).to_s + "</br></br>"
    @breakdown +=  "Potential profit:" + "</br>" + (@potential*100).round(2).to_s + "%</br>"
    @breakdown += "Paid: </br>" + (@a_bet+@b_bet+@c_bet).to_s
    @breakdown +=  "</br></br></br><hr></br>"
    return @breakdown
  end
end
