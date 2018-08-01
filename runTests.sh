#bin/bash
# run this script to test REST API
# set up variables for use
s=1
echo $(export GOPATH="Insert Path here")

#set chaincode version here --> increment this if you have made any changes to chaincode
ccVersion="v4"
cat ./utils/welcome
cat ./utils/start
echo -e "\033[33;33mStarting Hyperledger Network Example.... \033[0m"
sleep 5

#POST request or Enroll on Org1
echo -e "\033[33;33mPOST request for Enroll on Org1 \033[0m"
ORG1_TOKEN=$(curl -s -X POST http://localhost:4000/users -H "content-type: application/x-www-form-urlencoded" -d 'username=John&orgName=org1&secret=thisismysecret')
ORG1_TOKEN=$(echo $ORG1_TOKEN | jq ".Token" | sed "s/\"//g")
echo $ORG1_TOKEN
echo $'\n'
sleep $s

#POST request or Enroll on Org2
echo -e "\033[33;33mPOST request for Enroll on Org2 \033[0m"

ORG2_TOKEN=$(curl -s -X POST http://localhost:4000/users -H "content-type: application/x-www-form-urlencoded" -d 'username=Jeff&orgName=org2&secret=thisismysecret')
ORG2_TOKEN=$(echo $ORG2_TOKEN | jq ".Token" | sed "s/\"//g")
echo $ORG2_TOKEN
echo $'\n'
sleep $s

#POST request to Create Channel
echo -e "\033[33;33mPOST request to Create Channel \033[0m" 
echo "channel creation takes time so wait for it!"
curl -s -X POST http://localhost:4000/channels -H "content-type: application/json" \
 -H "Authorization: $ORG1_TOKEN" \
 -d '{
     "channelName":"mychannel", 
     "channelConfigPath":"./artifacts/channel/channel.tx"
     }'
sleep 5

#POST request: Org-1 joining channel
echo $'\n'
echo -e "\033[33;33mPOST request: Org-1 joining channel \033[0m" 
curl -s -X POST http://localhost:4000/channels/mychannel \
    -H "Authorization: $ORG1_TOKEN" \
    -H "content-type: application/json" \
    -d '{
        "peers": ["peer0.org1.example.com",
        "peer1.org1.example.com"]
        }'
echo $'\n'
sleep $s

#POST request: Org-2 joining channel
echo -e "\033[33;33mPOST request: Org-2 joining channel \033[0m" 
curl -s -X POST http://localhost:4000/channels/mychannel \
    -H "Authorization: $ORG2_TOKEN" \
    -H "content-type: application/json" \
    -d '{
        "peers": ["peer0.org2.example.com",
        "peer1.org2.example.com"]
        }'
echo $'\n'
sleep $s

# Install Chain Code on peers at Org1
echo -e "\033[33;33mInstall Chaincode on peers at Org1 \033[0m" 
curl -s -X POST http://localhost:4000/chaincodes \
    -H "authorization: $ORG1_TOKEN" \
    -H "content-type: application/json" \
    -d '{
        "peers": ["peer0.org1.example.com","peer1.org1.example.com"],
        "chaincodeName":"mycc",
        "chaincodePath":"github.com/balance-transfer-go/chaincode/chaincode_example02/go",
        "chaincodeType": "golang",
        "chaincodeVersion":"'$ccVersion'"
        }'
echo $'\n'
sleep $s

# Install Chain Code on peers at Org2
echo -e "\033[33;33mInstall Chaincode on peers at Org1 \033[0m" 
curl -s -X POST http://localhost:4000/chaincodes \
    -H "authorization: $ORG2_TOKEN" \
    -H "content-type: application/json" \
    -d '{
        "peers": ["peer0.org2.example.com","peer1.org2.example.com"],
        "chaincodeName":"mycc",
        "chaincodePath":"github.com/balance-transfer-go/chaincode/chaincode_example02/go",
        "chaincodeType": "golang",
        "chaincodeVersion":"'$ccVersion'"
        }'
echo $'\n'
sleep $s

#Instantiate Chaincode
echo -e "\033[33;33mInstantiating chaincode on the channel \033[0m" 
curl -s -X POST http://localhost:4000/channels/mychannel/instantiate \
    -H "authorization: $ORG1_TOKEN" \
    -H "content-type: application/json" \
    -d '{
        "peers": ["peer0.org1.example.com","peer1.org1.example.com"],
        "chaincodeName":"mycc",
        "chaincodeVersion":"'$ccVersion'",
        "chaincodeType": "golang", 
        "args": [ "Init", "John","400" ],
        "chaincodePath":"github.com/balance-transfer-go/chaincode/chaincode_example02/go"
        }'
echo $'\n'
sleep $s


#Invoke chaincode
echo -e "\033[33;33mInvoking chaincode 'Add function' on the channel \033[0m" 
curl -s -X POST  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"fcn":"add",
	"args":["Jeff","500"]
}'
echo $'\n'
sleep $s

#Invoke chaincode
echo -e "\033[33;33mInvoking chaincode 'Move function' to move 10 from John to Jeff \033[0m" 
curl -s -X POST  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"fcn":"move",
	"args":["John","Jeff","10"]
}'
echo $'\n'
sleep $s

#Query chaincode
echo -e "\033[33;33mQuering chaincode for current balances of John \033[0m" 
curl -s -X GET  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peer": "peer0.org2.example.com",
	"fcn":"query",
	"args":[ "John" ]
}'
echo $'\n'
sleep $s

#Query chaincode
echo -e "\033[33;33mQuering chaincode for current balances of Jeff \033[0m" 
curl -s -X GET  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peer": "peer0.org2.example.com",
	"fcn":"query",
	"args":[ "Jeff" ]
}'
echo $'\n'
sleep $s