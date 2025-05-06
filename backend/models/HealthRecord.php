<?php
class HealthRecord {
    private $conn;
    private $table_name = "health_records";

    public $id;
    public $pet_id;
    public $type;
    public $date;
    public $notes;
    public $created_at;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function create() {
        $query = "INSERT INTO " . $this->table_name . "
                (pet_id, type, date, notes, created_at)
                VALUES (:pet_id, :type, :date, :notes, :created_at)";

        $stmt = $this->conn->prepare($query);

        $this->created_at = date('Y-m-d H:i:s');

        $stmt->bindParam(":pet_id", $this->pet_id);
        $stmt->bindParam(":type", $this->type);
        $stmt->bindParam(":date", $this->date);
        $stmt->bindParam(":notes", $this->notes);
        $stmt->bindParam(":created_at", $this->created_at);

        return $stmt->execute();
    }

    public function readByPet($pet_id) {
        $query = "SELECT * FROM " . $this->table_name . " WHERE pet_id = :pet_id ORDER BY date DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":pet_id", $pet_id);
        $stmt->execute();
        return $stmt;
    }

    public function update() {
        $query = "UPDATE " . $this->table_name . "
                SET type = :type,
                    date = :date,
                    notes = :notes
                WHERE id = :id AND pet_id = :pet_id";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(":type", $this->type);
        $stmt->bindParam(":date", $this->date);
        $stmt->bindParam(":notes", $this->notes);
        $stmt->bindParam(":id", $this->id);
        $stmt->bindParam(":pet_id", $this->pet_id);

        return $stmt->execute();
    }

    public function delete() {
        $query = "DELETE FROM " . $this->table_name . " WHERE id = :id AND pet_id = :pet_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $this->id);
        $stmt->bindParam(":pet_id", $this->pet_id);
        return $stmt->execute();
    }
}
