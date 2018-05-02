require_relative 'questions'

class QuestionFollow
  attr_accessor :id, :question_id, :user_id

  def self.find_by_id(id)
    ids = QuestionsDBConnection.instance.execute(<<-SQL,id)
      SELECT
        *
      FROM
        questions_follows
      WHERE
        id = ?
    SQL
    return nil if ids.length == 0
    QuestionFollow.new(ids.first)
  end

  def self.find_by_user_id(user_id)
    user_ids = QuestionsDBConnection.instance.execute(<<-SQL,user_id)
      SELECT
        *
      FROM
        questions_follows
      WHERE
        user_id = ?
    SQL
    return nil if user_ids.length == 0
    QuestionFollow.new(user_ids.first)
  end

  def self.find_by_question_id(question_id)
    question_ids = QuestionsDBConnection.instance.execute(<<-SQL,question_id)
      SELECT
        *
      FROM
        questions_follows
      WHERE
        question_id = ?
    SQL
    return nil if question_ids.length == 0
    QuestionFollow.new(question_ids.first)
  end

  def self.followers_for_questions(question_id)
    users = QuestionsDBConnection.instance.execute(<<-SQL,question_id)
      SELECT
      users.fname,users.lname,users.id
      FROM
      users
      JOIN
      questions_follows ON users.id = questions_follows.user_id
      JOIN
      questions ON questions.id = questions_follows.question_id
      WHERE
      question_id = ?
    SQL
  end

  def self.followed_for_user_id(user_id)
    users = QuestionsDBConnection.instance.execute(<<-SQL,user_id)
      SELECT
      *
      FROM
      questions
      JOIN
      questions_follows ON questions.user_id= questions_follows.user_id
      WHERE
      questions.user_id = ?
    SQL
  end

  def self.most_followed_questions(n)
    total = QuestionsDBConnection.instance.execute(<<-SQL,n)
    SELECT
      DISTINCT(questions.id)
    FROM
      questions
    JOIN
      questions_follows ON questions.id = questions_follows.question_id
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
        questions_follows(question_id, user_id)
      VALUES
        (?, ?)
    SQL
      @id = QuestionsDBConnection.instance.last_insert_row_id
  end

end
