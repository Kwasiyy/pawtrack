// backend/api/auth/register.php
<?php
header('Content-Type: application/json');
require_once __DIR__ . '/../../config/database.php';

$body     = json_decode(file_get_contents('php://input'), true);
$name     = $body['name']     ?? '';
$email    = $body['email']    ?? '';
$password = $body['password'] ?? '';

// hash the password
$hash = password_hash($password, PASSWORD_BCRYPT);

try {
  $stmt = $pdo->prepare('INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)');
  $stmt->execute([$name, $email, $hash]);

  session_start();
  $_SESSION['user_id'] = $pdo->lastInsertId();

  echo json_encode(['token' => session_id()]);
} catch (PDOException $e) {
  http_response_code(400);
  echo json_encode(['message' => 'Registration failed: ' . $e->getMessage()]);
}
