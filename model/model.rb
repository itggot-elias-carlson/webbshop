module TodoDB
    DB_PATH = 'db/webbshop.sqlite'

    def db_connect
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true
        return db
    end

    def get_user username
        db = db_connect()
        result = db.execute("SELECT * FROM users WHERE name=?", [username])
        return result.first
    end

    def create_user username, password
        db = db_connect()
        password_digest = BCrypt::Password.create(password)
        db.execute("INSERT INTO users(name, password) VALUES (?,?)", [username, password_digest])
    end

    def get_articles
        db = db_connect()
        db.results_as_hash = false

        result = db.execute("SELECT * FROM articles")
        return result
    end

    def get_carts user_id
        db = db_connect()
        db.results_as_hash = false

        result = db.execute("SELECT * FROM carts WHERE user_id=?", [user_id])

        i = 0
        articles = []
        article_name = ""
        result.length.times do
            article_name = db.execute("SELECT name FROM articles WHERE id=?", result[i][4])
            article_name = article_name[0][0]
            articles << article_name
            i += 1
        end
        return result, articles
    end
end