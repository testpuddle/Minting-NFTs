# Creating an NFT using the DIP721NFT smart contract from Blocks-Editor 

## Aim
This process will build a DIP721NFT smart contract based on the template provided by the Blocks-Editor.  This is to show NFT functionality and is not a full implementation.

## Disclaimer

This is for educational purposes.  This is not fit for production use.  There is no security and many features are lacking.  Beware.

## Before you begin
  Make sure you have the DFINITY Canister SDK installed as found on https://smartcontract.org
  
  Confirm the installation is correct by following the quickstart tutorial found here: https://smartcontracts.org/docs/quickstart/local-quickstart.html
  
  Create three png digital assets and place them in a subdirectory called $HOME/digitalassets calling them 1.png, 2.png and 3.png
 
## Step 1: Create a new project named dip721 by running the following command from your home directory:

dfx new dip721

## Step 2: Start the local replica

In a new shell window or tab do:

cd $HOME/dip721

dfx start 

## Step 3:  Copy the .png files into the asset Canister 

cp $HOME/digitalassets/*.png  ./dip721/src/dip721_assets/assets

ls -l ./dip721/src/dip721_assets/assets

## Step 4:  Get the sample DIP721NFT template motoko code from Blocks-Editor
Navigate to https://blocks-editor.github.io/ (if you can't find it - I have a copy use main.mo in this repository.

Click on Try Online

Choose Load

Select the DIP721NFT

Select Compile 

Copy the code to the clipboard (by selecting the CLipboard on the bottom of the screen in the Compiled Output Window.

## Step 5: Replace the content of the main.mo smart contract with the DIP721NFT content (I use vi but you use VS code or another editor).
The content is in ./dip721/src/dip721/main.mo

rm ./dip721/src/dip721/main.mo

vi ./dip721/src/dip721/main.mo #paste the contents of the clipboard in.

## Step 6:  Deploy the canister locally

dfx deploy

## Step 7:  Start the node instance so webpages can be served.

In a new shell window or tab while in the root of the dip721 project directory:

npm start

## Step 8:  Check to see the local server is working using a browser:

http://localhost:8080/1.png  #This should display your .png file.

## Step 9: Test to see the DIP721 NFT smart contract is working.

dfx canister call dip721 name

If the smartcontract is successfully deployed it will return ("ExampleNFT")

dfx canister call dip721 symbol 

If the smartcontract is successfully deployed it will return ("ENFT")

## Step 10: Mint your first NFT using the DIP721NFT smart contract referencing the URI for the digital asset 1.png

call dip721 dfx canister mint http://localhost:8080/1.png

If successful, it will return the TokenID minted, i.e. (1:Nat) for the first Token.

## Step 11: Verify the URI that you used for Token1.

dfx canister call dip721 tokenURI '(1)'

## Step 12:  Confirm you own it

dfx canister call dip721 ownerOf '(1)'

This will return the pricipal that you used at the time of minting.

## Step 13 Check to see the principal you are using:

dfx identity list

The one with the * will be the identity being used - normally it will be called default.

dfx get-principal 

## Step 14: Find another principal to whom you wish to transfer ownership of the NFT.

dfx identity use alice_authdf   (This is just an example, use whatever one you see in the list for the example).

dfx get-principal

## Step 15: Return to the default identity

dfx identity use default

## Step 16:  Preparing for transfer - Confirm you own the NFT in case you are using the wrong principal

dfx canister call dip721 doIOwn '(1)'

## Step 17: Transfer it.

REPLACE THE PRINCIPALS with the correct ones.  Note the word principal is essential to include as it is part of the CANDID type notation.

dfx canister call dip721 transferFrom '(principal "p3oiq-zvq7o-ir4je-ngxhk-br4ps-ymn3e-i7lsc-a6o67-irbt3-h5ddq-pae",principal "zht7g-jivec-azc2g-f5bkj-oxsfc-nvyo6-ch4jb-el2tb-ebyuf-zeo4d-gae",1)'

## Step 18.  Confirm you no longer own it.

dfx canister call dip721 doIOwn '(1)'

("false") will be the response as you transferred it to someone else.

dfx canister call dip721 ownerOf '(1)'

It will respond with the principal of the new owner.

## Step 19

Access control and security have not been implemented.

