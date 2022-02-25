import Error "mo:base/Error";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import P "mo:base/Prelude";

actor Dip721Nft {
	public shared query (doIOwn__msg) func doIOwn(tokenId : Nat) : async Bool {
		let caller = doIOwn__msg.caller; // First input
		_ownerOf(tokenId) == ?caller;
	};
	
	stable var name_ : Text = "ExampleNFT";
	
	stable var symbol_ : Text = "ENFT";
	
	// Adapted from: https://github.com/SuddenlyHazel/DIP721/blob/main/src/DIP721/DIP721.mo
	
	private type TokenAddress = Principal;
	private type TokenId = Nat;
	
	private stable var tokenPk : Nat = 0;
	
	private stable var tokenURIEntries : [(TokenId, Text)] = [];
	private stable var ownersEntries : [(TokenId, Principal)] = [];
	private stable var balancesEntries : [(Principal, Nat)] = [];
	private stable var tokenApprovalsEntries : [(TokenId, Principal)] = [];
	private stable var operatorApprovalsEntries : [(Principal, [Principal])] = [];
	
	private let tokenURIs : HashMap.HashMap<TokenId, Text> = HashMap.fromIter<TokenId, Text>(tokenURIEntries.vals(), 10, Nat.equal, Hash.hash);
	private let owners : HashMap.HashMap<TokenId, Principal> = HashMap.fromIter<TokenId, Principal>(ownersEntries.vals(), 10, Nat.equal, Hash.hash);
	private let balances : HashMap.HashMap<Principal, Nat> = HashMap.fromIter<Principal, Nat>(balancesEntries.vals(), 10, Principal.equal, Principal.hash);
	private let tokenApprovals : HashMap.HashMap<TokenId, Principal> = HashMap.fromIter<TokenId, Principal>(tokenApprovalsEntries.vals(), 10, Nat.equal, Hash.hash);
	private let operatorApprovals : HashMap.HashMap<Principal, [Principal]> = HashMap.fromIter<Principal, [Principal]>(operatorApprovalsEntries.vals(), 10, Principal.equal, Principal.hash);
	
	private func _unwrap<T>(x : ?T) : T {
		switch x {
			case null { P.unreachable() };
			case (?x_) { x_ };
		}
	};
	
	public shared query func balanceOf(p : Principal) : async ?Nat {
		return balances.get(p);
	};
	
	public shared query func ownerOf(tokenId : TokenId) : async ?Principal {
		return _ownerOf(tokenId);
	};
	
	public shared query func tokenURI(tokenId : TokenId) : async ?Text {
		return _tokenURI(tokenId);
	};
	
	public shared query func name() : async Text {
		return name_;
	};
	
	public shared query func symbol() : async Text {
		return symbol_;
	};
	
	public shared func isApprovedForAll(owner : Principal, opperator : Principal) : async Bool {
		return _isApprovedForAll(owner, opperator);
	};
	
	public shared(msg) func approve(to : Principal, tokenId : TokenId) : async () {
		switch(_ownerOf(tokenId)) {
			case (?owner) {
				assert to != owner;
				assert msg.caller == owner or _isApprovedForAll(owner, msg.caller);
				_approve(to, tokenId);
			};
			case (null) {
				throw Error.reject("No owner for token")
			};
		}
	};
	
	public shared func getApproved(tokenId : Nat) : async Principal {
		switch(_getApproved(tokenId)) {
			case (?v) { return v };
			case null { throw Error.reject("None approved") }
		}
	};
	
	public shared(msg) func setApprovalForAll(op : Principal, isApproved : Bool) : () {
		assert msg.caller != op;
		
		switch (isApproved) {
			case true {
				switch (operatorApprovals.get(msg.caller)) {
					case (?opList) {
						var array = Array.filter<Principal>(opList,func (p) { p != op });
						array := Array.append<Principal>(array, [op]);
						operatorApprovals.put(msg.caller, array);
					};
					case null {
						operatorApprovals.put(msg.caller, [op]);
					};
				};
			};
			case false {
				switch (operatorApprovals.get(msg.caller)) {
					case (?opList) {
						let array = Array.filter<Principal>(opList, func(p) { p != op });
						operatorApprovals.put(msg.caller, array);
					};
					case null {
						operatorApprovals.put(msg.caller, []);
					};
				};
			};
		};
		
	};
	
	public shared(msg) func transferFrom(from : Principal, to : Principal, tokenId : Nat) : () {
		assert _isApprovedOrOwner(msg.caller, tokenId);
		
		_transfer(from, to, tokenId);
	};
	
	public shared(msg) func mint(uri : Text) : async Nat {
		tokenPk += 1;
		_mint(msg.caller, tokenPk, uri);
		return tokenPk;
	};
	
	
	// Internal
	
	private func _ownerOf(tokenId : TokenId) : ?Principal {
		return owners.get(tokenId);
	};
	
	private func _tokenURI(tokenId : TokenId) : ?Text {
		return tokenURIs.get(tokenId);
	};
	
	private func _isApprovedForAll(owner : Principal, opperator : Principal) : Bool {
		switch (operatorApprovals.get(owner)) {
			case(?whiteList) {
				for (allow in whiteList.vals()) {
					if (allow == opperator) {
						return true;
					};
				};
			};
			case null {return false;};
		};
		return false;
	};
	
	private func _approve(to : Principal, tokenId : Nat) : () {
		tokenApprovals.put(tokenId, to);
	};
	
	private func _removeApprove(tokenId : Nat) : () {
		ignore tokenApprovals.remove(tokenId);
	};
	
	private func _exists(tokenId : Nat) : Bool {
		return Option.isSome(owners.get(tokenId));
	};
	
	private func _getApproved(tokenId : Nat) : ?Principal {
		assert _exists(tokenId) == true;
		switch(tokenApprovals.get(tokenId)) {
			case (?v) { return ?v };
			case null {
				return null;
			};
		}
	};
	
	private func _hasApprovedAndSame(tokenId : Nat, spender : Principal) : Bool {
		switch(_getApproved(tokenId)) {
			case (?v) {
				return v == spender;
			};
			case null { return false }
		}
	};
	
	private func _isApprovedOrOwner(spender : Principal, tokenId : Nat) : Bool {
		assert _exists(tokenId);
		let owner = _unwrap(_ownerOf(tokenId));
		return spender == owner or _hasApprovedAndSame(tokenId, spender) or _isApprovedForAll(owner, spender);
	};
	
	private func _transfer(from : Principal, to : Principal, tokenId : Nat) : () {
		assert _exists(tokenId);
		assert _unwrap(_ownerOf(tokenId)) == from;
		
		// Bug in HashMap https://github.com/dfinity/motoko-base/pull/253/files
		// this will throw unless you patch your file
		_removeApprove(tokenId);
		
		_decrementBalance(from);
		_incrementBalance(to);
		owners.put(tokenId, to);
	};
	
	private func _incrementBalance(address : Principal) {
		switch (balances.get(address)) {
			case (?v) {
				balances.put(address, v + 1);
			};
			case null {
				balances.put(address, 1);
			}
		}
	};
	
	private func _decrementBalance(address : Principal) {
		switch (balances.get(address)) {
			case (?v) {
				balances.put(address, v - 1);
			};
			case null {
				balances.put(address, 0);
			}
		}
	};
	
	private func _mint(to : Principal, tokenId : Nat, uri : Text) : () {
		assert not _exists(tokenId);
		
		_incrementBalance(to);
		owners.put(tokenId, to);
		tokenURIs.put(tokenId,uri)
	};
	
	private func _burn(tokenId : Nat) {
		let owner = _unwrap(_ownerOf(tokenId));
		
		_removeApprove(tokenId);
		_decrementBalance(owner);
		
		ignore owners.remove(tokenId);
	};
	
	system func preupgrade() {
		tokenURIEntries := Iter.toArray(tokenURIs.entries());
		ownersEntries := Iter.toArray(owners.entries());
		balancesEntries := Iter.toArray(balances.entries());
		tokenApprovalsEntries := Iter.toArray(tokenApprovals.entries());
		operatorApprovalsEntries := Iter.toArray(operatorApprovals.entries());
		
	};
	
	system func postupgrade() {
		tokenURIEntries := [];
		ownersEntries := [];
		balancesEntries := [];
		tokenApprovalsEntries := [];
		operatorApprovalsEntries := [];
	};
}
