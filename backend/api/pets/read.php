<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../config/database.php';
include_once '../../models/Pet.php';

$database = new Database();
$db = $database->getConnection();

$pet = new Pet($db);

$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : die();

$stmt = $pet->read($user_id);
$num = $stmt->rowCount();

if ($num > 0) {
    $pets_arr = array();
    $pets_arr["records"] = array();

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        extract($row);
        $pet_item = array(
            "id" => $id,
            "user_id" => $user_id,
            "name" => $name,
            "breed" => $breed,
            "age" => $age,
            "photo_url" => $photo_url,
            "created_at" => $created_at
        );
        array_push($pets_arr["records"], $pet_item);
    }

    http_response_code(200);
    echo json_encode($pets_arr);
} else {
    http_response_code(404);
    echo json_encode(array("message" => "No pets found."));
}
