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

    def get_account_type user_id
        db = db_connect()

        user = db.execute("SELECT account_type FROM users WHERE id=?", [user_id])[0][0]
    end

    def create_user username, password
        db = db_connect()
        password_digest = BCrypt::Password.create(password)
        db.execute("INSERT INTO users(name, password) VALUES (?,?)", [username, password_digest])
    end

    def add_to_cart article_id, user_id
        db = db_connect()
        db.results_as_hash = false

        existing = db.execute("SELECT * FROM carts WHERE article_id = ? AND user_id = ?", [article_id, user_id])

        if existing != []
            amount = db.execute("SELECT amount FROM carts WHERE id=?", existing[0][0])[0][0]
            if amount == nil
                amount = 1
            else
                amount += 1
            end
            db.execute("UPDATE carts SET amount =? WHERE id =?", [amount, existing[0][0]])
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

    def remove_from_cart article_id, user_id
        db = db_connect() 
        db.results_as_hash = false
        
        amount = db.execute("SELECT amount FROM carts WHERE article_id = ? AND user_id = ?", [article_id, user_id]) 
        amount = amount[0][0]
        if amount != 0  
            amount -=1
            db.execute("UPDATE carts SET amount=? WHERE user_id=? AND article_id=?", [amount, user_id, article_id])
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

    def add_article(name, price, description, type)
        db = db_connect()
        db.execute("INSERT INTO articles(name, price, description, type) VALUES (?,?,?,?)", [name, price, description, type])
    end

    def change_article(id, name, price, description, type)
        db = db_connect()
        db.execute("UPDATE articles SET name=?, price=?, description=?, type=? WHERE id=?", [name, price, description, type, id])
    end

    def remove_article(id)
        db = db_connect()       
        db.execute("DELETE FROM articles WHERE id=?", [id])
    end
end