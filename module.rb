module Database
    def connect()
        return SQLite3::Database.new("db/slutprojekt.db")
    end

    def get_group_info(user_id)
        db = connect()
        return db.execute("SELECT * FROM groups")
    end

    def get_members(group_id)
        db = connect()
        return db.execute("SELECT username FROM users WHERE user_id IN (SELECT user_id FROM user_group WHERE group_id = ?)", [group_id])
    end

    def get_username(user_id)
        db = connect()
        return db.execute("SELECT username FROM users WHERE user_id = ?", [user_id]).join
    end

    def get_user_id(username)
        db = connect()
        return db.execute("SELECT user_id FROM users WHERE username=?", [username])
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
        db.execute("INSERT INTO users (username, password) VALUES (?,?)", [username, password_digest])
    end

    def create_group(user_id, groupname)
        db = connect()
        db.execute("INSERT INTO groups (user_id, name) VALUES (?, ?)", [user_id, groupname])
        ids = db.execute("SELECT group_id FROM groups WHERE name = ? AND user_id = ?",[groupname,user_id])
        largest = 0
        ids.each do |id|
            if id[0] > largest
                largest = id[0]
            end
        end
        db.execute("INSERT INTO user_group (user_id, group_id) VALUES (?,?)", [user_id,largest])
    end

    def add_user(user_id, group_id)
        db = connect()
        db.execute("INSERT INTO user_group (user_id, group_id) VALUES (?,?)", [user_id,group_id])
    end

    def get_group_ids(user_id)
        db = connect()
        return db.execute("SELECT group_id FROM user_group WHERE user_id = ?", [user_id])
    end

    def get_all_usernames()
        db = connect()
        return db.execute("SELECT username FROM users")
    end
end