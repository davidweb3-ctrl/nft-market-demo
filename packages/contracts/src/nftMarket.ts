import NFTMarketABI from "./abi/NFTMarket.json" assert { type: "json" };

export const nftMarketAbi = NFTMarketABI.abi as const;

export interface NFTMarketDeployment {
  address: `0x${string}`;
  chainId: number;
  collection: `0x${string}`;
}

export const nftMarketDeployments: NFTMarketDeployment[] = [
  {
    address: "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9",
    chainId: 31337,
    collection: "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0",
  },
];
