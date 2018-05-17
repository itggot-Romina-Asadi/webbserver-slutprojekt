module Database
    def connect()
        return SQLite3::Database.new("db/slutprojekt.db")
    end

    def get_groupname(user_id)
        db = connect()
        return db.execute("SELECT * FROM groups WHERE user_id=?", [user_id])
    end

    def get_members(group_id)
        db = connect()
        return db.execute("SELECT username FROM users WHERE user_id IN (SELECT user_id FROM groups WHERE group_id = ?)", [group_id])
    end

    def get_username(user_id)
        db = connect()
        return db.execute("SELECT username FROM users WHERE user_id = ?", [user_id]).join
    end

    def get_user_id(username)
        db = connect()
        return db.execute("SELECT user_id FROM users WHERE username='#{username}'")
    end

    def get_password(username)
        db = connect()
        return db.execute("SELECT password FROM users WHERE username='#{username}'").join
    end

    def get_usernames(username)
        db = connect()
        return db.execute("SELECT username FROM users")
    end

    def create_user(username, password_digest)
        db = connect()
        return db.execute("INSERT INTO users (username, password) VALUES (?,?)", [username, password_digest])
    end

    def create_group(user_id, groupname)
        db = connect()
        return db.execute("INSERT INTO groups (user_id, name) VALUES (?, ?)", [user_id, groupname])
    end
end