// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { FHE, euint8, euint32, ebool } from "@fhevm/solidity/lib/FHE.sol";
import { SepoliaConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

contract PrivacyAbTesting is SepoliaConfig {

    address public owner;
    uint32 public currentExperimentId;

    struct Experiment {
        string name;
        string description;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        uint32 totalParticipants;
        uint32 groupACount;
        uint32 groupBCount;
        euint32 encryptedMetricSum;
        address creator;
    }

    struct Participant {
        euint8 assignedGroup; // 0 for A, 1 for B
        euint32 encryptedMetricValue;
        bool hasSubmittedData;
        uint256 joinTime;
        bytes32 anonymousId;
    }

    mapping(uint32 => Experiment) public experiments;
    mapping(uint32 => mapping(address => Participant)) public participants;
    mapping(uint32 => mapping(bytes32 => bool)) public anonymousIdUsed;
    mapping(address => uint32[]) public userExperiments;

    event ExperimentCreated(uint32 indexed experimentId, string name, address creator);
    event ParticipantJoined(uint32 indexed experimentId, bytes32 anonymousId, uint8 group);
    event DataSubmitted(uint32 indexed experimentId, bytes32 anonymousId);
    event ExperimentEnded(uint32 indexed experimentId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyExperimentCreator(uint32 _experimentId) {
        require(experiments[_experimentId].creator == msg.sender, "Not experiment creator");
        _;
    }

    modifier experimentExists(uint32 _experimentId) {
        require(experiments[_experimentId].creator != address(0), "Experiment does not exist");
        _;
    }

    modifier experimentActive(uint32 _experimentId) {
        require(experiments[_experimentId].isActive, "Experiment not active");
        require(block.timestamp >= experiments[_experimentId].startTime, "Experiment not started");
        require(block.timestamp <= experiments[_experimentId].endTime, "Experiment ended");
        _;
    }

    constructor() {
        owner = msg.sender;
        currentExperimentId = 1;
    }

    // Create a new A/B testing experiment
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
            encryptedMetricSum: FHE.asEuint32(0),
            creator: msg.sender
        });

        userExperiments[msg.sender].push(experimentId);

        emit ExperimentCreated(experimentId, _name, msg.sender);
        return experimentId;
    }

    // Join an experiment with anonymous ID
    function joinExperiment(
        uint32 _experimentId,
        bytes32 _anonymousId
    ) external
        experimentExists(_experimentId)
        experimentActive(_experimentId)
    {
        require(!anonymousIdUsed[_experimentId][_anonymousId], "Anonymous ID already used");
        require(!participants[_experimentId][msg.sender].hasSubmittedData, "Already participated");

        // Mark anonymous ID as used
        anonymousIdUsed[_experimentId][_anonymousId] = true;

        // Assign to group A or B based on encrypted random selection
        euint8 randomValue = FHE.randEuint8();
        euint8 groupAssignment = FHE.and(randomValue, FHE.asEuint8(1)); // 0 or 1

        participants[_experimentId][msg.sender] = Participant({
            assignedGroup: groupAssignment,
            encryptedMetricValue: FHE.asEuint32(0),
            hasSubmittedData: false,
            joinTime: block.timestamp,
            anonymousId: _anonymousId
        });

        // Update experiment counters
        experiments[_experimentId].totalParticipants++;

        // Grant access permissions
        FHE.allowThis(groupAssignment);
        FHE.allow(groupAssignment, msg.sender);

        emit ParticipantJoined(_experimentId, _anonymousId, 0); // Always emit 0 for privacy
    }

    // Submit encrypted metric data
    function submitData(
        uint32 _experimentId,
        uint32 _metricValue
    ) external
        experimentExists(_experimentId)
        experimentActive(_experimentId)
    {
        require(participants[_experimentId][msg.sender].joinTime > 0, "Not a participant");
        require(!participants[_experimentId][msg.sender].hasSubmittedData, "Data already submitted");

        // Encrypt the metric value
        euint32 encryptedValue = FHE.asEuint32(_metricValue);

        participants[_experimentId][msg.sender].encryptedMetricValue = encryptedValue;
        participants[_experimentId][msg.sender].hasSubmittedData = true;

        // Add to total encrypted sum
        experiments[_experimentId].encryptedMetricSum = FHE.add(
            experiments[_experimentId].encryptedMetricSum,
            encryptedValue
        );

        // Grant access permissions
        FHE.allowThis(encryptedValue);
        FHE.allow(encryptedValue, msg.sender);

        emit DataSubmitted(_experimentId, participants[_experimentId][msg.sender].anonymousId);
    }

    // End experiment and request results
    function endExperiment(uint32 _experimentId)
        external
        onlyExperimentCreator(_experimentId)
        experimentExists(_experimentId)
    {
        require(experiments[_experimentId].isActive, "Experiment already ended");

        experiments[_experimentId].isActive = false;
        experiments[_experimentId].endTime = block.timestamp;

        emit ExperimentEnded(_experimentId);
    }

    // Request decryption of results (only experiment creator)
    function requestResults(uint32 _experimentId)
        external
        onlyExperimentCreator(_experimentId)
        experimentExists(_experimentId)
    {
        require(!experiments[_experimentId].isActive, "Experiment still active");

        // Prepare encrypted values for decryption
        bytes32[] memory cts = new bytes32[](1);
        cts[0] = FHE.toBytes32(experiments[_experimentId].encryptedMetricSum);

        FHE.requestDecryption(cts, this.processResults.selector);
    }

    // Process decrypted results (callback)
    function processResults(
        uint256 requestId,
        uint32 totalSum,
        bytes memory signatures
    ) external {
        // Verify signatures
        bytes memory decryptedData = abi.encode(totalSum);
        FHE.checkSignatures(requestId, decryptedData, signatures);

        // Results are now available as totalSum
        // Additional processing can be done here
    }

    // Get participant's group assignment (encrypted)
    function getMyGroup(uint32 _experimentId)
        external
        view
        experimentExists(_experimentId)
        returns (bytes32)
    {
        require(participants[_experimentId][msg.sender].joinTime > 0, "Not a participant");
        return FHE.toBytes32(participants[_experimentId][msg.sender].assignedGroup);
    }

    // Get experiment info
    function getExperimentInfo(uint32 _experimentId)
        external
        view
        experimentExists(_experimentId)
        returns (
            string memory name,
            string memory description,
            uint256 startTime,
            uint256 endTime,
            bool isActive,
            uint32 totalParticipants,
            address creator
        )
    {
        Experiment storage exp = experiments[_experimentId];
        return (
            exp.name,
            exp.description,
            exp.startTime,
            exp.endTime,
            exp.isActive,
            exp.totalParticipants,
            exp.creator
        );
    }

    // Get participant status
    function getParticipantStatus(uint32 _experimentId, address _participant)
        external
        view
        experimentExists(_experimentId)
        returns (
            bool hasJoined,
            bool hasSubmittedData,
            uint256 joinTime
        )
    {
        Participant storage participant = participants[_experimentId][_participant];
        return (
            participant.joinTime > 0,
            participant.hasSubmittedData,
            participant.joinTime
        );
    }

    // Get user's experiments
    function getUserExperiments(address _user)
        external
        view
        returns (uint32[] memory)
    {
        return userExperiments[_user];
    }

    // Get current experiment count
    function getCurrentExperimentId() external view returns (uint32) {
        return currentExperimentId - 1;
    }

    // Check if anonymous ID is available
    function isAnonymousIdAvailable(uint32 _experimentId, bytes32 _anonymousId)
        external
        view
        experimentExists(_experimentId)
        returns (bool)
    {
        return !anonymousIdUsed[_experimentId][_anonymousId];
    }
}