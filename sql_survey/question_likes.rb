require_relative 'questions.rb'

class QuestionLike
  attr_accessor :id, :question_id, :user_id

  def self.find_by_id(id)
    ids = QuestionsDBConnection.instance.execute(<<-SQL,id)
      SELECT
        *
      FROM
        questions_likes
      WHERE
        id = ?
    SQL
    return nil if ids.length == 0
    QuestionLike.new(ids.first)
  end

  def self.find_by_user_id(user_id)
    user_ids = QuestionsDBConnection.instance.execute(<<-SQL,user_id)
      SELECT
        *
      FROM
        questions_likes
      WHERE
        user_id = ?
    SQL
    return nil if user_ids.length == 0
    QuestionLike.new(user_ids.first)
  end

  def self.find_by_question_id(question_id)
    question_ids = QuestionsDBConnection.instance.execute(<<-SQL,question_id)
      SELECT
        *
      FROM
        questions_likes
      WHERE
        question_id = ?
    SQL
    return nil if question_ids.length == 0
    QuestionLike.new(question_ids.first)
  end

  def self.likers_for_question_id(question_id)
    QuestionsDBConnection.instance.execute(<<-SQL,question_id)
      SELECT
      *
      FROM
        users
      JOIN
        questions_likes ON users.id = questions_likes.user_id
      JOIN
        questions ON questions.id =questions_likes.question_id
      WHERE
        questions.id = ?
    SQL
  end

  def self.num_likes_for_question_id(question_id)
    QuestionsDBConnection.instance.execute(<<-SQL,question_id)
      SELECT
        COUNT(users.fname) AS num_of_likes
      FROM
        users
      JOIN
        questions_likes ON users.id = questions_likes.user_id
      JOIN
        questions ON questions.id =questions_likes.question_id
      WHERE
        questions.id = ?
    SQL
  end

  def self.liked_question_user_id(user_id)
    QuestionsDBConnection.instance.execute(<<-SQL,user_id)
    SELECT DISTINCT
      *
    FROM
    questions
    JOIN
    questions_likes ON questions_likes.user_id =questions.user_id
    WHERE
    questions.user_id = ?
    SQL
  end
  def self.most_liked_questions(n)
    total = QuestionsDBConnection.instance.execute(<<-SQL,n)
    SELECT
      DISTINCT(questions.title)
    FROM
      questions
    JOIN
      questions_likes ON questions.id = questions_likes.question_id
    ORDER BY
      question_id DESC
    LIMIT
      ?
    SQL
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def create
    QuestionsDBConnection.instance.execute(<<-SQL, @question_id, @user_id)
      INSERT INTO
        questions_likes(question_id, user_id)
      VALUES
        (?, ?)
    SQL
      @id = QuestionsDBConnection.instance.last_insert_row_id
  end




end
