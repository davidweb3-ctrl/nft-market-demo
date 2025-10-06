"use client";

import { useMemo, useState } from "react";
import { useAccount, useReadContract, useWriteContract } from "wagmi";
import { formatUnits, parseUnits } from "viem";
import { nftMarketAbi, nftMarketDeployments } from "@nft-market-demo/contracts";
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

export function MarketplacePanel() {
  const { address } = useAccount();
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
    if (!address) return;
    const parsedPrice = parseUnits(price || "0", DECIMALS);

    await writeContractAsync({
      address: deployment.address,
      abi: nftMarketAbi,
      functionName: "list",
      args: [BigInt(tokenId), deployment.collection, parsedPrice],
    }).catch(console.error);

    await refetchListing();
  }

  async function handleBuy() {
    if (!address) return;
    const result = listing as any;
    if (!result || result.seller === "0x0000000000000000000000000000000000000000") {
      return;
    }

    await writeContractAsync({
      address: deployment.address,
      abi: nftMarketAbi,
      functionName: "buyNFT",
      args: [BigInt(tokenId)],
    }).catch(console.error);

    await refetchListing();
  }

  const listingInfo = listing as { seller: string; paymentToken: string; price: bigint } | undefined;

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

        {listingInfo && listingInfo.seller != address && listingInfo.seller != "0x0000000000000000000000000000000000000000" ? (
          <div className="border rounded p-3 text-sm">
            <div className="font-semibold">Current Listing</div>
            <div>Seller: {listingInfo.seller}</div>
            <div>Price: {formatUnits(listingInfo.price, DECIMALS)} MTK</div>
            <div>Payment Token: {listingInfo.paymentToken}</div>
          </div>
        ) : (
          <div className="text-sm text-muted-foreground">
            No active listing for this token.
          </div>
        )}
      </CardContent>
      <CardFooter className="space-x-2">
        <Button onClick={handleList} disabled={isPending}>
          List
        </Button>
        <Button onClick={handleBuy} variant="secondary" disabled={isPending}>
          Buy
        </Button>
      </CardFooter>
    </Card>
  );
}
