import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Validator {
  'validateGame' : ActorMethod<
    [number, number, number, number],
    [boolean, string]
  >,
}
export interface _SERVICE extends Validator {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
