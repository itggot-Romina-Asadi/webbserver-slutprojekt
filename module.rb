module Database
    def connect()
        return SQLite3::Database.new("db/slutprojekt.db")
    end

    def get_groupname(user_id)
        db = connect()
        return db.execute("SELECT * FROM groups WHERE user_id=?", [user_id])
    end
end