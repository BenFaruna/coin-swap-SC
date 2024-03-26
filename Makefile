-include .env

fork-testnet:
	@echo "Forking testnet..."
	@anvil --fork-url ${RPC_URL} --fork-block-number 5561880

test-fork:
	@echo "Testing fork..."
	@forge t --rpc-url ${LOCAL} --match-path test/CoinSwap.t.sol -vvvv

deploy-testnet:
	@echo "Deploying to testnet..."
	@forge script ./script/DeployCoinSwap.s.sol --rpc-url ${RPC_URL}  --broadcast --etherscan-api-key ${ETHERSCAN_KEY} --verifier-url ${RPC_URL} --verify -vvvvv 

verify-testnet:
	@echo "Verifying on testnet..."
	@forge verify-contract 0xC8F0B7ccEBBa68caeCE3Ced52C22578d94E590b7 CoinSwap --etherscan-api-key ${ETHERSCAN_KEY} --chain-id 11155111 --flatten