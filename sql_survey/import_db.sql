CREATE TABLE users(
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE questions_follows(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  previous_reply_id INTEGER,
  body TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (previous_reply_id) REFERENCES replies(id)
);

CREATE TABLE questions_likes(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ("Meenakshi", "Anand"),
  ("Daniel", "Chen");


INSERT INTO
  questions(title, body, user_id)
VALUES
  ("aA", "How is aA?", (SELECT id FROM users WHERE fname ='Daniel')),
  ("sql", "How to work with queries in SQL?", (SELECT id FROM users WHERE fname ='Meenakshi'));

INSERT INTO
  questions_follows(question_id,user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'aA'), (SELECT id FROM users WHERE fname ='Meenakshi')),
  ((SELECT id FROM questions WHERE title = 'sql'), (SELECT id FROM users WHERE fname ='Daniel')),
  ((SELECT id FROM questions WHERE title = 'sql'), (SELECT id FROM users WHERE fname ='Meenakshi')),
  ((SELECT id FROM questions WHERE title = 'aA'), (SELECT id FROM users WHERE fname ='Daniel'));

INSERT INTO
  questions_likes(question_id,user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'aA'), (SELECT id FROM users WHERE fname ='Meenakshi')),
  ((SELECT id FROM questions WHERE title = 'sql'), (SELECT id FROM users WHERE fname ='Daniel')),
  ((SELECT id FROM questions WHERE title = 'sql'), (SELECT id FROM users WHERE fname ='Meenakshi')),
  ((SELECT id FROM questions WHERE title = 'aA'), (SELECT id FROM users WHERE fname ='Daniel'));

INSERT INTO
  replies(question_id,user_id,previous_reply_id,body)
VALUES
  ((SELECT id FROM questions WHERE title = 'aA'), (SELECT id FROM users WHERE fname ='Meenakshi'),null,"First reply"),
  ((SELECT id FROM questions WHERE title = 'sql'), (SELECT id FROM users WHERE fname ='Daniel'),null,"First reply"),
  ((SELECT id FROM questions WHERE title = 'sql'), (SELECT id FROM users WHERE fname ='Meenakshi'),2,"Second reply"),
  ((SELECT id FROM questions WHERE title = 'aA'), (SELECT id FROM users WHERE fname ='Daniel'),1,"Second reply");
