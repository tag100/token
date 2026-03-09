
<?php
// Verify environment requirements

echo "<h2>Railway PHP Environment Check</h2>";

echo "<p>PHP Version: " . phpversion() . "</p>";

if (function_exists('curl_version')) {
    $curl = curl_version();
    echo "<p>cURL Enabled: YES (version " . $curl['version'] . ")</p>";
} else {
    echo "<p>cURL Enabled: NO</p>";
}

echo "<p>.htaccess + mod_rewrite should be active.</p>";
?>
