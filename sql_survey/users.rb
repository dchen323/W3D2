require_relative 'questions.rb'
require_relative 'replies.rb'

class User

  attr_accessor :fname, :lname, :id

  def self.find_by_id(id)
    ids = QuestionsDBConnection.instance.execute(<<-SQL,id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil if ids.length == 0
    User.new(ids.first)
  end

  def self.find_by_name(fname,lname)
    names = QuestionsDBConnection.instance.execute(<<-SQL,fname,lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil if names.length == 0
    User.new(names.first)
  end


  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_user_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def create
    QuestionsDBConnection.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users(fname,lname)
      VALUES
        (?, ?)
    SQL
      @id = QuestionsDBConnection.instance.last_insert_row_id
  end


  def followed_questions
    QuestionFollow.followed_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_question_user_id(@id)
  end

  def average_karma
    QuestionsDBConnection.instance.execute(<<-SQL, @id)
    SELECT
      questions.id , CAST(COUNT(questions_likes.id)AS FLOAT)/COUNT(questions.id) AS average_karma
    FROM
      questions
    LEFT OUTER JOIN
      questions_likes ON questions.id = questions_likes.question_id
    JOIN
      USERS ON questions.user_id = users.id
    WHERE
      users.id = ?
    SQL
  end
end
