-include .env

fork-testnet:
	@echo "Forking testnet..."
	@anvil --fork-url ${RPC_URL} --fork-block-number 5561880

test-fork:
	@echo "Testing fork..."
	@forge t --rpc-url ${LOCAL} --match-path test/CoinSwap.t.sol -vvvv

deploy-testnet:
	@echo "Deploying to testnet..."
	@script ./script/DeployCoinSwap.s.sol --rpc-url ${RPC_URL}  --broadcast --etherscan-api-key ${ETHERSCAN_KEY} --verifier-url ${RPC_URL} --verify -vvvvv 