class GamesController < ApplicationController
  def create
  end

  def update
  end

  def show
    @game = Game.find(params[:id])
  end

  def advance
    @game = Game.find(params[:id])
    case params[:move]
    when "down"
      @game.move_down
    when "left"
      @game.move_left
    when "right"
      @game.move_right
    when "rotate"
      @game.rotate
    else
      @game.auto_move
    end

    render partial: "games/board",  locals: { game: @game.reload }
  end

end
