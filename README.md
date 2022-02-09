# CyberWay

#### Build
```
yarn
```

```
npx hardhat compile
```

#### Test
```
npx hardhat test
```

```
npx hardhat coverage
```

##### Flatten

```
npx hardhat flat --output flattener/{{contract_name}}.sol contracts/{{contract_name}}.sol
```

### Deploy
check CyberToken(ERC20) address in `CYBER_TOKEN` var
```
npx hardhat run deploy/deploy.js --network bsc
```
