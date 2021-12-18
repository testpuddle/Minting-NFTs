# Minting-NFTs

NFT Making on the IC 
MY NOTES as A beginner
Disclaimer
	These are my notes and may contain inaccuracies.
	Use the information at your own risk.


  
Non-Fungible Token (NFT)
	A non-fungible token (NFT) is a unique and non-interchangeable unit of data stored on a digital ledger (blockchain).
	NFTs can be associated with reproducible digital files such as photos, videos, and audio.
	NFTs use a digital ledger to provide a public certificate of authenticity or proof of ownership, but it does not restrict the sharing or copying of the underlying digital file.
	The lack of interchangeability (fungibility) distinguishes NFTs from blockchain cryptocurrencies, such as Bitcoin.

The NFT terminology
	Digital asset: photo, music, video, game piece, software, ticket stub, etc.
	Minter: process that converts an asset into an NFT.
	Wallet – where your assets can be viewed/transferred.
	Marketplace – where you can buy and sell NFTs.
Difference between a digital asset and a NFT?
Costs of minting an NFT on the IC
	NFTs are stored in canisters.  
	Minting a canister costs about $3 USD on the IC:
	Canister creation costs 2 trillion Cycles.
	1 trillion cycles costs 1 Standard Define Rate (SDR), a term defined by the International Monetary Fund or approximately $1.42 USD as at 15 Dec 2021.
	In addition, there is an ongoing fee for storage, transmittal and processing.
	Overtime, the cost of storage and execution will have to be topped up unless it is loaded with more cycles to maintain it.  If not, it will be removed from the blockchain when it is depleted. 

Multiple NFTs can also be stored in a single canister reducing cost.
	Using a multi-NFT canister, minting 100 000 tokens would costs around $3 vs $300 000.



How do you make an NFT?
	Create an image and save as a .png file.  (Any digital asset can be used.)
	Use an online minter to create the NFT or do it yourself.



Online minting of your content
	DepartureLabs had an experimental minter – offline now.
	NFT anvil is in development.
	https://5rttq-yqaaa-aaaai-qa2ea-cai.raw.ic0.app/mint
	Toniqlabs will mint collections as part of the collect intake process if deemed of interest into Entrepot.

Let me know if you find any others.
 
Create it yourself
	You will need to have the DFINITY Canister SDK and dependencies installed and running on a computer  using :
	Windows with WSL2 and linux; 
	Linux; or
	Mac
	Follow the quick start tutorial and deploy the sdk hello example.
	Test to see if you can see the front end that looks like this:



So what did that achieve?
	You created a smart contract that is owned by you that displays an image (the dfinity symbol) stored on the local replica.  It has an index.html, index.js and the dfinity logo png.
	Turning into an NFT means adding the data elements for the certificate of ownership data and the functions to enable transfer and management of the NFT so that it will work with wallets.
	The data elements follow a format called ERC-721.
 
ERC-721
	Ethereum established a standard called ERC-721 (ERC is Ethereum Request for Comment) that defines data elements and methods that must be present when constructing an NFT for trading within the Ethereum eco-system to aid interoperability with wallets and ecosystems. 
	The Internet Computer community has not defined a standard however a variety of ERC-721 inspired implementations have been implemented:
	Toniq-Labs/extendable-token
	DepartureLabsIC/non-fungible-token
	C3-Protocol/NFT-standards
	rocklabs-io/ic-nft
	These implementatons are all available on github.


 
ERC-1155 – Multi-NFT

	ERC1155 uses a single smart contract to represent multiple tokens at once.
	Storing multiple NFTs into one smart contract reduces the cost of creating a canister for each and every NFT.
	Toniq-Labs/extendable-token examples has an advanced token that enables multiple NFTs to be stored in a single canister available on GITHUB.

For the purpose of this document, building is shown using an ERC-721-like token not the multi-NFT canister.


 
A word about wallets
	Wallets are a place to load, view and transfer NFTs.  They will accept NFTs in a format they support.
	Popular wallets are:
	Stoic Wallet by Toniq Labs and
	Plug Wallet
	EarthWallet by EarthDAO

Wallets only work with NFTs in certain formats.  If it is in the wrong format, it may be possible to use a wrapper to transform one NFT format into another NFT format.  

Creating a NFT and moving it to a Stoic Wallet
	Here is a process overview.
Steps to build (after you installed the SDK)
	Create a new project called nft1


	It will install code and when successful displays the following. 






Clone the NFT code repository from GITHUB
	Change directory into ~nft1.
	Install github (if not already done  google for your particular platform).  
	Clone the repository (repo) locally.

	Copy the erc721.mo file in the examples subdirectory into the ~nft1/src/nft1 subdirectory.
	Rename the existing main.mo to main.old or delete it.
	Rename the erc721.mo to main.mo
This replaces the Motoko code with the ERC721 code. 


Move the dependencies
	Copy the extendable-token motoko sub-directory and its contents into the ~nft1/src directory.
	Check make ext and util directories are their and the files are there:


Start the local replica
	dfx start --clean      warning: --clean wipes out the old replica state
	dfx start 

Create an empty Canister
Build the wasm code
	dfx build nft1
Get the principal
	dfx identity get-principal will show you the identity you are using on the local replica.  Your principal response will be different to this.
Install the code into the canister
	The dfx canister install is used to move the code into the canister and to set the owner of the registry to your principal.  Your principle will be different (the output from the dfx identity get-principal)

Status check
	You now have a canister with the dfinity logo in it and the NFT logic to manage the token.  It also has an HTML page to render it and a no longer needed index.js which can be removed.
	Check to see which identity will be the minter.
	

Mint your first NFT
	Call the mintNFT method passing the principal (vs a stoic address) with the appropriate principal
You can use dfx to call public methods of the canister 
	getMinter()   e.g. dfx canister call nft1 getMinter
	setMinter(minter : Principal)
	mintNFT(request : MintRequest)
	transfer(request: TransferRequest)
	approve(request: ApproveRequest)
	extensions()
	balance(request : BalanceRequest)
	allowance(request : AllowanceRequest)

…continued
	bearer(token : TokenIdentifier)
	supply(token : TokenIdentifier)
	getRegistry()
	getAllowances()
	getTokens()
	metadata(token
	public func acceptCycles()
	availableCycles()
This is what was achieved
	You minted an NFT with ownership information stored within the canister on the local replica.
	There is no access control implemented – anyone can see the content of the canister or call the methods – not just the NFT holder.
	Upgrading the contract may clobber persistent data (I have not checked this).
	You can mint additional tokens by running the mint command again and it will store it in the same canister with an index.
DEPLOYING ON THE IC
Deploying costs cycles
	Creating a canister costs 2 Trillion cycles.

	Sign up to GITHUB to get free cycles from the Dfinity cycles faucet:
					https://faucet.dfinity.org/auth

	With a GITHUB account created more than 90 days ago, you can get free cycles to test deployment on the IC.
	The Faucet will give about $20 worth of cycles once. 

Now moving to the real world
	Doing it on chain in production would involve:
	creating a canister (incurs a cost of 2 x SDR) using the NNS.
	Noting the canister ID.
	Replacing the Dfinity logo image file with your digital asset image.
	Clean up the code (index.js and index.html).
	Add access controls in the Motoko code.
	Installing the code into the canister on the IC with the correct principle and meta data by changing the json file in the build.
Along the lines of dfx deploy --network ic --no-wallet

	Then running the dfx minter command pointing to the IC.


Moving into a wallet:  
	Install a wallet that supports NFTs (e.g. Stoic wallet)
	Go to the NFT option
	Add NFTs
	Enter the canister ID when you created it on the IC
	Boom! Done! (if the canister is in a compatible format).
The End
