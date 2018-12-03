pragma solidity >=0.4.25 <=0.5.0;

/**
 * @author Lee
 * @title KStarWallet V0.4
 * @dev see http://www.kstarlive.com
 * Additional Requirement & remaining implementaion 2018.12.03
 * 1. 수수료 정산(via the KyberNetwork API with KSC/BTC or KSC/ETH etc...)
 */

/**
 * @title SafeMath
 * @dev this is an arithmetic operation for safety.
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
 
/**
 * @title MultiOwnable
 * @dev Ownership of the each user's KStarWallet
 */
contract MultiOwnable {
    
  mapping(address => bool) internal owners;
  address internal privilegedUser;
  
  event OwnershipRenounced(
      address indexed previousUser,
      address indexed newUser
  );

  constructor() public {
    owners[msg.sender] = true;
  }

  modifier privilegedOwner() {
    require(owners[msg.sender] || privilegedUser == msg.sender);
    _;
  }
  
  modifier onlyMultiOwner() {
    require(owners[msg.sender]);
    _;
  }
  
  function addOwner(address _newOwner) public onlyMultiOwner {
      require(_newOwner != address(0) && !owners[_newOwner]);
      
      owners[_newOwner] = true;
  }

  function removeOwner(address _owner) public onlyMultiOwner {
    require(_owner != address(0)  && owners[msg.sender]);
    owners[_owner] = false;
  }

  function renounceUserOwnership(address _newPrivileged) public privilegedOwner {
    emit OwnershipRenounced(msg.sender, _newPrivileged);
    privilegedUser = _newPrivileged;
  }
  
  function getPrivildgedUser() public view onlyMultiOwner returns (address) {
      return privilegedUser;
  }
  
  function getOwnerOf(address _owner) public view onlyMultiOwner returns (bool) {
      return owners[_owner];
  }
  
}

/**
 * @title IERC20 standard interface
 * @dev 범용적 컨트랙트 지갑을 위한 ERC20 표준 인터페이스
 */
contract IERC20 {
  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function allowance(address owner, address spender)
    public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value)
    public returns (bool);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);
}

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 *
 * @dev 대체 불가능한 (Non-Fungible) 토큰 규약 ERC721 에 따른 인터페이스 선언
 */
contract IERC721 {
  
  bytes4 private constant InterfaceId_ERC721 = 0x80ac58cd;

  bytes4 private constant InterfaceId_ERC721Exists = 0x4f558e79;

  function balanceOf(address _owner) public view returns (uint256 _balance);

  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  
  function exists(uint256 _tokenId) public view returns (bool _exists);

  function approve(address _to, uint256 _tokenId) public;

  function getApproved(uint256 _tokenId)
    public view returns (address _operator);

  function setApprovalForAll(address _operator, bool _approved) public;

  // _owner 의 모든 토큰에 대한 접근 권한이 _operator 에게 있는지를 체크
  function isApprovedForAll(address _owner, address _operator)
    public view returns (bool);

 // 본인의 혹은 접근 가능한 _tokenId 토큰을 _from 에서 _to 로 넘김
  function transferFrom(address _from, address _to, uint256 _tokenId) public;

  // _to 가 콘트랙트 주소인 경우에는 ERC721Receiver 의 onERC721Received 함수가 존재하는지를 체크한 후에 토큰을 넘김.
  function safeTransferFrom(address _from, address _to, uint256 _tokenId)
    public;
    
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data)
    public;
}


/**
 * @title ERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface ERC165 {

  /**
   * @notice Query if a contract implements an interface
   * @param _interfaceId The interface identifier, as specified in ERC-165
   * @dev Interface identification is specified in ERC-165. This function
   * @dev  uses less than 30,000 gas.
   */
  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);
}

/**
 * @title SupportsInterfaceWithLookup
 * @author Matt Condon (@shrugs)
 * @dev Implements ERC165 using a lookup table.
 */
contract SupportsInterfaceWithLookup is ERC165 {

  bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;
  /**
   * 0x01ffc9a7 ===
   *   bytes4(keccak256('supportsInterface(bytes4)'))
   */

  /**
   * @dev a mapping of interface id to whether or not it's supported
   */
  mapping(bytes4 => bool) internal supportedInterfaces;

  /**
   * @dev A contract implementing SupportsInterfaceWithLookup
   * @dev  implement ERC165 itself
   */
  constructor()
    public
  {
    _registerInterface(InterfaceId_ERC165);
  }

  /**
   * @dev implement supportsInterface(bytes4) using a lookup table
   */
  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool)
  {
    return supportedInterfaces[_interfaceId];
  }

  /**
   * @dev private method for registering an interface
   */
  function _registerInterface(bytes4 _interfaceId)
    internal
  {
    require(_interfaceId != 0xffffffff);
    supportedInterfaces[_interfaceId] = true;
  }
  
}

contract WalletEvent {
    
    event KswErc20Transfer(
        address _token,
        address indexed _from,
        address indexed _to,
        uint256 _amount
    );
    
    event KswErc20TransferFrom(
        address _token,
        address indexed _spender,
        address indexed _from,
        address indexed _to,
        uint256 _amount
    );
    
    event KswErc20Approve(
        address _token,
        address indexed _from,
        address indexed _spender,
        uint256 _amount
    );
    
    event KswApproveToken721(
        address _token,
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    
    event KswApprovalForAllToken721(
        address _token,
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );
    
    event KswTransferToken721From(
        address _token,
        address indexed _spender,
        address indexed _from,
        address indexed _to,
        uint256 _tokenId
    );
    
    event KswSafeTransferToken721From(
        address _token,
        address indexed _spender,
        address indexed _from,
        address indexed _to,
        uint256 _tokenId,
        bytes _data
    );
}


/**
 * KStarLive Wallet 유저별 지갑
 */
contract KStarWallet is MultiOwnable, WalletEvent, SupportsInterfaceWithLookup {
   
    using SafeMath for uint256;
    
    bytes4 private constant InterfaceId_ERC721 = 0x80ac58cd;
    bytes4 private constant InterfaceId_ERC721Exists = 0x4f558e79;
   
    constructor () public {
       owners[msg.sender] = true;
       
       _registerInterface(InterfaceId_ERC721);
       _registerInterface(InterfaceId_ERC721Exists);
    }
   
    /**
     * 토큰을 외/내부 지갑으로 이동하기 위한 함수
     */  
    function kswToken20Transfer(
        address _token,
        address _to,
        uint256 _amount
    ) 
        public 
        privilegedOwner 
        returns 
        (bool retVal) 
    {
        retVal = IERC20(_token).transfer(_to, _amount);
        emit KswErc20Transfer(_token, address(this), _to, _amount);
        return retVal;
    }
    
    function kswToken20Approve(
        address _token,
        address _spender,
        uint256 _amount
    ) 
        public 
        privilegedOwner 
        returns 
        (bool retVal) 
    {
        retVal = IERC20(_token).approve(_spender, _amount);
        emit KswErc20Approve(_token, address(this), _spender, _amount);
        return retVal;
    }
    
    function kswToken20TransferFrom(
        address _token,
        address _owner,
        address _to,
        uint256 _amount
    )
        public
        privilegedOwner
        returns
        (bool retVal)
    {
        retVal = IERC20(_token).transferFrom(address(_owner), address(_to), _amount);
        emit KswErc20TransferFrom(_token, address(this), address(_owner), address(_to), _amount);
        return retVal;
    }
    
    function kswTotalSupplyOfToken20(
        address _token
    ) 
        public 
        view 
        returns 
        (uint256) 
    {
        return IERC20(_token).totalSupply();    
    }
    
    function kswAllowanceOfToken20(
        address _token,
        address _from,
        address _spender
    )
        public
        view
        returns
        (uint256)
    {
        return IERC20(_token).allowance(_from, _spender);
    }
    
    function kswBalanceOfToken20(
        address _token
    ) 
        public
        view
        returns
        (uint256)
    {
        return IERC20(_token).balanceOf(address(this));
    }
    
    function kswBalanceOfToken721(
        address _token
    )
        public
        view
        returns
        (uint256)
    {
        return IERC721(_token).balanceOf(address(this));
    }
    
    function kswOwnerOfToken721(
        address _token,
        uint256 _tokenId
    ) 
        public 
        view 
        returns 
        (address)
    {
        return IERC721(_token).ownerOf(_tokenId);
    }
    
    function kswExistsToken721(
        address _token,
        uint256 _tokenId
    )
        public
        view
        returns
        (bool)
    {
        return IERC721(_token).exists(_tokenId);        
    }
    
    function kswApproveToken721(
        address _token,
        address _to,
        uint256 _tokenId
    ) 
        public 
        privilegedOwner
        returns
        (bool)
    {
        IERC721(_token).approve(_to, _tokenId);
        emit KswApproveToken721(_token, address(this), address(_to), _tokenId);
        return true;
    }
    
    function kswGetApprovedForToken721(
        address _token,
        uint256 _tokenId
    )
        public
        view
        returns
        (address)
    {
        return IERC721(_token).getApproved(_tokenId);
    }
    
    function kswSetApprovalForAllToken721(
        address _token,
        address _operator,
        bool _approved
    ) 
        public
        privilegedOwner
        returns
        (bool)
    {
        IERC721(_token).setApprovalForAll(_operator, _approved);
        emit KswApprovalForAllToken721(_token, address(this), address(_operator), _approved);
        return true;
    }
    
    function kswIsApprovedForAllToken721(
        address _token,
        address _operator
    )
        public
        view
        returns
        (bool)
    {
        return IERC721(_token).isApprovedForAll(address(this), _operator);
    }
    
    function kswTransferToken721From(
        address _token,
        address _owner,
        address _to,
        uint256 _tokenId
    )
        public
        privilegedOwner
        returns
        (bool)
    {
        IERC721(_token).transferFrom(_owner, _to, _tokenId);
        emit KswTransferToken721From(_token, address(this), _owner, address(_to), _tokenId);
        return true;
    }
    
    function kswSafeTransferToken721From(
        address _token,
        address _owner,
        address _to,
        uint256 _tokenId,
        bytes _data
    ) 
        public
        privilegedOwner
        returns
        (bool)
    {
        IERC721(_token).safeTransferFrom(_owner, _to, _tokenId, _data);
        emit KswSafeTransferToken721From(_token, address(this), _owner, address(_to), _tokenId, _data);
        return true;
    }
    
    /**
     * 이더를 입금하기 위한 fallback 함수 
     */  
    function () public payable {
        require(msg.value > 0);
    }

    /**
     *  유저 컨트랙트 지갑의 이더 보유량
     */
    function kswBalanceOfEther() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * 이더를 외/내부 지갑으로 이동하기 위한 함수
     */  
    function kswEtherTransfer(
        address _to,
        uint256 _amount
    ) 
        public 
        privilegedOwner
        returns 
        (bool) 
    {
        require(address(this).balance.sub(_amount) >= 0, 'The balance of Ether is insufficient.');
        require(_to != address(0), 'The recipent address cannot be a 0 address.');
        
        address(_to).transfer(_amount);
        
        return true;
    }

}