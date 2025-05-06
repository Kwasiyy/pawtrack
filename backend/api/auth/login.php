// backend/api/auth/login.php
<?php
header('Content-Type: application/json');
require_once __DIR__ . '/../../config/database.php';

$body     = json_decode(file_get_contents('php://input'), true);
$email    = $body['email']    ?? '';
$password = $body['password'] ?? '';

$stmt = $pdo->prepare('SELECT id, password_hash FROM users WHERE email = ?');
$stmt->execute([$email]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password_hash'])) {
  http_response_code(401);
  echo json_encode(['message' => 'Invalid credentials']);
  exit;
}

session_start();
$_SESSION['user_id'] = $user['id'];
echo json_encode(['token' => session_id()]);
