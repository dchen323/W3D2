require_relative 'questions.rb'
require_relative 'users.rb'

class Reply
  attr_accessor :id, :question_id, :user_id, :previous_reply_id, :body

  def self.find_by_id(id)
    ids = QuestionsDBConnection.instance.execute(<<-SQL,id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil if ids.length == 0
    Reply.new(ids.first)
  end

  def self.find_by_user_id(user_id)
    user_ids = QuestionsDBConnection.instance.execute(<<-SQL,user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil if user_ids.length == 0
    Reply.new(user_ids.first)
  end

  def self.find_by_question_id(question_id)
    question_ids = QuestionsDBConnection.instance.execute(<<-SQL,question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil if question_ids.length == 0
    Reply.new(question_ids.first)
  end

  def self.find_by_previous_reply_id(previous_reply_id)
    previous_reply_ids = QuestionsDBConnection.instance.execute(<<-SQL,previous_reply_id)
      SELECT
        *
      FROM
        replies
      WHERE
        previous_reply_id = ?
    SQL
    return nil if previous_reply_ids.length == 0
    Reply.new(previous_reply_ids.first)
  end


  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
    @previous_reply_id = options['previous_reply_id']
    @body = options['body']
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    if @previous_reply_id.nil?
      return nil
    else
      Reply.find_by_id(@previous_reply_id)
    end
  end

  def child_replies
    Reply.find_by_previous_reply_id(@id)
  end

  def create
    QuestionsDBConnection.instance.execute(<<-SQL, @question_id, @user_id, @previous_reply_id, @body)
      INSERT INTO
        replies(question_id, user_id,previous_reply_id,body)
      VALUES
        (?, ?, ?, ?)
    SQL
      @id = QuestionsDBConnection.instance.last_insert_row_id
  end

end
