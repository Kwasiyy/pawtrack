<?php
// backend/api/walks/create.php
header('Content-Type: application/json');
require_once __DIR__ . '/../../config/database.php';

// 1) Parse incoming JSON
$body = json_decode(file_get_contents('php://input'), true);
$petId    = $body['pet_id']         ?? null;
$start    = $body['start_time']     ?? null;
$end      = $body['end_time']       ?? null;
$distance = $body['distance']       ?? null;

// 2) Basic validation
if (!$petId || !$start || !$end || !is_numeric($distance)) {
  http_response_code(400);
  echo json_encode(['message' => 'Missing or invalid fields']);
  exit;
}

try {
  // 3) Insert into walks table (matches your schema)
  $stmt = $pdo->prepare('
    INSERT INTO walks (pet_id, start_time, end_time, distance)
    VALUES (?, ?, ?, ?)
  ');
  $stmt->execute([$petId, $start, $end, $distance]);

  // 4) Return the new walk’s ID
  $newId = $pdo->lastInsertId();
  echo json_encode(['id' => $newId]);
} catch (PDOException $e) {
  http_response_code(500);
  echo json_encode(['message' => 'Database error: ' . $e->getMessage()]);
}
