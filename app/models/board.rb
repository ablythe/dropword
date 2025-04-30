class Board < ApplicationRecord
  belongs_to :game
  
  has_many :squares, dependent: :destroy

  after_create :create_squares


  def create_squares
    20.times do |y|
      10.times do |x|
        Square.create(x: x, y: y, board: self)
      end
    end
  end

  def rows 
    squares.each_slice(10).to_a
  end
end