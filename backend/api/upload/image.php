<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_FILES['image']) {
    $target_dir = "../../uploads/";
    $file = $_FILES['image'];
    $file_name = uniqid() . '_' . basename($file["name"]);
    $target_file = $target_dir . $file_name;
    
    if (move_uploaded_file($file["tmp_name"], $target_file)) {
        http_response_code(201);
        echo json_encode(array(
            "message" => "Image uploaded successfully.",
            "url" => "/uploads/" . $file_name
        ));
    } else {
        http_response_code(503);
        echo json_encode(array("message" => "Failed to upload image."));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "No image file provided."));
}
