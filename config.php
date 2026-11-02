<?php
// En producción, Render entrega DATABASE_URL como variable de entorno.
// En el computador local se usan estos valores de config.php.
$databaseUrl = getenv('DATABASE_URL');
if ($databaseUrl) {
    $parts = parse_url($databaseUrl);
    if (!$parts || empty($parts['host']) || empty($parts['path'])) {
        throw new RuntimeException('DATABASE_URL no tiene un formato válido.');
    }
    $dsn = 'pgsql:host=' . $parts['host']
        . ';port=' . ($parts['port'] ?? 5432)
        . ';dbname=' . ltrim($parts['path'], '/');
    parse_str($parts['query'] ?? '', $query);
    if (!empty($query['sslmode'])) {
        $dsn .= ';sslmode=' . preg_replace('/[^a-zA-Z0-9_-]/', '', $query['sslmode']);
    }
    return [
        'dsn' => $dsn,
        'user' => isset($parts['user']) ? rawurldecode($parts['user']) : '',
        'password' => isset($parts['pass']) ? rawurldecode($parts['pass']) : '',
    ];
}

return [
    'host' => getenv('DB_HOST') ?: '127.0.0.1',
    'port' => getenv('DB_PORT') ?: '5432',
    'dbname' => getenv('DB_NAME') ?: 'eps_villavicencio',
    'user' => getenv('DB_USER') ?: 'postgres',
    'password' => getenv('DB_PASSWORD') ?: '',
];
