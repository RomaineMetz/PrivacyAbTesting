# 🚀 Quick Start Guide

Get your Privacy A/B Testing FHEVM application running in 5 minutes!

## Prerequisites Checklist

- [ ] **Node.js** (v16 or higher) installed
- [ ] **MetaMask** browser extension installed
- [ ] **Sepolia testnet ETH** in your wallet ([Get free ETH here](https://sepoliafaucet.com/))
- [ ] **Git** installed (optional, for cloning)

## ⚡ Lightning Setup

### 1. Clone and Install

```bash
# Clone the repository
git clone https://github.com/your-username/privacy-ab-testing-fhevm-tutorial.git
cd privacy-ab-testing-fhevm-tutorial

# Install dependencies
npm install
```

### 2. Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your values
nano .env  # or use your preferred editor
```

Add your configuration:
```env
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
PRIVATE_KEY=your_private_key_without_0x_prefix
ETHERSCAN_API_KEY=your_etherscan_key_optional
```

### 3. Deploy Smart Contract

```bash
# Compile contracts
npm run compile

# Deploy to Sepolia testnet
npm run deploy
```

**📝 Save your contract address!** You'll need it for the frontend.

### 4. Update Frontend Configuration

Edit `index.html` and update the contract address:

```javascript
const CONTRACT_ADDRESS = "0xYourDeployedContractAddress";
```

### 5. Launch Application

```bash
# Start local server
npm run serve
```

Visit: **http://localhost:8080**

## 🎯 Test Your Application

### Create Your First A/B Test

1. **Connect Wallet**: Click "Connect Wallet" and approve MetaMask
2. **Create Test**:
   - Name: "Button Color Test"
   - Description: "Testing red vs blue buttons"
   - Duration: 24 hours

3. **Join Anonymously**:
   - Test ID: 1
   - Anonymous ID: "user_123_anonymous"

4. **Submit Data**:
   - Test ID: 1
   - Metric Value: 150 (e.g., conversion rate)

5. **View Results**: End the test and request decrypted results

## 🔍 Verification Steps

- [ ] Contract deployed successfully ✅
- [ ] Wallet connected to Sepolia ✅
- [ ] Experiment created ✅
- [ ] Anonymous participation works ✅
- [ ] Encrypted data submission successful ✅
- [ ] No errors in browser console ✅

## 🆘 Troubleshooting

### Common Issues

**"Please install MetaMask"**
- Install MetaMask browser extension
- Refresh the page

**"Please switch to Sepolia network"**
- In MetaMask: Networks → Add Network → Sepolia Testnet
- Or let the app add it automatically

**"Insufficient funds"**
- Get free Sepolia ETH from [SepoliaFaucet.com](https://sepoliafaucet.com/)

**"Contract not deployed"**
- Run `npm run deploy` again
- Check your .env configuration
- Ensure you have Sepolia ETH for gas

### Getting Help

1. **Check the Console**: Open browser DevTools (F12) for error messages
2. **Review Logs**: Look at transaction hashes on [Sepolia Etherscan](https://sepolia.etherscan.io/)
3. **Read Tutorial**: Full detailed guide in `TUTORIAL.md`

## 🎉 Success!

You now have a working FHEVM privacy application!

### What You've Accomplished

- ✅ Deployed your first FHE smart contract
- ✅ Built a privacy-preserving web application
- ✅ Implemented encrypted data handling
- ✅ Created anonymous user participation
- ✅ Learned FHEVM development fundamentals

### Next Steps

- Read the complete `TUTORIAL.md` for deeper understanding
- Experiment with different FHE operations
- Build your own privacy-preserving applications
- Join the Zama developer community

---

**🏆 Congratulations! You're now an FHEVM developer!**

*Time to build the future of privacy-preserving applications! 🔒*