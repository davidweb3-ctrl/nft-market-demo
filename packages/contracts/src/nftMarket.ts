import NFTMarketABI from "./abi/NFTMarket.json" assert { type: "json" };

export const nftMarketAbi = NFTMarketABI.abi as const;

export interface NFTMarketDeployment {
  address: `0x${string}`;
  chainId: number;
}

export const nftMarketDeployments: NFTMarketDeployment[] = [];
