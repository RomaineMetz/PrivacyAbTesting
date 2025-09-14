# Hello FHEVM: Build Your First Privacy-Preserving A/B Testing Application

## Welcome to FHEVM Development! 🎉

This comprehensive tutorial will guide you through building your first **Fully Homomorphic Encryption (FHE)** powered decentralized application on the Zama network. By the end of this tutorial, you'll have created a complete privacy-preserving A/B testing platform that protects user data while enabling meaningful analytics.

## 🎯 Learning Objectives

After completing this tutorial, you will be able to:

- ✅ Understand the fundamentals of Fully Homomorphic Encryption in blockchain applications
- ✅ Build smart contracts using FHEVM with encrypted data types
- ✅ Create a web frontend that interacts with FHE-enabled smart contracts
- ✅ Deploy your application to the Sepolia testnet
- ✅ Test encrypted operations and private computations
- ✅ Implement real-world privacy-preserving features

## 📋 Prerequisites

Before starting this tutorial, you should have:

- **Solidity Knowledge**: Basic understanding of smart contracts, functions, and state variables
- **JavaScript/HTML**: Familiarity with web development
- **MetaMask**: Browser wallet extension installed
- **Development Tools**: Basic familiarity with npm and command line
- **No Cryptography Knowledge Required**: We'll explain FHE concepts as we go!

## 🛠️ What We're Building

We'll create a **Privacy-Preserving A/B Testing Platform** that allows:

- **Anonymous Participation**: Users join tests without revealing their identity
- **Encrypted Data Collection**: All metrics are encrypted before storage
- **Private Group Assignment**: A/B group allocation remains confidential
- **Secure Result Aggregation**: Final results computed on encrypted data

## 🏗️ Project Structure

```
privacy-ab-testing/
├── contracts/
│   └── PrivacyAbTesting.sol
├── frontend/
│   ├── index.html
│   ├── app.js
│   └── styles.css
├── scripts/
│   └── deploy.js
├── package.json
└── hardhat.config.js
```

---

## Part 1: Understanding FHEVM Basics

### What is Fully Homomorphic Encryption?

**Fully Homomorphic Encryption (FHE)** allows computations to be performed on encrypted data without decrypting it. This means:

- Data stays encrypted during processing
- Computations produce encrypted results
- Only authorized parties can decrypt final results
- Perfect for privacy-preserving applications

### FHEVM Data Types

FHEVM introduces special encrypted data types:

```solidity
euint8   // Encrypted 8-bit unsigned integer
euint16  // Encrypted 16-bit unsigned integer
euint32  // Encrypted 32-bit unsigned integer
ebool    // Encrypted boolean
```

### Key FHEVM Operations

```solidity
// Create encrypted values
euint32 encryptedValue = FHE.asEuint32(100);

// Arithmetic operations
euint32 sum = FHE.add(a, b);
euint32 product = FHE.mul(a, b);

// Comparison operations
ebool isEqual = FHE.eq(a, b);
ebool isGreater = FHE.gt(a, b);

// Random number generation
euint8 randomNum = FHE.randEuint8();
```

---

## Part 2: Setting Up Your Development Environment

### Step 1: Initialize Your Project

```bash
mkdir privacy-ab-testing
cd privacy-ab-testing
npm init -y
```

### Step 2: Install Dependencies

```bash
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npm install @fhevm/solidity ethers
```

### Step 3: Initialize Hardhat

```bash
npx hardhat init
```

Select "Create a JavaScript project" when prompted.

### Step 4: Configure Hardhat for Sepolia

Update `hardhat.config.js`:

```javascript
require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: "https://sepolia.infura.io/v3/YOUR_INFURA_KEY",
      accounts: ["YOUR_PRIVATE_KEY"]
    }
  }
};
```

---

## Part 3: Building the Smart Contract

### Step 1: Create the Base Contract Structure

Create `contracts/PrivacyAbTesting.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { FHE, euint8, euint32, ebool } from "@fhevm/solidity/lib/FHE.sol";
import { SepoliaConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

contract PrivacyAbTesting is SepoliaConfig {

    address public owner;
    uint32 public currentExperimentId;

    constructor() {
        owner = msg.sender;
        currentExperimentId = 1;
    }
}
```

**🔍 What's Happening Here:**
- We import FHEVM libraries and data types
- `SepoliaConfig` provides network-specific FHE configuration
- Basic contract initialization with owner and experiment counter

### Step 2: Define Data Structures

Add these structures to your contract:

```solidity
struct Experiment {
    string name;
    string description;
    uint256 startTime;
    uint256 endTime;
    bool isActive;
    uint32 totalParticipants;
    uint32 groupACount;
    uint32 groupBCount;
    euint32 encryptedMetricSum;  // 🔒 Encrypted sum of all metrics
    address creator;
}

struct Participant {
    euint8 assignedGroup;        // 🔒 Encrypted group assignment (0=A, 1=B)
    euint32 encryptedMetricValue; // 🔒 Encrypted metric data
    bool hasSubmittedData;
    uint256 joinTime;
    bytes32 anonymousId;         // Anonymous identifier
}
```

**🔍 Key Privacy Features:**
- `euint32 encryptedMetricSum`: Stores encrypted aggregate data
- `euint8 assignedGroup`: Group assignment stays private
- `euint32 encryptedMetricValue`: Individual metrics are encrypted
- `bytes32 anonymousId`: Prevents identity correlation

### Step 3: Add State Variables and Events

```solidity
mapping(uint32 => Experiment) public experiments;
mapping(uint32 => mapping(address => Participant)) public participants;
mapping(uint32 => mapping(bytes32 => bool)) public anonymousIdUsed;
mapping(address => uint32[]) public userExperiments;

event ExperimentCreated(uint32 indexed experimentId, string name, address creator);
event ParticipantJoined(uint32 indexed experimentId, bytes32 anonymousId, uint8 group);
event DataSubmitted(uint32 indexed experimentId, bytes32 anonymousId);
event ExperimentEnded(uint32 indexed experimentId);
```

### Step 4: Implement Core Functions

#### Creating Experiments

```solidity
function createExperiment(
    string memory _name,
    string memory _description,
    uint256 _duration
) external returns (uint32) {
    require(bytes(_name).length > 0, "Name cannot be empty");
    require(_duration > 0, "Duration must be positive");

    uint32 experimentId = currentExperimentId++;

    experiments[experimentId] = Experiment({
        name: _name,
        description: _description,
        startTime: block.timestamp,
        endTime: block.timestamp + _duration,
        isActive: true,
        totalParticipants: 0,
        groupACount: 0,
        groupBCount: 0,
        encryptedMetricSum: FHE.asEuint32(0), // 🔒 Initialize encrypted sum
        creator: msg.sender
    });

    userExperiments[msg.sender].push(experimentId);
    emit ExperimentCreated(experimentId, _name, msg.sender);
    return experimentId;
}
```

**🔍 Privacy Implementation:**
- `FHE.asEuint32(0)` creates an encrypted zero value
- All metric aggregation will happen on encrypted data

#### Anonymous Participation

```solidity
function joinExperiment(
    uint32 _experimentId,
    bytes32 _anonymousId
) external {
    require(experiments[_experimentId].isActive, "Experiment not active");
    require(!anonymousIdUsed[_experimentId][_anonymousId], "Anonymous ID already used");

    // Mark anonymous ID as used
    anonymousIdUsed[_experimentId][_anonymousId] = true;

    // 🔒 Encrypted random group assignment
    euint8 randomValue = FHE.randEuint8();
    euint8 groupAssignment = FHE.and(randomValue, FHE.asEuint8(1)); // 0 or 1

    participants[_experimentId][msg.sender] = Participant({
        assignedGroup: groupAssignment,
        encryptedMetricValue: FHE.asEuint32(0),
        hasSubmittedData: false,
        joinTime: block.timestamp,
        anonymousId: _anonymousId
    });

    experiments[_experimentId].totalParticipants++;

    // 🔑 Grant access permissions for encrypted data
    FHE.allowThis(groupAssignment);
    FHE.allow(groupAssignment, msg.sender);

    emit ParticipantJoined(_experimentId, _anonymousId, 0); // Always emit 0 for privacy
}
```

**🔍 Privacy Features:**
- `FHE.randEuint8()` generates encrypted random numbers
- `FHE.and()` performs encrypted bitwise AND for group assignment
- `FHE.allowThis()` and `FHE.allow()` manage encrypted data permissions
- Event emits `0` instead of actual group for privacy

#### Encrypted Data Submission

```solidity
function submitData(
    uint32 _experimentId,
    uint32 _metricValue
) external {
    require(participants[_experimentId][msg.sender].joinTime > 0, "Not a participant");
    require(!participants[_experimentId][msg.sender].hasSubmittedData, "Data already submitted");

    // 🔒 Encrypt the metric value
    euint32 encryptedValue = FHE.asEuint32(_metricValue);

    participants[_experimentId][msg.sender].encryptedMetricValue = encryptedValue;
    participants[_experimentId][msg.sender].hasSubmittedData = true;

    // 🔒 Add to encrypted total (computation on encrypted data!)
    experiments[_experimentId].encryptedMetricSum = FHE.add(
        experiments[_experimentId].encryptedMetricSum,
        encryptedValue
    );

    // 🔑 Grant access permissions
    FHE.allowThis(encryptedValue);
    FHE.allow(encryptedValue, msg.sender);

    emit DataSubmitted(_experimentId, participants[_experimentId][msg.sender].anonymousId);
}
```

**🔍 The Magic of FHE:**
- `FHE.asEuint32(_metricValue)` encrypts user input
- `FHE.add()` performs addition on encrypted values
- Result remains encrypted until explicitly decrypted

#### Result Decryption

```solidity
function requestResults(uint32 _experimentId) external {
    require(experiments[_experimentId].creator == msg.sender, "Not experiment creator");
    require(!experiments[_experimentId].isActive, "Experiment still active");

    // 🔓 Request decryption of encrypted sum
    bytes32[] memory cts = new bytes32[](1);
    cts[0] = FHE.toBytes32(experiments[_experimentId].encryptedMetricSum);

    FHE.requestDecryption(cts, this.processResults.selector);
}

function processResults(
    uint256 requestId,
    uint32 totalSum,
    bytes memory signatures
) external {
    // Verify decryption signatures
    bytes memory decryptedData = abi.encode(totalSum);
    FHE.checkSignatures(requestId, decryptedData, signatures);

    // Results are now available as totalSum
}
```

**🔍 Decryption Process:**
- Only experiment creators can request decryption
- `FHE.requestDecryption()` initiates the decryption process
- Results are verified with cryptographic signatures

---

## Part 4: Building the Frontend

### Step 1: Create the HTML Structure

Create `index.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Privacy A/B Testing Platform</title>
    <script src="https://cdn.jsdelivr.net/npm/ethers@5.7.2/dist/ethers.umd.min.js"></script>
    <script src="https://unpkg.com/fhevmjs@0.5.0/bundle/index.web.js"></script>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <header class="header">
            <h1>🔒 Privacy A/B Testing</h1>
            <p>Your first FHEVM application</p>
        </header>

        <div class="wallet-section" id="walletSection">
            <div id="connectWallet">
                <button class="btn primary" onclick="connectWallet()">
                    Connect Wallet
                </button>
            </div>
            <div id="walletConnected" class="hidden">
                <p>Connected: <span id="walletAddress"></span></p>
                <p>Network: <span id="networkName"></span></p>
            </div>
        </div>

        <div class="tabs">
            <button class="tab active" onclick="showTab('create')">Create Test</button>
            <button class="tab" onclick="showTab('participate')">Participate</button>
            <button class="tab" onclick="showTab('results')">Results</button>
        </div>

        <!-- Tab content sections will go here -->
    </div>

    <script src="app.js"></script>
</body>
</html>
```

### Step 2: Implement Web3 Integration

Create `app.js`:

```javascript
// Contract configuration
const CONTRACT_ADDRESS = "YOUR_DEPLOYED_CONTRACT_ADDRESS";
const CONTRACT_ABI = [/* Your contract ABI */];

let provider;
let signer;
let contract;
let fhevmInstance;

// Initialize the application
async function init() {
    console.log("🚀 Initializing FHEVM Application...");

    if (typeof window.ethereum !== 'undefined') {
        provider = new ethers.providers.Web3Provider(window.ethereum);

        // Check if already connected
        const accounts = await provider.listAccounts();
        if (accounts.length > 0) {
            await connectWallet();
        }
    } else {
        showStatus('Please install MetaMask', 'error');
    }
}

// Connect to MetaMask and initialize FHEVM
async function connectWallet() {
    try {
        console.log("🔌 Connecting to wallet...");

        // Request account access
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        provider = new ethers.providers.Web3Provider(window.ethereum);
        signer = provider.getSigner();

        // Initialize FHEVM instance
        console.log("🔐 Initializing FHEVM...");
        if (typeof fhevm !== 'undefined') {
            fhevmInstance = await fhevm.createInstance({
                chainId: parseInt(await window.ethereum.request({ method: 'eth_chainId' }), 16),
                provider: window.ethereum
            });
            console.log("✅ FHEVM initialized successfully!");
        }

        // Create contract instance
        contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);

        await updateWalletInfo();
        showStatus('Connected successfully! 🎉', 'success');

    } catch (error) {
        console.error('Connection error:', error);
        showStatus('Failed to connect: ' + error.message, 'error');
    }
}

// Create new experiment
async function createExperiment() {
    try {
        const name = document.getElementById('experimentName').value;
        const description = document.getElementById('experimentDescription').value;
        const duration = parseInt(document.getElementById('duration').value) * 3600;

        console.log("🧪 Creating experiment:", name);

        const tx = await contract.createExperiment(name, description, duration);
        console.log("⏳ Transaction sent:", tx.hash);

        await tx.wait();
        console.log("✅ Experiment created successfully!");

        showStatus('Experiment created! 🎊', 'success');

    } catch (error) {
        console.error('Create experiment error:', error);
        showStatus('Failed to create experiment: ' + error.message, 'error');
    }
}

// Join experiment anonymously
async function joinExperiment() {
    try {
        const experimentId = parseInt(document.getElementById('joinExperimentId').value);
        const anonymousId = document.getElementById('anonymousId').value;

        console.log("👤 Joining experiment anonymously...");

        // Convert to bytes32
        const anonymousIdBytes32 = ethers.utils.formatBytes32String(anonymousId);

        const tx = await contract.joinExperiment(experimentId, anonymousIdBytes32);
        await tx.wait();

        console.log("✅ Joined experiment successfully!");
        showStatus('Joined experiment anonymously! 🎭', 'success');

    } catch (error) {
        console.error('Join experiment error:', error);
        showStatus('Failed to join: ' + error.message, 'error');
    }
}

// Submit encrypted data
async function submitData() {
    try {
        const experimentId = parseInt(document.getElementById('submitExperimentId').value);
        const metricValue = parseInt(document.getElementById('metricValue').value);

        console.log("🔐 Submitting encrypted data...");

        const tx = await contract.submitData(experimentId, metricValue);
        await tx.wait();

        console.log("✅ Data submitted and encrypted!");
        showStatus('Data encrypted and submitted! 🔒', 'success');

    } catch (error) {
        console.error('Submit data error:', error);
        showStatus('Failed to submit data: ' + error.message, 'error');
    }
}

// Initialize when page loads
window.addEventListener('load', init);
```

**🔍 Key Frontend Features:**
- **FHEVM Integration**: Initialize FHEVM instance for encrypted operations
- **Wallet Connection**: Connect to MetaMask and manage user sessions
- **Contract Interaction**: Call smart contract functions with proper error handling
- **Privacy Preservation**: Handle anonymous IDs and encrypted data submission

---

## Part 5: Deployment and Testing

### Step 1: Compile Your Contract

```bash
npx hardhat compile
```

### Step 2: Create Deployment Script

Create `scripts/deploy.js`:

```javascript
const { ethers } = require("hardhat");

async function main() {
    console.log("🚀 Deploying Privacy A/B Testing Contract...");

    const PrivacyAbTesting = await ethers.getContractFactory("PrivacyAbTesting");
    const contract = await PrivacyAbTesting.deploy();

    await contract.deployed();

    console.log("✅ Contract deployed to:", contract.address);
    console.log("📝 Update your frontend with this address!");

    // Verify contract
    console.log("⏳ Waiting for block confirmations...");
    await contract.deployTransaction.wait(5);

    console.log("🎉 Deployment complete!");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
```

### Step 3: Deploy to Sepolia

```bash
npx hardhat run scripts/deploy.js --network sepolia
```

### Step 4: Update Frontend Configuration

Update `app.js` with your deployed contract address:

```javascript
const CONTRACT_ADDRESS = "0xYourDeployedContractAddress";
```

---

## Part 6: Testing Your Application

### Step 1: Test Contract Functions

Create `test/PrivacyAbTesting.test.js`:

```javascript
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PrivacyAbTesting", function () {
    let contract;
    let owner, user1, user2;

    beforeEach(async function () {
        [owner, user1, user2] = await ethers.getSigners();

        const PrivacyAbTesting = await ethers.getContractFactory("PrivacyAbTesting");
        contract = await PrivacyAbTesting.deploy();
        await contract.deployed();
    });

    it("Should create an experiment", async function () {
        const tx = await contract.createExperiment(
            "Test Campaign",
            "Testing button colors",
            3600
        );

        const receipt = await tx.wait();
        expect(receipt.events[0].event).to.equal("ExperimentCreated");
    });

    it("Should allow anonymous participation", async function () {
        // Create experiment
        await contract.createExperiment("Test", "Description", 3600);

        // Join anonymously
        const anonymousId = ethers.utils.formatBytes32String("user123");
        await contract.connect(user1).joinExperiment(1, anonymousId);

        const status = await contract.getParticipantStatus(1, user1.address);
        expect(status.hasJoined).to.be.true;
    });

    it("Should handle encrypted data submission", async function () {
        await contract.createExperiment("Test", "Description", 3600);

        const anonymousId = ethers.utils.formatBytes32String("user123");
        await contract.connect(user1).joinExperiment(1, anonymousId);

        await contract.connect(user1).submitData(1, 100);

        const status = await contract.getParticipantStatus(1, user1.address);
        expect(status.hasSubmittedData).to.be.true;
    });
});
```

### Step 2: Run Tests

```bash
npx hardhat test
```

### Step 3: Test Frontend

1. **Start Local Server**:
   ```bash
   npx http-server . -p 8080 --cors
   ```

2. **Open in Browser**: Navigate to `http://localhost:8080`

3. **Test Workflow**:
   - Connect MetaMask to Sepolia
   - Create a test experiment
   - Join with anonymous ID
   - Submit encrypted metric data
   - Request results (creator only)

---

## Part 7: Understanding the Privacy Features

### How Data Stays Private

1. **Anonymous Participation**: Users create their own anonymous IDs
2. **Encrypted Group Assignment**: A/B groups are assigned using encrypted randomization
3. **Encrypted Metrics**: All performance data is encrypted before storage
4. **Private Aggregation**: Results are computed on encrypted values
5. **Controlled Decryption**: Only experiment creators can decrypt final results

### Real-World Applications

- **Marketing Campaigns**: Test ad variants without exposing user behavior
- **Product Features**: Compare UI elements while protecting user privacy
- **Content Testing**: Measure engagement without revealing individual preferences
- **Conversion Optimization**: Improve funnels while maintaining anonymity

---

## 🎓 Congratulations!

You've successfully built your first FHEVM application! You now understand:

- ✅ **FHE Fundamentals**: How encrypted computation works in smart contracts
- ✅ **Privacy Patterns**: Implementing anonymous participation and encrypted data
- ✅ **FHEVM Development**: Using encrypted data types and operations
- ✅ **Full-Stack Integration**: Connecting frontend to FHE-enabled contracts
- ✅ **Real-World Applications**: Building privacy-preserving decentralized applications

## 🚀 Next Steps

1. **Enhance the UI**: Add better styling and user experience improvements
2. **Add More Features**: Implement result visualization and analytics
3. **Explore Advanced FHE**: Try conditional operations and complex computations
4. **Build Other Applications**: Apply FHE to voting, auctions, or gaming
5. **Join the Community**: Share your project and learn from other developers

## 📚 Additional Resources

- **FHEVM Documentation**: [https://docs.zama.ai/fhevm](https://docs.zama.ai/fhevm)
- **Zama GitHub**: [https://github.com/zama-ai](https://github.com/zama-ai)
- **Community Discord**: Join discussions with other FHE developers
- **Example Projects**: Explore more FHEVM applications

---

**🏆 You're now ready to build the next generation of privacy-preserving applications!**

*Remember: With great privacy power comes great responsibility. Always consider the ethical implications of the data you're protecting and ensure your applications truly serve user privacy.*