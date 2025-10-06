"use client";

import { useEffect, useState } from "react";
import { usePublicClient } from "wagmi";
import { parseAbiItem, Hex, createPublicClient, http } from "viem";
import { nftMarketAbi, nftMarketDeployments } from "@nft-market-demo/contracts";

interface EventLog {
  type: "list" | "purchase";
  seller: string;
  buyer?: string;
  tokenId: bigint;
  paymentToken: string;
  price: bigint;
  amountPaid: bigint;
  viaCallback?: boolean;
  txHash: string;
}

const LISTED_EVENT = parseAbiItem(
  "event NFTListed(address indexed seller, uint256 indexed tokenId, address indexed paymentToken, uint256 price)"
);
const PURCHASED_EVENT = parseAbiItem(
  "event NFTPurchased(address indexed buyer, address indexed seller, uint256 indexed tokenId, address paymentToken, uint256 price, uint256 amountPaid, bool viaCallback)"
);

export function MarketEventsListener() {
  const client = usePublicClient();
  const [logs, setLogs] = useState<EventLog[]>([]);

  useEffect(() => {
    if (!client) return;

    const deployment = nftMarketDeployments[0];
    if (!deployment) return;

    const unwatchList = client.watchEvent({
      address: deployment.address,
      abi: nftMarketAbi,
      eventName: "NFTListed",
      onLogs: (entries) => {
        setLogs((prev) => [
          ...entries.map((entry) => ({
            type: "list" as const,
            seller: entry.args.seller,
            tokenId: entry.args.tokenId,
            paymentToken: entry.args.paymentToken,
            price: entry.args.price,
            amountPaid: entry.args.price,
            txHash: entry.transactionHash,
          })),
          ...prev,
        ]);
      },
    });

    const unwatchPurchase = client.watchEvent({
      address: deployment.address,
      abi: nftMarketAbi,
      eventName: "NFTPurchased",
      onLogs: (entries) => {
        setLogs((prev) => [
          ...entries.map((entry) => ({
            type: "purchase" as const,
            seller: entry.args.seller,
            buyer: entry.args.buyer,
            tokenId: entry.args.tokenId,
            paymentToken: entry.args.paymentToken,
            price: entry.args.price,
            amountPaid: entry.args.amountPaid,
            viaCallback: entry.args.viaCallback,
            txHash: entry.transactionHash,
          })),
          ...prev,
        ]);
      },
    });

    return () => {
      unwatchList?.();
      unwatchPurchase?.();
    };
  }, [client]);

  if (logs.length === 0) return null;

  return (
    <div className="space-y-2">
      {logs.map((log, idx) => (
        <div key={`${log.txHash}-${idx}`} className="text-xs text-muted-foreground border p-2 rounded">
          <div className="font-semibold uppercase tracking-wide">
            {log.type === "list" ? "NFT Listed" : "NFT Purchased"}
          </div>
          <div>Token ID: {log.tokenId.toString()}</div>
          <div>Seller: {log.seller}</div>
          {log.buyer && <div>Buyer: {log.buyer}</div>}
          <div>Payment Token: {log.paymentToken}</div>
          <div>Price: {log.price.toString()}</div>
          {log.type === "purchase" && (
            <div>
              Amount Paid: {log.amountPaid.toString()} {log.viaCallback ? "(via tokensReceived)" : ""}
            </div>
          )}
          <div>Tx: {log.txHash}</div>
        </div>
      ))}
    </div>
  );
}
