from web3 import Web3
import time

# enter your private key.  Be careful with your private key
private_key = "3e6b29b9e9b8f1b0af41e2150a0ff5883f5f4615c880dc86e49cd37da4b0a664"

# add your blockchain connection information
infura_url = 'https://ropsten.infura.io/v3/812452009e1a419289aea5abcb8e3734'

web3 = Web3(Web3.HTTPProvider(infura_url))
print(web3.isConnected())

# enter the account that the crypto is being sent from
from_account ="0xD4fA4748C53736fBaF97e01EB55584F24b85afb8"

# enter a list of accounts that the crypto is being sent to
to_addresses = ("0x7e6512518b2C10644b327f03A2FD966B1483EFb6", "0x43138CE633F015DEa78df028e6270a1eBBeA4FDe", "0x2Be0694790606A6Ab5F8c44A6a4b46FdbE24ED3C")

# get from account balance so you can monitor
sending_account_balance = web3.eth.get_balance(from_account)
balance = web3.fromWei(sending_account_balance, "ether")
print(balance)

# loop through each of the to_addresses and send Ether in the amount designated below
for i in to_addresses:
    print(i)

    nonce = web3.eth.getTransactionCount(from_account)

    tx = {
        'nonce': nonce,
        'to': web3.toChecksumAddress(i),
        'value': web3.toWei(.005, 'ether'),
        'gas': 21000,
        'gasPrice': web3.toWei('50', 'gwei')
    }

# sign the transaction and print on the screen
# wait 5 seconds before processing the next transaction
    signed_tx = web3.eth.account.sign_transaction(tx, private_key)
    tx_hash = web3.eth.sendRawTransaction(signed_tx.rawTransaction)
    transaction = web3.toHex(tx_hash)
    print(transaction)
    time.sleep(5)