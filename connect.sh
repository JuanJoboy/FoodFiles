#!/usr/bin/expect -f

ip=10.130.4.250
pair_port1=46789
pair_code=009671
pair_port2=35369

# Spawn the pairing command
spawn adb pair $ip:$pair_port1

# Look for the pairing code prompt and send the code
expect "Enter pairing code:"
send "$pair_code\r"

# Wait for the process to finish
expect eof

# Execute the final connection command
exec adb connect $ip:$pair_port2