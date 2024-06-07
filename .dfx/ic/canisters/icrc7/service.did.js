export const idlFactory = ({ IDL }) => {
  const Metadata = IDL.Rec();
  const Account = IDL.Record({
    'owner' : IDL.Principal,
    'subaccount' : IDL.Opt(IDL.Vec(IDL.Nat8)),
  });
  const CollectionInitArgs = IDL.Record({
    'name' : IDL.Text,
    'description' : IDL.Opt(IDL.Text),
    'supplyCap' : IDL.Opt(IDL.Nat),
    'royalties' : IDL.Opt(IDL.Nat16),
    'royaltyRecipient' : IDL.Opt(Account),
    'image' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'symbol' : IDL.Text,
  });
  const GetTransactionsArgs = IDL.Record({
    'offset' : IDL.Nat,
    'limit' : IDL.Nat,
    'account' : IDL.Opt(Account),
  });
  const TokenId = IDL.Nat;
  const MetadataArray = IDL.Vec(IDL.Tuple(IDL.Text, Metadata));
  Metadata.fill(
    IDL.Variant({
      'Int' : IDL.Int,
      'Nat' : IDL.Nat,
      'Blob' : IDL.Vec(IDL.Nat8),
      'Text' : IDL.Text,
      'MetadataArray' : MetadataArray,
    })
  );
  const Transaction = IDL.Record({
    'kind' : IDL.Text,
    'mint' : IDL.Opt(
      IDL.Record({ 'to' : Account, 'token_ids' : IDL.Vec(TokenId) })
    ),
    'icrc7_transfer' : IDL.Opt(
      IDL.Record({
        'to' : Account,
        'from' : Account,
        'memo' : IDL.Opt(IDL.Vec(IDL.Nat8)),
        'token_ids' : IDL.Vec(TokenId),
        'created_at_time' : IDL.Opt(IDL.Nat64),
        'spender' : IDL.Opt(Account),
      })
    ),
    'upgrade' : IDL.Opt(
      IDL.Record({
        'new_metadata' : IDL.Vec(IDL.Tuple(IDL.Text, Metadata)),
        'token_id' : IDL.Opt(TokenId),
        'memo' : IDL.Opt(IDL.Vec(IDL.Nat8)),
        'upgraded_at' : IDL.Opt(IDL.Nat64),
        'prev_metadata' : IDL.Vec(IDL.Tuple(IDL.Text, Metadata)),
      })
    ),
    'timestamp' : IDL.Nat64,
    'icrc7_approve' : IDL.Opt(
      IDL.Record({
        'from' : Account,
        'memo' : IDL.Opt(IDL.Vec(IDL.Nat8)),
        'token_ids' : IDL.Opt(IDL.Vec(TokenId)),
        'created_at_time' : IDL.Opt(IDL.Nat64),
        'expires_at' : IDL.Opt(IDL.Nat64),
        'spender' : Account,
      })
    ),
  });
  const GetTransactionsResult = IDL.Record({
    'total' : IDL.Nat,
    'transactions' : IDL.Vec(Transaction),
  });
  const Subaccount = IDL.Vec(IDL.Nat8);
  const ApprovalArgs = IDL.Record({
    'memo' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'from_subaccount' : IDL.Opt(Subaccount),
    'token_ids' : IDL.Opt(IDL.Vec(TokenId)),
    'created_at_time' : IDL.Opt(IDL.Nat64),
    'expires_at' : IDL.Opt(IDL.Nat64),
    'spender' : Account,
  });
  const ApprovalId = IDL.Nat;
  const ApprovalError = IDL.Variant({
    'GenericError' : IDL.Record({
      'message' : IDL.Text,
      'error_code' : IDL.Nat,
    }),
    'TemporarilyUnavailable' : IDL.Record({}),
    'Unauthorized' : IDL.Record({ 'token_ids' : IDL.Vec(TokenId) }),
    'TooOld' : IDL.Null,
  });
  const ApprovalReceipt = IDL.Variant({
    'Ok' : ApprovalId,
    'Err' : ApprovalError,
  });
  const CallError = IDL.Variant({
    'GenericError' : IDL.Null,
    'SupplyCapOverflow' : IDL.Null,
    'InvalidTokenId' : IDL.Null,
    'Unauthorized' : IDL.Null,
    'InvalidRecipient' : IDL.Null,
    'AlreadyExistTokenId' : IDL.Null,
  });
  const BalanceResult = IDL.Variant({ 'Ok' : IDL.Nat, 'Err' : CallError });
  const CollectionMetadata = IDL.Record({
    'name' : IDL.Text,
    'description' : IDL.Opt(IDL.Text),
    'supplyCap' : IDL.Opt(IDL.Nat),
    'totalSupply' : IDL.Nat,
    'royalties' : IDL.Opt(IDL.Nat16),
    'royaltyRecipient' : IDL.Opt(Account),
    'image' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'symbol' : IDL.Text,
  });
  const MetadataResult = IDL.Variant({
    'Ok' : IDL.Vec(IDL.Tuple(IDL.Text, Metadata)),
    'Err' : CallError,
  });
  const OwnerResult = IDL.Variant({ 'Ok' : Account, 'Err' : CallError });
  const SupportedStandard = IDL.Record({ 'url' : IDL.Text, 'name' : IDL.Text });
  const TokensOfResult = IDL.Variant({
    'Ok' : IDL.Vec(TokenId),
    'Err' : CallError,
  });
  const TransferArgs = IDL.Record({
    'to' : Account,
    'spender_subaccount' : IDL.Opt(Subaccount),
    'from' : IDL.Opt(Account),
    'memo' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'is_atomic' : IDL.Opt(IDL.Bool),
    'token_ids' : IDL.Vec(TokenId),
    'created_at_time' : IDL.Opt(IDL.Nat64),
  });
  const TransferId = IDL.Nat;
  const TransferError = IDL.Variant({
    'GenericError' : IDL.Record({
      'message' : IDL.Text,
      'error_code' : IDL.Nat,
    }),
    'TemporarilyUnavailable' : IDL.Record({}),
    'Duplicate' : IDL.Record({ 'duplicate_of' : TransferId }),
    'Unauthorized' : IDL.Record({ 'token_ids' : IDL.Vec(TokenId) }),
    'CreatedInFuture' : IDL.Record({ 'ledger_time' : IDL.Nat64 }),
    'TooOld' : IDL.Null,
  });
  const TransferReceipt = IDL.Variant({
    'Ok' : TransferId,
    'Err' : TransferError,
  });
  const MintArgs = IDL.Record({
    'to' : Account,
    'token_id' : TokenId,
    'metadata' : IDL.Vec(IDL.Tuple(IDL.Text, Metadata)),
  });
  const MintError = IDL.Variant({
    'GenericError' : IDL.Record({
      'message' : IDL.Text,
      'error_code' : IDL.Nat,
    }),
    'SupplyCapOverflow' : IDL.Null,
    'Unauthorized' : IDL.Null,
    'InvalidRecipient' : IDL.Null,
    'AlreadyExistTokenId' : IDL.Null,
  });
  const MintReceipt = IDL.Variant({ 'Ok' : TokenId, 'Err' : MintError });
  const UpgradeArgs = IDL.Record({
    'token_id' : TokenId,
    'metadata' : IDL.Vec(IDL.Tuple(IDL.Text, Metadata)),
    'from' : Account,
  });
  const UpgradeError = IDL.Variant({
    'DoesntExistTokenId' : IDL.Null,
    'GenericError' : IDL.Record({
      'message' : IDL.Text,
      'error_code' : IDL.Nat,
    }),
    'Unauthorized' : IDL.Null,
    'InvalidRecipient' : IDL.Null,
  });
  const UpgradeReceipt = IDL.Variant({ 'Ok' : TokenId, 'Err' : UpgradeError });
  const Collection = IDL.Service({
    'get_collection_owner' : IDL.Func([], [Account], ['query']),
    'get_transactions' : IDL.Func(
        [GetTransactionsArgs],
        [GetTransactionsResult],
        [],
      ),
    'icrc7_approve' : IDL.Func([ApprovalArgs], [ApprovalReceipt], []),
    'icrc7_balance_of' : IDL.Func([Account], [BalanceResult], ['query']),
    'icrc7_collection_metadata' : IDL.Func([], [CollectionMetadata], ['query']),
    'icrc7_description' : IDL.Func([], [IDL.Opt(IDL.Text)], ['query']),
    'icrc7_image' : IDL.Func([], [IDL.Opt(IDL.Vec(IDL.Nat8))], ['query']),
    'icrc7_metadata' : IDL.Func([TokenId], [MetadataResult], ['query']),
    'icrc7_name' : IDL.Func([], [IDL.Text], ['query']),
    'icrc7_owner_of' : IDL.Func([TokenId], [OwnerResult], ['query']),
    'icrc7_royalties' : IDL.Func([], [IDL.Opt(IDL.Nat16)], ['query']),
    'icrc7_royalty_recipient' : IDL.Func([], [IDL.Opt(Account)], ['query']),
    'icrc7_supply_cap' : IDL.Func([], [IDL.Opt(IDL.Nat)], ['query']),
    'icrc7_supported_standards' : IDL.Func(
        [],
        [IDL.Vec(SupportedStandard)],
        ['query'],
      ),
    'icrc7_symbol' : IDL.Func([], [IDL.Text], ['query']),
    'icrc7_tokens_of' : IDL.Func([Account], [TokensOfResult], ['query']),
    'icrc7_total_supply' : IDL.Func([], [IDL.Nat], ['query']),
    'icrc7_transfer' : IDL.Func([TransferArgs], [TransferReceipt], []),
    'mint' : IDL.Func([MintArgs], [MintReceipt], []),
    'mintDeck' : IDL.Func([IDL.Vec(MintArgs)], [MintReceipt], []),
    'upgradeNFT' : IDL.Func([UpgradeArgs], [UpgradeReceipt], []),
  });
  return Collection;
};
export const init = ({ IDL }) => {
  const Account = IDL.Record({
    'owner' : IDL.Principal,
    'subaccount' : IDL.Opt(IDL.Vec(IDL.Nat8)),
  });
  const CollectionInitArgs = IDL.Record({
    'name' : IDL.Text,
    'description' : IDL.Opt(IDL.Text),
    'supplyCap' : IDL.Opt(IDL.Nat),
    'royalties' : IDL.Opt(IDL.Nat16),
    'royaltyRecipient' : IDL.Opt(Account),
    'image' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'symbol' : IDL.Text,
  });
  return [Account, CollectionInitArgs];
};
