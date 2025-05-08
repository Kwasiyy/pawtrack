<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

if($db) {
    http_response_code(200);
    echo json_encode(array("message" => "Database connection successful"));
} else {
    http_response_code(503);
    echo json_encode(array("message" => "Unable to connect to the database"));
}
