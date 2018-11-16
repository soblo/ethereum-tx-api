pragma solidity ^0.4.25;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title KStarLive Quiz Contract
 * @dev see http://www.kstarlive.com
 */

contract KStarLiveQuiz {
  bytes32 public correctAnswerDoubleHash;
  uint256 public prize;
  address[] public winners;
  IERC20 token;
  address public admin;

  constructor (address _token, string _correctAnswerHash, uint256 _prize) public {
    token = IERC20(_token);
    correctAnswerDoubleHash = keccak256(abi.encodePacked(_correctAnswerHash));
    prize = _prize;
    admin = msg.sender;
  }

  modifier onlyAdmin() {
      require(msg.sender == admin);
      _;
  }

  function getNumOfWinners() public view returns(uint)
  {
    return winners.length;
  }

  function submitAnswer (address _participant, string _answerHash) public onlyAdmin returns(bool)
  {
    if (keccak256(abi.encodePacked(_answerHash)) == correctAnswerDoubleHash) {
        winners.push(_participant);
        token.transferFrom(admin, _participant, prize);
        return true;
    }
    else {
        return false;
    }
  }
}
