pragma solidity >=0.4.25 <=0.5.0;

/**
 * @author Lee
 * @title KStarWallet V0.4
 * @dev see http://www.kstarlive.com
 * Additional Requirement & remaining implementaion 2018.11.28
 * 1. ERC 721고려
 * 2. 수수료 정산(오라클라이즈)
 * 3. Code Refactoring for gas reduction
 * 4. Controller가 업데이트 되었을 때 유저 지갑에 Owner 전환에 대한 업그레이드 코드
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
 * @title Ownable
 * @dev Ownership of the each user's KStarWallet
 */
contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}
 
/**
 * @title MultiOwnable
 * @dev Ownership of the each user's KStarWallet
 */
contract MultiOwnable {
    
    using SafeMath for uint256;

    address public root; // 혹시 몰라 준비해둔 superOwner 의 백업. 하드웨어 월렛 주소로 세팅할 예정.
    address public superOwner;
    mapping (address => bool) public owners;
    address[] public ownerList;

    // for changeSuperOwnerByDAO
    // mapping(address => mapping (address => bool)) public preSuperOwnerMap;
    mapping(address => address) public candidateSuperOwnerMap;


    event ChangedRoot(address newRoot);
    event ChangedSuperOwner(address newSuperOwner);
    event AddedNewOwner(address newOwner);
    event DeletedOwner(address deletedOwner);

    constructor() public {
        root = msg.sender;
        superOwner = msg.sender;
        owners[root] = true;

        ownerList.push(msg.sender);

    }

    modifier onlyRoot() {
        require(msg.sender == root, "Root privilege is required.");
        _;
    }

    modifier onlySuperOwner() {
        require(msg.sender == superOwner, "SuperOwner priviledge is required.");
        _;
    }

    modifier onlyOwner() {
        require(owners[msg.sender], "Owner priviledge is required.");
        _;
    }

    /**
     * @dev root 교체 (root 는 root 와 superOwner 를 교체할 수 있는 권리가 있다.)
     * @dev 기존 루트가 관리자에서 지워지지 않고, 새 루트가 자동으로 관리자에 등록되지 않음을 유의!
     */
    function changeRoot(address newRoot) onlyRoot public returns (bool) {
        require(newRoot != address(0), "This address to be set is zero address(0). Check the input address.");

        root = newRoot;

        emit ChangedRoot(newRoot);
        return true;
    }

    /**
     * @dev superOwner 교체 (root 는 root 와 superOwner 를 교체할 수 있는 권리가 있다.)
     * @dev 기존 superOwner 가 관리자에서 지워지지 않고, 새 superOwner 가 자동으로 관리자에 등록되지 않음을 유의!
     */
    function changeSuperOwner(address newSuperOwner) onlyRoot public returns (bool) {
        require(newSuperOwner != address(0), "This address to be set is zero address(0). Check the input address.");

        superOwner = newSuperOwner;

        emit ChangedSuperOwner(newSuperOwner);
        return true;
    }

    /**
     * @dev owner 들의 1/2 초과가 합의하면 superOwner 를 교체할 수 있다.
     */
    function changeSuperOwnerByDAO(address newSuperOwner) onlyOwner public returns (bool) {
        require(newSuperOwner != address(0), "This address to be set is zero address(0). Check the input address.");
        require(newSuperOwner != candidateSuperOwnerMap[msg.sender], "You have already voted for this account.");

        candidateSuperOwnerMap[msg.sender] = newSuperOwner;

        uint8 votingNumForSuperOwner = 0;
        uint8 i = 0;

        for (i = 0; i < ownerList.length; i++) {
            if (candidateSuperOwnerMap[ownerList[i]] == newSuperOwner)
                votingNumForSuperOwner++;
        }

        if (votingNumForSuperOwner > ownerList.length / 2) { // 과반수 이상이면 DAO 성립 => superOwner 교체
            superOwner = newSuperOwner;

            // 초기화
            for (i = 0; i < ownerList.length; i++) {
                delete candidateSuperOwnerMap[ownerList[i]];
            }

            emit ChangedSuperOwner(newSuperOwner);
        }

        return true;
    }

    function newOwner(address owner) onlySuperOwner public returns (bool) {
        require(owner != address(0), "This address to be set is zero address(0). Check the input address.");
        require(!owners[owner], "This address is already registered.");

        owners[owner] = true;
        ownerList.push(owner);

        emit AddedNewOwner(owner);
        return true;
    }

    function deleteOwner(address owner) onlySuperOwner public returns (bool) {
        require(owners[owner], "This input address is not a super owner.");
        delete owners[owner];

        for (uint256 i = 0; i < ownerList.length; i++) {
            if (ownerList[i] == owner) {
                ownerList[i] = ownerList[ownerList.length.sub(1)];
                ownerList.length = ownerList.length.sub(1);
                break;
            }
        }

        emit DeletedOwner(owner);
        return true;
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
 * @title KStarWallet 컨트롤러
 * @dev 지갑 잠금, KRC포인트 -> KSC Deposit, 
 *      Token transfer, 
 *      이더 송금, ERC20 토큰리스트 추가, 
 *      유저 월렛 생성 및 관리, 
 *      월렛 및 컨트롤러 락기능 등
 */
contract KStarWalletController {
    
    MultiOwnable multiOwner; // KStarCoin EOA 오너들 중 dApp용 Owner 추가 (해당 오너에게 토큰을 유저들에게 보낼 수 있도록 보유할 수 있도록 설정함)
    mapping(address => bool) public wallets; // 생성된 지갑들에 대한 현재 상태 (true : 사용 , false : 미사용)
    address[] public walletList; // 생성된 지갑의 리스트
    bool public operationLocked; // 현재 Controller의 작동 상태를 관리 (true : 정지상태, false : 작동상태)
    mapping(string => address) tokens; // 토큰 심볼별 ERC20 Address (eg. KSC -> 0x123123...., GTK -> 0x32322.... )
  
    /**
     * TokenDeposit 이벤트
     */
    event TokenDeposit(
        address indexed token,
        address spender,
        address indexed from,
        address indexed to,
        uint256 amount
    );
    
    /**
     * WithdrawEtherRequest 이벤트
     */
    event WithdrawEtherRequest(
        address indexed wallet,
        address indexed to,
        uint256 amount
    );
    
    /**
     * WithdrawTokenRequest 이벤트
     */
    event WithdrawTokenRequest(
        address indexed token,
        address indexed wallet,
        address indexed to,
        uint256 amount
    );

    /**
     * 전체 지갑 락 기능과 KStarCoin MultiOwnable 실행 권한 체크
     */
    modifier isValidAndOwner() {
        require(multiOwner.owners(msg.sender), "Only the owner can execute.");
        require(!operationLocked, "This controller is stopped.");
        _;
    }
    
    /**
     * 지갑 주소가 Zero Address 인지 체크
     */
    modifier walletIsNotZeroAddress(address _wallet) {
        require(_wallet != address(0), 'The wallet address cannot be a 0 address.');
        _;
    }
    
    /**
     * 토큰이 존재하는 토큰인지 체크
     */
    modifier tokenIsNotZeroAddress(string _tokenSymbol) {
        require(tokens[_tokenSymbol] != address(0), 'The token address cannot be a 0 address.');
        _;
    }
    
    /**
     * constructor 생성자
     *  전체 지갑 락 기능과 KStarCoin MultiOwnable 실행 권한 체크를 위해 KStarCoin 을 MultiOwnable 로 형변환
     */
    constructor(string _tokenSymbol, IERC20 _kStarToken) public {
        operationLocked = false;
        multiOwner = MultiOwnable(_kStarToken);
        addToken(_tokenSymbol, _kStarToken);
    }
    

    /**
     * KStarCoin 생태계에서 다른 토큰 지원을 위해 토큰을 추가하는 함수 
     */
    function addToken(
        string _tokenSymbol, 
        IERC20 _token
    )
        public
        isValidAndOwner 
        tokenIsNotZeroAddress(_tokenSymbol)
        returns
        (bool)
    {
        tokens[_tokenSymbol] = _token;
        return true;
    }
    
    /**
     * 토큰 업그레이드시 업그레이드 된 ERC20 컨트랙트로 업데이트 하기 위한 함수
     */
    function upgradeToken(
        string _tokenSymbol, 
        address _tokenNewAddr
    )
        public
        isValidAndOwner
        tokenIsNotZeroAddress(_tokenSymbol)
        returns
        (bool)
    {
        require(_tokenNewAddr != address(0), 'The new token address cannot be a 0 address.');
        
        tokens[_tokenSymbol] = _tokenNewAddr;
        return true;
    }
    
    /**
     * 현재 Controller 가 새로운 주소로 전환 시 기존 유저 지갑을 새로운 Controller를 바라보게 함.. (유저들 지갑에 Owner를 바꿈..)
     **/
    function controllerChange(
        address _newFactory
    ) 
        public 
        isValidAndOwner 
        returns 
        (bool) 
    {
        uint loop;
        for(loop = 0; loop < walletList.length; loop++){
            if(wallets[walletList[loop]]){
                KStarWallet(walletList[loop]).transferOwnership(_newFactory);
            }
        }
        
        return true;
    }

    /**
     * KStarLive 지갑을 생성해주는 함수
     */
    function createWallet() public isValidAndOwner returns (address) {
        KStarWallet wallet = new KStarWallet();
        
        wallets[wallet] = true;
        walletList.push(wallet);
        
        return wallet;
    }
    
    /**
     * 유저 월렛별 lock/unlock 기능
     */
    function lockWallet(
        address _wallet, 
        bool _lock
    ) 
        public
        isValidAndOwner
        walletIsNotZeroAddress(_wallet)
        returns
        (bool)
    {
        wallets[_wallet] = _lock;
        return true;
    }
    
    /**
     *  현재 Controller의 일부 기능을 잠그기 위한 함수
     */
    function operationChange(
        bool _val
    ) 
        public 
        isValidAndOwner 
        returns 
        (bool)
    {
       operationLocked = _val;
       
       return true;
    }
   
    /**
     *  유저 컨트랙트 지갑의 이더 보유량
     */
    function balanceOfEther(
       address _wallet
    )
        public
        view
        walletIsNotZeroAddress(_wallet)
        returns
        (uint256)
    {
       return address(_wallet).balance;
    }

    /**
     *  유저 컨트랙트 지갑의 토큰 보유량
     */
    function balanceOfToken(
       string _symbol, 
       address _wallet
    ) 
        public 
        view 
        tokenIsNotZeroAddress(_symbol)
        walletIsNotZeroAddress(_wallet)
        returns 
        (uint256) 
    {
       return IERC20(tokens[_symbol]).balanceOf(_wallet);
    }
    
   /**
    * 포탈에서 KRC -> KSC 산정후 수량을 유저 지갑에 넣기 위한 함수 
    **/
   function tokenDeposit(
        string _symbol, 
        address _from,
        address _wallet,
        uint256 _amount
    ) 
        public
        isValidAndOwner
        tokenIsNotZeroAddress(_symbol)
        walletIsNotZeroAddress(_wallet)
        returns 
        (bool ret)
    {
        ret = IERC20(tokens[_symbol]).transferFrom(_from, _wallet, _amount);
        emit TokenDeposit(tokens[_symbol], msg.sender, _from, _wallet, _amount);
        return ret;
    }
    
    /**
     * 유저의 지갑에 보유한 ERC20 토큰을 다른 내/외부 지갑 주소로 Transfer 하기 위한 call 함수 
     */
    function withdrawTokenRequest(
        string _symbol,
        address _to,
        address _wallet,
        uint256 _amount
    )
        public
        isValidAndOwner
        tokenIsNotZeroAddress(_symbol)
        walletIsNotZeroAddress(_wallet)
        returns
        (bool ret)
    {
        ret = KStarWallet(_wallet).withdrawToken(tokens[_symbol], _to, _amount);
        emit WithdrawTokenRequest(tokens[_symbol], _wallet, _to, _amount);  
        return ret;
    }
    
    /**
     * 유저의 지갑에 보유한 이더를 다른 내/외부 지갑 주소로 Transfer 하기 위한 call 함수 
     */
    function withdrawEtherRequest(
        address _wallet,
        address _to,
        uint256 _amount
    ) public isValidAndOwner returns (bool ret) {
        ret = KStarWallet(_wallet).withdrawEther(_to, _amount);
        emit WithdrawEtherRequest(_wallet, _to, _amount);
        return ret;
    }
    
    /**
     * 유저 지갑에 보유한 토큰별 수량을 알기 위한 밸런스 체크 함수 
     */
    function tokenBalance(
        string _symbol,
        address _wallet
    )
        public
        view
        tokenIsNotZeroAddress(_symbol)
        walletIsNotZeroAddress(_wallet)
        returns
        (uint256)
    {
        return IERC20(tokens[_symbol]).balanceOf(_wallet);
    }
   
    /**
     * 유저별 컨트랙트 지갑의 존재여부
     */
    function existWallet(
       address _wallet
    ) 
        public 
        view
        walletIsNotZeroAddress(_wallet)
        returns 
        (bool) 
    {
       return wallets[_wallet];
    }
   
    /**
     * 토큰 Address를 가져오기 위한 함수
     */
    function getTokenInfo(
        string _symbol
    ) 
        public 
        view 
        tokenIsNotZeroAddress(_symbol)
        returns 
        (address) 
    {
       return tokens[_symbol];
    }
}

/**
 * KStarLive Wallet 유저별 지갑
 * 유저별 토큰 지갑 실제로 실행은 Controller에서 실행하고 Owner의 권한은 Controller의 Address 임
 */
contract KStarWallet is Ownable {
   
   using SafeMath for uint256;
   
    /**
     *  유저 컨트랙트 지갑의 이더 보유량
     */
    function balanceOfEther() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * 토큰을 외/내부 지갑으로 이동하기 위한 함수 Controller를 통해서만 접근 가능함
     */  
    function withdrawToken(
        address _token,
        address _to,
        uint256 _amount
    ) 
        public 
        onlyOwner 
        returns 
        (bool) 
    {
        return IERC20(_token).transfer(_to, _amount);
    }

    /**
     * 이더를 외/내부 지갑으로 이동하기 위한 함수 Controller를 통해서만 접근 가능함
     */  
    function withdrawEther(
        address _to,
        uint256 _amount
    ) 
        public 
        onlyOwner 
        returns 
        (bool) 
    {
        require(address(this).balance.sub(_amount) >= 0, 'The balance of Ether is insufficient.');
        require(_to != address(0), 'The recipent address cannot be a 0 address.');
        
        address(_to).transfer(_amount);
        
        return true;
    }
    
    /**
     * 이더를 입금하기 위한 fallback 함수 Controller를 통해서만 접근 가능함
     */  
    function () public payable onlyOwner {
        require(msg.value > 0);
    }
   
}