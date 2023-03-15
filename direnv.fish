set -gx PROTOSTAR_ACCOUNT_PRIVATE_KEY '0x4c855e9c76dafea1bca1da35175cb6835249163389d8115c3d368b75567c2a1'
set -gx ACCOUNT_ADDR '0x07eF16028fD5B4FbC4755b98e2892eA6437901a18aEC877a12a7df407FFA4284'

#set -gx CLASS_HASH '0x6549843e08f808e659bf71a5c922de88424c103687408f45dcf2bfaaa7143a'
#set -gx LATEST_DEPLOYMENT '0x046a9ddc7765b84053d60659e6b7281bcf641226c6b2d080e817cb9a52c146d1'

hlp_register deploy 'Deploy the contract'
function deploy
	set json (protostar deploy --network testnet --max-fee 3006769442910825 --account-address $ACCOUNT_ADDR $CLASS_HASH --json | head -n 1)
	#echo $json
	echo $json | jq '.'
	set -gx LATEST_DEPLOYMENT (echo $json | jq -r '.contract_address')
end

hlp_register declare 'declare'
function declare
	set json (protostar declare --network testnet ./build/main.json --max-fee auto --account-address $ACCOUNT_ADDR  --json | head -n 1)
	echo $json | jq '.'
	set -gx CLASS_HASH (echo $json | jq -r '.class_hash')
end

hlp_register invoke 'invoke'
function invoke
	#protostar invoke --contract-address $LATEST_DEPLOYMENT --function 'constructor' --network testnet --account-address $ACCOUNT_ADDR --max-fee auto
	protostar invoke --contract-address $LATEST_DEPLOYMENT --function 'invoke_advent' --network testnet --account-address $ACCOUNT_ADDR --max-fee auto --inputs $argv 
end

hlp_register runtest 'test'
function runtest
	protostar test ./tests

end
