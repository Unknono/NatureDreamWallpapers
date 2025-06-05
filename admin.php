<?php
$PASSWORD = "Supercell15112005%"; // Change this!

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input_pass = $_POST['admin_pass'] ?? '';
    $action = $_POST['action'] ?? '';

    if ($input_pass !== $PASSWORD) {
        die("Incorrect password.");
    }

    $script_map = [
        "reboot" => "/var/www/html/src/bash/reboot_server.sh",
        "shutdown" => "/var/www/html/src/bash/shutdown_server.sh",
        "monitor" => "/var/www/html/src/bash/website_monitor.sh"
    ];

    if (!array_key_exists($action, $script_map)) {
        die("Invalid action.");
    }

    $script = escapeshellcmd($script_map[$action]);
    $output = shell_exec("sudo $script 2>&1");

    echo "<pre>Action '$action' triggered.<br>Output:\n$output</pre>";
    echo "<a href='admin.html'>Back to Admin Panel</a>";
} else {
    echo "Invalid request.";
}
?>