<?php
class Walk {
    private $conn;
    private $table_name = "walks";

    public $id;
    public $pet_id;
    public $start_time;
    public $end_time;
    public $distance;
    public $start_location;
    public $end_location;
    public $created_at;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function create() {
        $query = "INSERT INTO " . $this->table_name . "
                (pet_id, start_time, end_time, distance, start_location, end_location, created_at)
                VALUES (:pet_id, :start_time, :end_time, :distance, :start_location, :end_location, :created_at)";

        $stmt = $this->conn->prepare($query);

        $this->created_at = date('Y-m-d H:i:s');

        $stmt->bindParam(":pet_id", $this->pet_id);
        $stmt->bindParam(":start_time", $this->start_time);
        $stmt->bindParam(":end_time", $this->end_time);
        $stmt->bindParam(":distance", $this->distance);
        $stmt->bindParam(":start_location", $this->start_location);
        $stmt->bindParam(":end_location", $this->end_location);
        $stmt->bindParam(":created_at", $this->created_at);

        return $stmt->execute();
    }

    public function readByPet($pet_id) {
        $query = "SELECT * FROM " . $this->table_name . " WHERE pet_id = :pet_id ORDER BY start_time DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":pet_id", $pet_id);
        $stmt->execute();
        return $stmt;
    }
}
