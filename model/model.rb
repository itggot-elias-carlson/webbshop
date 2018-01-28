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

    def add_to_cart article_id, user_id
        db = db_connect()
        db.results_as_hash = false

        test = db.execute("SELECT * FROM carts WHERE article_id = ? AND user_id = ?", [article_id, user_id])
        p test

        if test != []
            amount = db.execute("SELECT amount FROM carts WHERE id=?", test[0][0])[0][0]
            if amount == nil
                amount = 1
            else
                amount += 1
            end
            db.execute("UPDATE carts SET amount =? WHERE id =?", [amount, test[0][0]])
        else
            db.execute("INSERT INTO carts(article_id, user_id) VALUES (?,?)", [article_id, user_id])
            result = db.execute("SELECT MAX(id) FROM carts")
            result = result[0][0]
            amount = db.execute("SELECT amount FROM carts WHERE id=?", result)[0][0]
            if amount == nil
                amount = 1
            else
                amount += 1
            end
            db.execute("UPDATE carts SET amount =? WHERE id =?", [amount, result])
        end
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
        article = ""
        result.length.times do
            article = db.execute("SELECT name, price FROM articles WHERE id=?", result[i][3])
            article = article[0]
            articles << article
            i += 1
        end
        return result, articles
    end
end