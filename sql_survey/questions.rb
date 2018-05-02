require 'singleton'
require 'sqlite3'
require_relative "users.rb"
require_relative "questions.rb"

class QuestionsDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Question
  attr_accessor :id, :title, :body, :user_id
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
    Question.new(ids.first)
  end

  def self.find_by_title(title)
    questions = QuestionsDBConnection.instance.execute(<<-SQL,title)
      SELECT
        *
      FROM
        questions
      WHERE
        title = ?
    SQL
    return nil if questions.length == 0
    Question.new(questions.first)
  end

  def self.find_by_user_id(user_id)
    questions = QuestionsDBConnection.instance.execute(<<-SQL,user_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
    p questions
    return nil if questions.length == 0
    Question.new(questions.first)
  end

  def self.most_followed_questions(n)
    total = QuestionsDBConnection.instance.execute(<<-SQL,n)
    SELECT
      questions.id
    FROM
      questions
    JOIN
      questions_follows ON question.id = questions_follows.question_id
    ORDER BY
      COUNT(question_id) DESC
    LIMIT
      ?
    SQL
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def author
    User.find_by_id(@user_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def save
     if @id
       update
     else
       create
    end

  end
  def create
    QuestionsDBConnection.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO
        questions(title,body,user_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    QuestionsDBConnection.instance.execute(<<-SQL,@title, @body, @user_id,@id)
      UPDATE
        questions
      SET
        title = ?, body=?, user_id = ?
      WHERE
        id = ?
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def followers
    QuestionFollow.followers_for_questions(@id)
  end
  def likers
    QuestionLike.likers_for_question_id(@id)
  end
  def num_likes
    QuestionLike.likes_for_question_id(@id)
  end
end

# z=Question.new('title'=>'rdbms','body'=>'database','user_id'=>4)
# q = User.new('id'=> 4,'fname'=>'abi','lname'=>'anand')
# q.authored_questions
