// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

interface IERC20 {
  function transfer(address to, uint256 amount) external;
  function balanceOf(address user) external returns (uint256);
  function decimals() external view returns (uint256);
}

interface IUniswapV2Pair {
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function token0() external view returns (address);
  function token1() external view returns (address);
}

interface IUniswapV2Router02 {
  function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
  function getAmountsIn(uint amountOut, address[] memory path) external view returns (uint[] memory amounts);
}

contract RandomNumberConsumer is VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 internal _userLength;

    uint256 public randomResult;

    constructor()
        VRFConsumerBase(
            0x747973a5A2a4Ae1D3a8fDF5479f1514F65Db9C31, // VRF Coordinator
            0x404460C6A5EdE2D891e8297795264fDe62ADBB75  // LINK Token
        )
    {
        keyHash = 0xc251acd21ec4fb7f31bb8868288bfdbaeb4fbfec2df3735ddbd4f7dc8d60103c;
        fee = 0.2 * 10 ** 18; // 0.2 LINK
    }

    function getRandomNumber(uint256 _length) public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");

        _userLength = _length;
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness % _userLength;
    }
}

contract WenLamboLottery is RandomNumberConsumer {
  address public owner;
  address public token = 0xd8A31016cD7da048ca21FFE04256C6d08C3A2251;
  bytes32 public proofHash;
  uint256 public usersLength;
  uint256 public rewardUSD;

  address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
  address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

  modifier onlyOwner(){
    require(msg.sender == owner, 'Only owner!');
    _;
  }

  constructor(address _owner, uint256 _reward){
    owner = _owner;
    rewardUSD = _reward;
  }

  function requestWinner(bytes32 _hash, uint256 _length) external onlyOwner {

    proofHash = _hash;
    usersLength = _length;
    bytes32 requestId = getRandomNumber(usersLength);
  }

  function submitWinner(address _winner) external onlyOwner {
    uint256 rewardAmount = getRewardAmount();

    uint256 amount = rewardAmount > IERC20(token).balanceOf(address(this)) ? IERC20(token).balanceOf(address(this)) : rewardAmount;
    IERC20(token).transfer(_winner, amount);
  }

  function getRewardAmount() public returns (uint256) {
    address[] memory path = new address[](3);
    path[0] = token;
    path[1] = WBNB;
    path[1] = BUSD;

    uint256[] memory rewardAmount = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E).getAmountsIn(rewardUSD * 10**18, path);
    return rewardAmount[0];
  }

  function settings(uint256 _reward) external onlyOwner {
    rewardUSD = _reward;
  }

  function transferOut(address _token) external onlyOwner {
    IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
  }

  function getRandomNumber() external view returns (uint256){
    return randomResult;
  }

  function transferOwnership(address _owner) external onlyOwner {
    owner = _owner;
  }
}
