# Privacy A/B Testing Platform

A revolutionary A/B testing platform that leverages **Fully Homomorphic Encryption (FHE)** to conduct anonymous experiments while preserving complete data privacy throughout the testing process.

## 🔒 Core Concepts

### Fully Homomorphic Encryption (FHE) Contracts
This platform utilizes cutting-edge FHE technology to enable computation on encrypted data without ever decrypting it. Key features include:

- **Anonymous Participation**: Users can join tests with anonymous IDs while maintaining complete privacy
- **Encrypted Data Processing**: All metric values and group assignments are processed in encrypted form
- **Privacy-Preserving Analytics**: Aggregate results can be computed without revealing individual participant data
- **Secure Random Assignment**: Participants are randomly assigned to groups A or B using encrypted randomization

### Anonymous A/B Testing Architecture
- **Private Group Assignment**: Group allocation (A/B) is encrypted and only revealed when necessary
- **Encrypted Metrics Collection**: All performance metrics are encrypted at submission
- **Anonymous Identity Management**: Participants use anonymous IDs to prevent correlation with real identities
- **Confidential Result Aggregation**: Final results are computed on encrypted values

## 🚀 Features

- **Create Private Experiments**: Set up A/B tests with customizable duration and parameters
- **Anonymous Participation**: Join tests using anonymous identifiers
- **Encrypted Data Submission**: Submit test metrics in encrypted form
- **Privacy-Preserving Results**: View aggregated results without compromising individual privacy
- **Secure Group Assignment**: Automatic encrypted assignment to test groups
- **Real-time Experiment Management**: Monitor and control active experiments

## 📋 Smart Contract

**Contract Address**: `0xf2DF4bd7851AB7a5084403d54850b93c56e196B7`

**Network**: Sepolia Testnet

**Key Functions**:
- `createExperiment()`: Create new A/B tests
- `joinExperiment()`: Anonymous participation with encrypted group assignment
- `submitData()`: Submit encrypted metric values
- `requestResults()`: Decrypt and retrieve final results
- `endExperiment()`: Terminate active experiments

## 🎥 Demo Resources

### Live Demo
🌐 **Web Application**: [https://privacy-ab-testing.vercel.app/](https://privacy-ab-testing.vercel.app/)

### Video Demonstration
📹 **Demo Video**: Available in the repository (`PrivacyAbTesting.mp4`)

### Transaction Evidence
📊 **On-chain Transaction Screenshot**: `PrivacyAbTesting.png`

## 💻 Technology Stack

- **Smart Contracts**: Solidity with Zama FHE libraries
- **Frontend**: Vanilla JavaScript with Web3 integration
- **Blockchain**: Ethereum Sepolia Testnet
- **Encryption**: Fully Homomorphic Encryption (FHE)
- **Web3 Integration**: Ethers.js for blockchain interactions

## 🔧 Core Smart Contract Features

### Experiment Management
```solidity
struct Experiment {
    string name;
    string description;
    uint256 startTime;
    uint256 endTime;
    bool isActive;
    uint32 totalParticipants;
    euint32 encryptedMetricSum;  // FHE encrypted sum
    address creator;
}
```

### Privacy-Preserving Participation
```solidity
struct Participant {
    euint8 assignedGroup;        // Encrypted group assignment
    euint32 encryptedMetricValue; // Encrypted metric data
    bool hasSubmittedData;
    bytes32 anonymousId;         // Anonymous identifier
}
```

## 🛡️ Privacy Features

1. **Anonymous Identity**: Participants use self-generated anonymous IDs
2. **Encrypted Group Assignment**: Group allocation (A/B) remains encrypted
3. **Private Metrics**: All performance data is encrypted before submission
4. **Secure Aggregation**: Results computed on encrypted values
5. **Confidential Results**: Only authorized creators can decrypt final results

## 🌐 Web Interface

The platform provides an intuitive web interface with four main sections:

1. **Create Test**: Design and launch new A/B experiments
2. **Participate**: Join existing tests anonymously
3. **My Tests**: Manage created experiments
4. **Results**: View decrypted test outcomes

## 🔗 Repository

**GitHub**: [https://github.com/RomaineMetz/PrivacyAbTesting](https://github.com/RomaineMetz/PrivacyAbTesting)

## 🏗️ Architecture Highlights

- **On-chain Privacy**: All sensitive operations occur on-chain with FHE protection
- **Client-side Encryption**: Data encrypted before leaving user's device
- **Decentralized Results**: No central authority can access individual data
- **Transparent Verification**: All operations verifiable on blockchain
- **Scalable Design**: Supports multiple concurrent experiments

## 🎯 Use Cases

- **Marketing Campaign Testing**: Compare ad variants while protecting user privacy
- **Product Feature Analysis**: Test UI changes without exposing user behavior
- **Content Performance Evaluation**: Measure engagement privately
- **Conversion Rate Optimization**: Optimize funnels while maintaining anonymity
- **User Experience Research**: Conduct studies with complete privacy guarantees

## 🔐 Security Considerations

- Anonymous IDs prevent participant correlation
- FHE ensures data remains encrypted during computation
- Group assignments use secure randomization
- Result decryption requires proper authorization
- All operations are recorded on immutable blockchain

---

*Built with privacy-first principles using Fully Homomorphic Encryption to revolutionize A/B testing while protecting user data.*