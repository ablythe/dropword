class Game < ApplicationRecord
  has_one :board, dependent: :destroy
  has_many :squares, through: :board
  belongs_to :word

  after_create :build_board

  SPEEDS = [ 1, 2, 4, 6, 8 ].freeze

  O = {
    positions: [ [ [ 0, 0 ], [ 0, 1 ], [ 1, 0 ], [ 1, 1 ] ] ],
    color: "blue"
  }.freeze

  T = {
    positions: [
      [ [ 1, 0 ], [ 0, 1 ], [ 1, 1 ], [ 2, 1 ] ],
      [ [ 1, 0 ], [ 1, 1 ], [ 2, 1 ], [ 1, 2 ] ],
      [ [ 0, 1 ], [ 1, 1 ], [ 2, 1 ], [ 1, 2 ] ],
      [ [ 1, 0 ], [ 0, 1 ], [ 1, 1 ], [ 1, 2 ] ]
    ],
    color: "yellow"
  }.freeze

  L = {
    positions: [
      [ [ 1, 0 ], [ 1, 1 ], [ 1, 2 ], [ 2, 2 ] ],
      [ [ 0, 1 ], [ 1, 1 ], [ 2, 1 ], [ 0, 2 ] ],
      [ [ 0, 0 ], [ 1, 0 ], [ 1, 1 ], [ 1, 2 ] ],
      [ [ 2, 0 ], [ 0, 1 ], [ 1, 1 ], [ 2, 1 ] ]
    ],
    color: "red"
  }.freeze

  J = {
    positions: [
      [ [ 1, 0 ], [ 1, 1 ], [ 1, 2 ], [ 0, 2 ] ],
      [ [ 0, 0 ], [ 0, 1 ], [ 1, 1 ], [ 2, 1 ] ],
      [ [ 1, 0 ], [ 2, 0 ], [ 1, 1 ], [ 1, 2 ] ],
      [ [ 0, 0 ], [ 1, 0 ], [ 2, 0 ], [ 2, 1 ] ]
    ],
    color: "orange"
  }.freeze

  I = {
    positions: [
      [ [ 1, 0 ], [ 1, 1 ], [ 1, 2 ], [ 1, 3 ] ],
      [ [ 0, 1 ], [ 1, 1 ], [ 2, 1 ], [ 3, 1 ] ]
    ],
    color: "green"
  }.freeze

  Z = {
    positions: [
      [ [ 1, 0 ], [ 1, 1 ], [ 0, 1 ], [ 0, 2 ] ],
      [ [ 0, 0 ], [ 1, 0 ], [ 1, 1 ], [ 2, 1 ] ]
    ],
    color: "purple"
  }.freeze

  S = {
    positions: [
      [ [ 0, 0 ], [ 0, 1 ], [ 1, 1 ], [ 1, 2 ] ],
      [ [ 1, 0 ], [ 2, 0 ], [ 0, 1 ], [ 1, 1 ] ]
    ],
    color: "aqua"
  }.freeze

  PIECES = {
    "O" => O,
    "T" => T,
    "L" => L,
    "J" => J,
    "I" => I,
    "Z" => Z,
    "S" => S
  }.freeze

  def pause
    self.update!(paused: true, last_move: DateTime.now())
  end

  def unpause
    self.update!(paused: false, last_move: DateTime.now())
  end

  def build_board
    Board.create(game: self)
  end

  def start
    update(paused: false, last_move: DateTime.now(), speed: 1)
  end

  def auto_move
    if paused || finished
      return
    end

    now = DateTime.now()
    time_elapsed = now.to_i - last_move.to_i
    move_down
    # if time_elapsed > 200 / SPEEDS[speed]
    #   move_down
    # end
  end

  def increase_speed
  end

  def decrease_speed
  end

  def undraw
    current_piece[:positions][piece_rotation].each do |coordinates|
      new_x = x + coordinates[0]
      new_y = y + coordinates[1]
      square = squares.find_by(x: new_x, y: new_y)
      square.update(filled: false, color: "gray")
    end
  end

  def update_board(x_offset: 0, y_offset: 0, moved: false)
   ex = x + x_offset
   why = y + y_offset
    current_piece[:positions][piece_rotation].each do |coordinates|
      new_x = ex + coordinates[0]
      new_y = why + coordinates[1]
      square = squares.find_by(x: new_x, y: new_y)
      return unless square
      square.filled = true
      square.color = current_piece[:color]
      square.save
    end

    if moved
      update(last_move: DateTime.now())
    end
    update(x: ex, y: why)
  end

  def set_piece
    current_piece[:positions][piece_rotation].each do |coordinates|
      new_x = x + coordinates[0]
      new_y = y + coordinates[1]
      square = squares.find_by(x: new_x, y: new_y)
      square.update(filled: true, color:  current_piece[:color])
    end
  end

  def clear_filled_lines
    y = 0
    lines_cleared = 0
    board.reload.rows.each do |line|
      if line.all? { |square| square.filled? }
        puts "LINE CLEARED"
        y2 = y
        while y2 > 0
          row = board.rows[y2 - 1].pluck(:filled, :color)
          board.rows[y2].each_with_index do |square, index|
            square.update(filled: row[index][0], color: row[index][1])
          end
          y2 -= 1
        end
        board.rows[0].each do |square|
          square.update(filled: false, color: "gray")
        end
        lines_cleared += 1
      end
      y += 1
    end

    if lines_cleared > 0
      points = calculate_score(lines_cleared)
      update(score: score + points)
    end
  end

  def calculate_score(lines_cleared)
    case lines_cleared
    when 1
      40
    when 2
      100
    when 3
      300
    else
      1200
    end
  end

  def get_next_piece
    pieces = %w[O T I L S Z J]
    index = rand(pieces.length).floor
    new_piece = pieces[index]
    self.update(piece: new_piece, piece_rotation: 0, x: 3, y: 0)
  end

  def check_over
    if board.rows[0].any? { |square| square.filled? }
      update(finished: true)
    end
  end

  def collision?(x, y, pce)
    pce.each do |coordinates|
      new_x = x + coordinates[0]
      new_y = y + coordinates[1]
      if new_y > 19
        return true
      end
      if new_x > (board.rows[0].length - 1)
        return true
      end
      if new_x < 0
        return true
      end

      square = squares.find_by(x: new_x, y: new_y)
      if square.filled?
        return true
      end
    end

    false
  end

  def move_right
    undraw
    if !collision?(x + 1, y, current_piece[:positions][piece_rotation])
      update_board(x_offset: 1)
    else
      update_board()
    end
  end

  def move_left
    undraw
    if !collision?(x - 1, y, current_piece[:positions][piece_rotation])
      update_board(x_offset: -1)
    else
      update_board()
    end
  end

  def move_down
    undraw
    if !collision?(x, y + 1, current_piece[:positions][piece_rotation])
      update_board(y_offset: 1, moved: true)
    else
      set_piece
      clear_filled_lines
      check_over
      if !finished
        get_next_piece
        update_board
      end
    end
  end

  def rotate
    new_piece_rotation = (piece_rotation + 1) % current_piece[:positions].length
    undraw()
    if collision?(x, y, current_piece[:positions][new_piece_rotation])
      update_board()
      return false
    end
    update(piece_rotation: new_piece_rotation)
    update_board()
  end

  private

  def current_piece
    PIECES[piece]
  end
end
