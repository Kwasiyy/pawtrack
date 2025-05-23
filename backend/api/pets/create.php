<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../../config/database.php';
include_once '../../models/Pet.php';

$database = new Database();
$db = $database->getConnection();

$pet = new Pet($db);

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->user_id) && !empty($data->name)) {
    $pet->user_id = $data->user_id;
    $pet->name = $data->name;
    $pet->breed = $data->breed;
    $pet->age = $data->age;
    $pet->photo_url = $data->photo_url;

    if ($pet->create()) {
        http_response_code(201);
        echo json_encode(array("message" => "Pet was created."));
    } else {
        http_response_code(503);
        echo json_encode(array("message" => "Unable to create pet."));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Unable to create pet. Data is incomplete."));
}
