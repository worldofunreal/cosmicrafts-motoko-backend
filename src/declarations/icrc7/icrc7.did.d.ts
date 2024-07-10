import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Account {
  'owner' : Principal,
  'subaccount' : [] | [Uint8Array | number[]],
}
export interface ApprovalArgs {
  'memo' : [] | [Uint8Array | number[]],
  'from_subaccount' : [] | [Subaccount],
  'token_ids' : [] | [Array<TokenId>],
  'created_at_time' : [] | [bigint],
  'expires_at' : [] | [bigint],
  'spender' : Account,
}
export type ApprovalError = {
    'GenericError' : { 'message' : string, 'error_code' : bigint }
  } |
  { 'TemporarilyUnavailable' : {} } |
  { 'Unauthorized' : { 'token_ids' : Array<TokenId> } } |
  { 'TooOld' : null };
export type ApprovalId = bigint;
export type ApprovalReceipt = { 'Ok' : ApprovalId } |
  { 'Err' : ApprovalError };
export type BalanceResult = { 'Ok' : bigint } |
  { 'Err' : CallError };
export type CallError = { 'GenericError' : null } |
  { 'SupplyCapOverflow' : null } |
  { 'InvalidTokenId' : null } |
  { 'Unauthorized' : null } |
  { 'InvalidRecipient' : null } |
  { 'AlreadyExistTokenId' : null };
export interface Collection {
  'get_collection_owner' : ActorMethod<[], Account>,
  'get_transactions' : ActorMethod<
    [GetTransactionsArgs],
    GetTransactionsResult
  >,
  'icrc7_approve' : ActorMethod<[ApprovalArgs], ApprovalReceipt>,
  'icrc7_balance_of' : ActorMethod<[Account], BalanceResult>,
  'icrc7_collection_metadata' : ActorMethod<[], CollectionMetadata>,
  'icrc7_description' : ActorMethod<[], [] | [string]>,
  'icrc7_image' : ActorMethod<[], [] | [Uint8Array | number[]]>,
  'icrc7_metadata' : ActorMethod<[TokenId], MetadataResult>,
  'icrc7_name' : ActorMethod<[], string>,
  'icrc7_owner_of' : ActorMethod<[TokenId], OwnerResult>,
  'icrc7_royalties' : ActorMethod<[], [] | [number]>,
  'icrc7_royalty_recipient' : ActorMethod<[], [] | [Account]>,
  'icrc7_supply_cap' : ActorMethod<[], [] | [bigint]>,
  'icrc7_supported_standards' : ActorMethod<[], Array<SupportedStandard>>,
  'icrc7_symbol' : ActorMethod<[], string>,
  'icrc7_tokens_of' : ActorMethod<[Account], TokensOfResult>,
  'icrc7_total_supply' : ActorMethod<[], bigint>,
  'icrc7_transfer' : ActorMethod<[TransferArgs], TransferReceipt>,
  'mint' : ActorMethod<[MintArgs], MintReceipt>,
  'mintDeck' : ActorMethod<[Array<MintArgs>], MintReceipt>,
  'upgradeNFT' : ActorMethod<[UpgradeArgs], UpgradeReceipt>,
}
export interface CollectionInitArgs {
  'name' : string,
  'description' : [] | [string],
  'supplyCap' : [] | [bigint],
  'royalties' : [] | [number],
  'royaltyRecipient' : [] | [Account],
  'image' : [] | [Uint8Array | number[]],
  'symbol' : string,
}
export interface CollectionMetadata {
  'name' : string,
  'description' : [] | [string],
  'supplyCap' : [] | [bigint],
  'totalSupply' : bigint,
  'royalties' : [] | [number],
  'royaltyRecipient' : [] | [Account],
  'image' : [] | [Uint8Array | number[]],
  'symbol' : string,
}
export interface GetTransactionsArgs {
  'offset' : bigint,
  'limit' : bigint,
  'account' : [] | [Account],
}
export interface GetTransactionsResult {
  'total' : bigint,
  'transactions' : Array<Transaction>,
}
export type Metadata = { 'Int' : bigint } |
  { 'Nat' : bigint } |
  { 'Blob' : Uint8Array | number[] } |
  { 'Text' : string } |
  { 'MetadataArray' : MetadataArray };
export type MetadataArray = Array<[string, Metadata]>;
export type MetadataResult = { 'Ok' : Array<[string, Metadata]> } |
  { 'Err' : CallError };
export interface MintArgs {
  'to' : Account,
  'token_id' : TokenId,
  'metadata' : Array<[string, Metadata]>,
}
export type MintError = {
    'GenericError' : { 'message' : string, 'error_code' : bigint }
  } |
  { 'SupplyCapOverflow' : null } |
  { 'Unauthorized' : null } |
  { 'InvalidRecipient' : null } |
  { 'AlreadyExistTokenId' : null };
export type MintReceipt = { 'Ok' : TokenId } |
  { 'Err' : MintError };
export type OwnerResult = { 'Ok' : Account } |
  { 'Err' : CallError };
export type Subaccount = Uint8Array | number[];
export interface SupportedStandard { 'url' : string, 'name' : string }
export type TokenId = bigint;
export type TokensOfResult = { 'Ok' : Array<TokenId> } |
  { 'Err' : CallError };
export interface Transaction {
  'kind' : string,
  'mint' : [] | [{ 'to' : Account, 'token_ids' : Array<TokenId> }],
  'icrc7_transfer' : [] | [
    {
      'to' : Account,
      'from' : Account,
      'memo' : [] | [Uint8Array | number[]],
      'token_ids' : Array<TokenId>,
      'created_at_time' : [] | [bigint],
      'spender' : [] | [Account],
    }
  ],
  'upgrade' : [] | [
    {
      'new_metadata' : Array<[string, Metadata]>,
      'token_id' : [] | [TokenId],
      'memo' : [] | [Uint8Array | number[]],
      'upgraded_at' : [] | [bigint],
      'prev_metadata' : Array<[string, Metadata]>,
    }
  ],
  'timestamp' : bigint,
  'icrc7_approve' : [] | [
    {
      'from' : Account,
      'memo' : [] | [Uint8Array | number[]],
      'token_ids' : [] | [Array<TokenId>],
      'created_at_time' : [] | [bigint],
      'expires_at' : [] | [bigint],
      'spender' : Account,
    }
  ],
}
export interface TransferArgs {
  'to' : Account,
  'spender_subaccount' : [] | [Subaccount],
  'from' : [] | [Account],
  'memo' : [] | [Uint8Array | number[]],
  'is_atomic' : [] | [boolean],
  'token_ids' : Array<TokenId>,
  'created_at_time' : [] | [bigint],
}
export type TransferError = {
    'GenericError' : { 'message' : string, 'error_code' : bigint }
  } |
  { 'TemporarilyUnavailable' : {} } |
  { 'Duplicate' : { 'duplicate_of' : TransferId } } |
  { 'Unauthorized' : { 'token_ids' : Array<TokenId> } } |
  { 'CreatedInFuture' : { 'ledger_time' : bigint } } |
  { 'TooOld' : null };
export type TransferId = bigint;
export type TransferReceipt = { 'Ok' : TransferId } |
  { 'Err' : TransferError };
export interface UpgradeArgs {
  'token_id' : TokenId,
  'metadata' : Array<[string, Metadata]>,
  'from' : Account,
}
export type UpgradeError = { 'DoesntExistTokenId' : null } |
  { 'GenericError' : { 'message' : string, 'error_code' : bigint } } |
  { 'Unauthorized' : null } |
  { 'InvalidRecipient' : null };
export type UpgradeReceipt = { 'Ok' : TokenId } |
  { 'Err' : UpgradeError };
export interface _SERVICE extends Collection {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
