## Balance transfer go example demonstrating use of Go SDK

To use this repository follow following steps

1. In the "runTest.sh" script, insert the Go PATH at the very top before doing anything else
2. Start a terminal from root directory of the folder start the network by executing 
    docker-compose -f ./artifacts/docker-compose.yaml up
3. In another terminal window start the server from root directory of the folder by executing
    go run main.go
4. In another terminal, you can execute the test commands by executing  
    ./runTest.sh

For understanding and learning the Go SDK or Hyperledger, it helps to see logs for docker containers and see detailed output as commands are executed. You can also increase the "s" variable at the top of the runTest.sh script to allow more time in between transactions to help you read the logs.

Have fun!