"use client";

import { useMemo, useState } from "react";
import { useAccount, useReadContract, useWriteContract } from "wagmi";
import { formatUnits, parseUnits } from "viem";
import { nftMarketAbi, nftMarketDeployments } from "@nft-market-demo/contracts";
import { erc721Abi } from "viem";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";

const DECIMALS = 18;
const DEFAULT_CHAIN_ID = Number(process.env.NEXT_PUBLIC_CHAIN_ID || 31337);
const PAYMENT_TOKEN_ADDRESS = process.env.NEXT_PUBLIC_TOKEN_ADDRESS as `0x${string}`;

export function MarketplacePanel() {
  const { address, isConnected } = useAccount();
  const deployment = useMemo(
    () => nftMarketDeployments.find((d) => d.chainId === DEFAULT_CHAIN_ID),
    []
  );

  const [tokenId, setTokenId] = useState("0");
  const [price, setPrice] = useState("0");

  const { data: listing, refetch: refetchListing } = useReadContract({
    address: deployment?.address,
    abi: nftMarketAbi,
    functionName: "getListing",
    args: tokenId ? [BigInt(tokenId)] : undefined,
    query: {
      enabled: Boolean(deployment && tokenId !== ""),
    },
  });

  const { writeContractAsync, isPending } = useWriteContract();

  // 钱包未连接时不显示
  if (!isConnected) {
    return null;
  }

  if (!deployment) {
    return (
      <Alert variant="destructive">
        <AlertTitle>Marketplace not configured</AlertTitle>
        <AlertDescription>
          No NFTMarket deployment found for chain {DEFAULT_CHAIN_ID}.
        </AlertDescription>
      </Alert>
    );
  }

  async function handleList() {
    if (!address) {
      toast.error("Please connect your wallet");
      return;
    }
    
    if (!tokenId || tokenId === "0") {
      toast.error("Please enter a valid Token ID");
      return;
    }
    
    if (!price || parseFloat(price) <= 0) {
      toast.error("Please enter a valid price");
      return;
    }
    
    const parsedPrice = parseUnits(price || "0", DECIMALS);
    let toastId: string | number | undefined;

    try {
      // 先 approve NFT 给 NFTMarket 合约
      toastId = toast.loading("Step 1/2: Approving NFT...");
      const approveTx = await writeContractAsync({
        address: deployment.collection,
        abi: erc721Abi,
        functionName: "approve",
        args: [deployment.address, BigInt(tokenId)],
      });
      toast.success(`NFT approved! Tx: ${approveTx.slice(0, 10)}...`, { id: toastId });

      // 然后上架 NFT
      toastId = toast.loading("Step 2/2: Listing NFT...");
      const listTx = await writeContractAsync({
        address: deployment.address,
        abi: nftMarketAbi,
        functionName: "list",
        args: [BigInt(tokenId), PAYMENT_TOKEN_ADDRESS, parsedPrice],
      });
      toast.success(`NFT listed successfully! Tx: ${listTx.slice(0, 10)}...`, { id: toastId });

      await refetchListing();
    } catch (error: any) {
      console.error("Failed to list NFT:", error);
      if (toastId) {
        toast.error(error?.shortMessage || error?.message || "Failed to list NFT", { id: toastId });
      } else {
        toast.error(error?.shortMessage || error?.message || "Failed to list NFT");
      }
    }
  }

  async function handleBuy() {
    if (!address) {
      toast.error("Please connect your wallet");
      return;
    }
    
    const result = listing as any;
    if (!result || result.seller === "0x0000000000000000000000000000000000000000") {
      toast.error("No active listing for this NFT");
      return;
    }

    let toastId: string | number | undefined;
    try {
      // 先授权 MyERC20 代币给 NFTMarket 合约
      toastId = toast.loading("Step 1/2: Approving payment token...");
      const approveTx = await writeContractAsync({
        address: PAYMENT_TOKEN_ADDRESS,
        abi: [
          {
            name: "approve",
            type: "function",
            stateMutability: "nonpayable",
            inputs: [
              { name: "spender", type: "address" },
              { name: "amount", type: "uint256" }
            ],
            outputs: [{ type: "bool" }]
          }
        ],
        functionName: "approve",
        args: [deployment.address, listingInfo!.price],
      });
      toast.success(`Payment token approved! Tx: ${approveTx.slice(0, 10)}...`, { id: toastId });

      // 然后购买 NFT
      toastId = toast.loading("Step 2/2: Purchasing NFT...");
      const buyTx = await writeContractAsync({
        address: deployment.address,
        abi: nftMarketAbi,
        functionName: "buyNFT",
        args: [BigInt(tokenId)],
      });
      toast.success(`NFT purchased successfully! Tx: ${buyTx.slice(0, 10)}...`, { id: toastId });
      
      await refetchListing();
    } catch (error: any) {
      console.error("Failed to buy NFT:", error);
      if (toastId) {
        toast.error(error?.shortMessage || error?.message || "Failed to buy NFT", { id: toastId });
      } else {
        toast.error(error?.shortMessage || error?.message || "Failed to buy NFT");
      }
    }
  }

  const listingInfo = listing as { seller: string; paymentToken: string; price: bigint } | undefined;
  const isOwnListing = listingInfo?.seller.toLowerCase() === address?.toLowerCase();
  const hasActiveListing = listingInfo && listingInfo.seller !== "0x0000000000000000000000000000000000000000";

  return (
    <Card>
      <CardHeader>
        <CardTitle>Marketplace</CardTitle>
        <CardDescription>List or purchase NFTs directly.</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="grid gap-4 sm:grid-cols-2">
          <div>
            <p className="text-xs text-muted-foreground mb-1">Token ID</p>
            <Input
              value={tokenId}
              onChange={(e) => setTokenId(e.target.value)}
              placeholder="Enter token ID"
            />
          </div>
          <div>
            <p className="text-xs text-muted-foreground mb-1">Price (MTK)</p>
            <Input
              value={price}
              onChange={(e) => setPrice(e.target.value)}
              placeholder="Enter price"
            />
          </div>
        </div>

        {listingInfo && listingInfo.seller !== "0x0000000000000000000000000000000000000000" ? (
          <div className="border rounded p-3 text-sm space-y-1">
            <div className="font-semibold text-base mb-2">
              {listingInfo.seller.toLowerCase() === address?.toLowerCase() 
                ? "Your Listing" 
                : "Current Listing"}
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Seller:</span>
              <span className="font-mono text-xs">
                {listingInfo.seller.toLowerCase() === address?.toLowerCase()
                  ? "You"
                  : `${listingInfo.seller.slice(0, 6)}...${listingInfo.seller.slice(-4)}`}
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Price:</span>
              <span className="font-semibold">{formatUnits(listingInfo.price, DECIMALS)} MTK</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Payment Token:</span>
              <span className="font-mono text-xs">
                {listingInfo.paymentToken.slice(0, 6)}...{listingInfo.paymentToken.slice(-4)}
              </span>
            </div>
          </div>
        ) : (
          <div className="text-sm text-muted-foreground border rounded p-3">
            No active listing for this token.
          </div>
        )}
      </CardContent>
      <CardFooter className="flex flex-col gap-3">
        {hasActiveListing && isOwnListing ? (
          <>
            <Alert>
              <AlertDescription>
                This NFT is currently listed. The contract doesn't support canceling listings directly.
                You can wait for someone to purchase it.
              </AlertDescription>
            </Alert>
          </>
        ) : hasActiveListing ? (
          <>
            <Button onClick={handleBuy} disabled={isPending} className="w-full">
              Buy NFT
            </Button>
          </>
        ) : (
          <>
            <Button onClick={handleList} disabled={isPending} className="w-full">
              List NFT
            </Button>
          </>
        )}
      </CardFooter>
    </Card>
  );
}
