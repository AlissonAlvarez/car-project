    <?php
    header("Access-Control-Allow-Origin: http://localhost:5173");
    header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type, Authorization");
    header("Access-Control-Allow-Credentials: true");

    $method = $_SERVER['REQUEST_METHOD'];
    $input = json_decode(file_get_contents("php://input"), true);

    // --- DEBUG: Ver qué datos llegan ---
    file_put_contents("php://stderr", print_r($input, true));

    $host = "localhost";
    $dbname = "alquiler_vehiculos";
    $user = "root";
    $pass = "";

    try {
        $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $user, $pass);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    } catch (PDOException $e) {
        echo json_encode(["success" => false, "error" => $e->getMessage()]);
        exit;
    }

    // Manejo de OPTIONS
    if ($method === "OPTIONS") {
        http_response_code(200);
        exit;
    }

    // GET: Mostrar todos los usuarios (debug)
    if ($method === "GET") {
        $stmt = $pdo->query("SELECT id_usuario, nombres, apellidos, email FROM Usuarios");
        $usuarios = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($usuarios ?: ["info" => "No hay usuarios registrados"]);
        exit;
    }

    // POST: Registro o Login
    if ($method === "POST") {
        // ----------------- Login -----------------
        if (isset($input['email']) && isset($input['contrasena']) && !isset($input['nombres'])) {
            $email = $input['email'];
            $password = $input['contrasena'];

            $stmt = $pdo->prepare("SELECT id_usuario, nombres, apellidos, email, contrasena FROM Usuarios WHERE email = :email");
            $stmt->execute(['email' => $email]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($user && password_verify($password, $user['contrasena'])) {
                unset($user['contrasena']);
                echo json_encode(["success" => true, "usuario" => $user]);
            } else {
                echo json_encode(["success" => false, "error" => "Email o contrasena incorrectos"]);
            }
            exit;
        }

        // ----------------- Registro -----------------
        if (isset($input['nombres'], $input['apellidos'], $input['email'], $input['contrasena'])) {
            $nombres = $input['nombres'];
            $apellidos = $input['apellidos'];
            $email = $input['email'];
            $contrasena = $input['contrasena'];

            if (!$nombres || !$apellidos || !$email || !$contrasena) {
                echo json_encode(["success" => false, "error" => "Todos los campos son obligatorios"]);
                exit;
            }

            $stmt = $pdo->prepare("SELECT id_usuario FROM Usuarios WHERE email = :email");
            $stmt->execute(['email' => $email]);
            if ($stmt->fetch()) {
                echo json_encode(["success" => false, "error" => "Email ya registrado"]);
                exit;
            }

            $hashedPassword = password_hash($contrasena, PASSWORD_DEFAULT);
            $id_rol_default = 1; // Cliente

            $stmt = $pdo->prepare("INSERT INTO Usuarios (nombres, apellidos, email, contrasena, id_rol) VALUES (:nombres, :apellidos, :email, :contrasena, :id_rol)");
            $stmt->execute([
                'nombres' => $nombres,
                'apellidos' => $apellidos,
                'email' => $email,
                'contrasena' => $hashedPassword,
                'id_rol' => $id_rol_default
            ]);

            $id_usuario = $pdo->lastInsertId();
            echo json_encode([
                "success" => true,
                "usuario" => [
                    "id_usuario" => $id_usuario,
                    "nombres" => $nombres,
                    "apellidos" => $apellidos,
                    "email" => $email
                ]
            ]);
            exit;
        }

        echo json_encode(["success" => false, "error" => "Datos inválidos"]);
        exit;
    }

    echo json_encode(["success" => false, "error" => "Método no soportado"]);
    ?>
