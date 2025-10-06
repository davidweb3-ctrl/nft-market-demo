import NFTMarketABI from "./abi/NFTMarket.json" assert { type: "json" };

export const nftMarketAbi = NFTMarketABI.abi as const;

export interface NFTMarketDeployment {
  address: `0x${string}`;
  chainId: number;
  collection: `0x${string}`;
}

export const nftMarketDeployments: NFTMarketDeployment[] = [
  {
    address: "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853",
    chainId: 31337,
    collection: "0x0165878A594ca255338adfa4d48449f69242Eb8F",
  },
];
