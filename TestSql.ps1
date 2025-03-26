param(
    $sqlUsername,
    $sqlPassword,
    $sqlServerName,
    $resourceGroupName,
    $SqlServerIp,
    $fqdn    
)


$fqdnToIp = ([System.Net.Dns]::GetHostAddresses($fqdn) | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -First 1) | select -ExpandProperty IPAddressToString

$localIps =  (([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() | Where-Object { $_.OperationalStatus -eq 'Up' } | ForEach-Object { $_.GetIPProperties().UnicastAddresses } | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and $_.Address.IPAddressToString -ne '127.0.0.1' }) | %{$_.Address.IPAddressToString}) -join ', '

# Define the connection string
$connectionString = "Server=tcp:$fqdn,1433;Initial Catalog=master;Persist Security Info=False;User ID=$sqlUsername;Password=$sqlPassword;MultipleActiveResultSets=False;Encrypt=true;TrustServerCertificate=True;Connection Timeout=30;"
#$connectionString = "Server=tcp:$SqlServerIp,1433;Initial Catalog=dev-db;Persist Security Info=False;User ID=$sqlUsername;Password='$sqlPassword';MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"
# DevSqlAdmin@dev-SQL-64apk66jntkng
# Load the .NET SQL client library
Add-Type -AssemblyName "System.Data"


$message = "FQDN: $fqdn`nfqdnToIp: $fqdnToIp`nResource Group: $resourceGroup`nAgent IP(s): $localIps`nPing to $SqlServerIp is $(Test-Connection $fqdn -Count 1 -Quiet)`nServerUsername: $sqlUsername`nSqlPassword: $sqlPassword"

# Create a new SQL connection
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

try {
    # Open the SQL connection
    $connection.Open()
    Write-Output "Connection successful!"

    # Define a SQL command to execute (e.g., get server version)
    $sqlCommand = $connection.CreateCommand()
    $sqlCommand.CommandText = "SELECT @@VERSION as ServerVersion;"

    # Execute the SQL command
    $reader = $sqlCommand.ExecuteReader()

    # Display the results
    while ($reader.Read()) {
        Write-output "SQL Server Version:" $reader["ServerVersion"]
    }

    # Close the data reader
    $reader.Close()
} catch {
    Write-Output "$message`n An error occurred: $($_.Exception.Message)"
} finally {
    # Close the SQL connection
    $connection.Close()
    Write-Output "All OK. Connection closed."
}

# removing script
# $path = $MyInvocation.MyCommand.Path
# Start-Sleep -Seconds 2  # Give the script time to exit
# Remove-Item $path # Script removes itself
