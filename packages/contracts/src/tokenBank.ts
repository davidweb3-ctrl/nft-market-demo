import TokenBankABI from "./abi/TokenBank.json" assert { type: "json" };

export const tokenBankAbi = TokenBankABI.abi as const;

export interface TokenBankDeployment {
  address: `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512`;
  chainId: number;
}

export const deployments: TokenBankDeployment[] = [
  { address: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512", chainId: 31337 }
];
