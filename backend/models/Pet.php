<?php
class Pet {
    private $conn;
    private $table_name = "pets";

    public $id;
    public $user_id;
    public $name;
    public $breed;
    public $age;
    public $photo_url;
    public $created_at;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function create() {
        $query = "INSERT INTO " . $this->table_name . "
                (user_id, name, breed, age, photo_url, created_at)
                VALUES (:user_id, :name, :breed, :age, :photo_url, :created_at)";

        $stmt = $this->conn->prepare($query);

        $this->created_at = date('Y-m-d H:i:s');

        $stmt->bindParam(":user_id", $this->user_id);
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":breed", $this->breed);
        $stmt->bindParam(":age", $this->age);
        $stmt->bindParam(":photo_url", $this->photo_url);
        $stmt->bindParam(":created_at", $this->created_at);

        return $stmt->execute();
    }

    public function read($user_id) {
        $query = "SELECT * FROM " . $this->table_name . " WHERE user_id = :user_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":user_id", $user_id);
        $stmt->execute();
        return $stmt;
    }

    public function update() {
        $query = "UPDATE " . $this->table_name . "
                SET name = :name,
                    breed = :breed,
                    age = :age,
                    photo_url = :photo_url
                WHERE id = :id AND user_id = :user_id";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":breed", $this->breed);
        $stmt->bindParam(":age", $this->age);
        $stmt->bindParam(":photo_url", $this->photo_url);
        $stmt->bindParam(":id", $this->id);
        $stmt->bindParam(":user_id", $this->user_id);

        return $stmt->execute();
    }

    public function delete() {
        $query = "DELETE FROM " . $this->table_name . " WHERE id = :id AND user_id = :user_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $this->id);
        $stmt->bindParam(":user_id", $this->user_id);
        return $stmt->execute();
    }
}
