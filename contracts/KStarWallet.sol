pragma solidity >=0.4.25 <=0.5.0;

/**
 * @author Lee
 * @title KStarWallet
 * @dev see http://www.kstarlive.com
 */

import './KStarCoin.sol';

/**
 * @title KStarLive Wallet Factory
 * @dev 사용자 지갑 생성, 사용자 지갑으로 KRC 포인트 > KSC Deposit (1일 1회 제한), ID 별로 지갑 조회 및 KSC 및 이더 보유 현황 조회
 *      (향후 non-zero , zero 에 대한 부분 고려하여 GAS비 절감)
 */
contract KStarWalletFactory is KSCReceiver {
    
    KStarCoin token;
    string private userId_;
    string private userNm_;
    mapping(string => address) wallets;
    bool public operationLocked;

    /**
     * @title Deposit 이벤트
     * @dev KRC > KSC 전환시 유저 지갑에 KSC Deposit
     */
    event Deposit(
       address indexed owner, 
       address indexed to, 
       string indexed userId, 
       uint256 amount,
       address token
    );
    
    /**
     * @title LogOnReceivedKSC 이벤트
     * @dev 컨트랙트가 KSC를 받을 수 있는지 체크
     */
    event LogOnReceivedKSC(
       string message, 
       address indexed owner, 
       address indexed spender, 
       uint256 value, 
       KSCReceiveType receiveType
    );
    
    /**
     * @title isValidOrOWner() 
     * @dev 전체 지갑 락 기능과 KStarCoin MultiOwnable 실행 권한 체크
     */
    modifier isValidOrOwner() {
        require(!operationLocked);
        require(token.owners(msg.sender));
        _;
    }
    
    /**
     * @title constructor 생성자
     * @param KStarCoin Address
     * @dev 전체 지갑 락 기능과 KStarCoin MultiOwnable 실행 권한 체크
     */
    constructor(KStarCoin _token) public {
        operationLocked = false;
        token = _token;
    }
    
    /**
     * @title upgradeToken()
     * @param KStarCoin Address
     * @dev KStarCoin 버전 업그레이드 시 지갑에도 버전 업그레이드를 진행함
     */
    function upgradeToken(KStarCoin _token) public isValidOrOwner() returns (bool) {
        token = _token;
        return true;
    }

    /**
     * @title createWallet()
     * @param 포탈 유저아이디, 포탈 유저명
     * @dev KStarLive Media 웹의 회원정보(유저ID, 유저명)으로 KStarWallet 컨트랙트 지갑을 생성함
     */
    function createWallet( string _userId, string _userNm) public isValidOrOwner() {
        require(wallets[_userId] == address(0));
    
        wallets[_userId] = new KStarWallet(_userId, _userNm);
    }

    /**
     * @title createWallet()
     * @param 포탈 유저아이디
     * @dev KStarLive Media 웹의 회원정보(유저ID)으로 KStarWallet 컨트랙트 지갑 주소를 불러옴
     */
    function getWallet(string _userId) public view returns (address) {
        return wallets[_userId];
    }
    
    /**
     * @title deposit (오너만 실행 가능함)
     * @param 포탈 유저아이디, KSC 양
     * @dev KRC > KSC 전환시 유저 지갑에 KSC Deposit
     *      KStarCoin 어드레스 타입의 call 을 사용함 (현재 지갑 msg.sender > 유저 지갑에 토큰을 전달함)
     *      이 기능을 사용하기 위해선 현재 컨트랙트에서 KStarCoin을 보유해야 함
     * Testing!!!!
     */
    function deposit(string _userId, uint256 _amount) public isValidOrOwner() returns (bool) {
       require(token.balanceOf(address(this)) >= _amount, 'The balance of msg.sender is insufficient.');
       
       bool retVal = address(token).call(
           bytes4(keccak256("transfer(address,uint256)")), // Testing 중 (향후 kscTransfer로 옮겨야함)
           wallets[_userId], 
           _amount
       );
       emit Deposit(address(this), wallets[_userId], _userId, _amount, token);
       
       return retVal;
   }
   
   /**
     * @title balanceOfFactory()
     * @dev 현재 컨트랙트의 토큰 밸런스를 확인함
     */
   function balanceOfFactory() public view returns (uint256) {
       return token.balanceOf(address(this));
   }
   
   /**
     * @title operationChange() 오너만 실행 가능함
     * @param 락과 언락 불리언 값
     * @dev 현재 전체 지갑의 락상태를 결정하기 위함
     */
   function operationChange(bool _val) public isValidOrOwner() returns (bool) {
       
       operationLocked = _val;
       
       return true;
   }
   
   /**
     * @title balanceOfEther()
     * @param 유저 아이디
     * @dev 유저 컨트랙트 지갑의 이더 보유량
     */
   function balanceOfEther(string userId) public view returns (uint256) {
       require(wallets[userId] != address(0));
       return address(wallets[userId]).balance;
   }

    /**
     * @title balanceOfToken()
     * @param 유저 아이디
     * @dev 유저 컨트랙트 지갑의 KSC 토큰 보유량
     */
   function balanceOfToken(string userId) public view returns (uint256) {
       require(wallets[userId] != address(0));
       return token.balanceOf(wallets[userId]);
   }
   
   /**
     * @title existWallet()
     * @param 유저 아이디
     * @dev 유저 컨트랙트 지갑의 존재여부
     */
   function existWallet(string userId) public view returns (bool) {
       return (wallets[userId] != address(0));
   }
   
   /**
     * @title onKSCReceived()
     * @dev 컨트랙트에서 KSC 를 받을 수 있는 상태인지 체크하기 위함... (KStarCoin -> kscTransferFrom...)
     */
   function onKSCReceived(address owner, address spender, uint256 value, KSCReceiveType receiveType) public returns (bool) {
        emit LogOnReceivedKSC("I received KstarCoin.", owner, spender, value, receiveType);
        return true;
   }
    
}


/**
 * @title KStarLive Wallet 유저별 지갑
 * @dev 외부로 토큰 및 이더 송금, 본인 지갑과 미디어 웹 정보(유저아이디, 사용자명) 조회, 지갑의 토큰 및 이더 밸런스 확인
 *      (향후 non-zero , zero 에 대한 부분 고려하여 GAS비 절감)
 *      (사용자 일일 출금 제한을 위해 함수제어자 추가 예정...)
 */
contract KStarWallet is KSCReceiver {
   
   string private _userId;
   string private _userNm;
   
   /**
    * @title WithdrawEther 이벤트
    * @dev Ether 외부 출금 시 로그
    */
    event WithdrawEther(

    );
   
    /**
     * @title WithdrawToken 이벤트
     * @dev KSC 외부 출금 시 로그..
     */
   event WithdrawToken(
        address spender,
        address from,
        address to,
        uint256 amount,
        string userId
    );
    
    /**
     * @title LogOnReceivedKSC 이벤트
     * @dev KSC 외부 출금 시 로그..
     */
   event LogOnReceivedKSC(
       string message, 
       address indexed owner, 
       address indexed spender, 
       uint256 value, 
       KSCReceiveType receiveType
    );
   
   /**
    * @title 생성자 
    * @param 유저아이디, 유저이름
    * @dev 미디어 웹 사용자 이름 상태변수에 저장
    */
   constructor (string _userId_, string _userNm_) public {
       _userId = _userId_;
       _userNm = _userNm_;
   }
   
   /**
    * @title fallback() 함수 payable
    * @dev 컨트랙트에 이더를 입금하기..
    */
   function () public payable {
       require(msg.value > 0);
   }
   
   // 팩토리에서 실행 및 관리할지 유저지갑별로 할지 고민중..
   function withdrawToken(KStarCoin _token, address _to, uint256 _amount) public returns (bool)  {
       require(_token.owners(msg.sender), 'msg.sender is not an owner of them');
       require(_to != address(0), 'recipent address can not be 0x.');
       require(_token.balanceOf(address(this)) >= _amount, 'The balance of your wallet is insufficient.');
       
       address(_token).call(
           bytes4(keccak256("kscApprove(address, uint256, string)")), 
           msg.sender,
           _amount,
           _userId
       );
       
       bool retVal = _token.kscTransferFrom(address(this), address(_to), _amount, _userId);
       
       emit WithdrawToken(msg.sender, address(this), address(_to), _amount, _userId);
       
       return retVal;
   }
   
   // 팩토리에서 실행 및 관리할지 유저지갑별로 할지 고민중..
   function withdrawEther(KStarCoin _token, address _to, uint256 _wei) public returns (bool) {
      require(_token.owners(msg.sender), 'msg.sender is not an owner of them');
      require(address(this).balance >= _wei);
      
      address(_to).transfer(_wei);
      
      return true;
   }
   
   /**
     * @title balanceOfEther()
     * @param 유저 아이디
     * @dev 유저 컨트랙트 지갑의 이더 보유량
     */
   function balanceOfEther() public view returns (uint256) {
       return address(this).balance;
   }

    /**
     * @title balanceOfToken()
     * @param 유저 아이디
     * @dev 유저 컨트랙트 지갑의 KSC 토큰 보유량
     */
   function balanceOfToken(KStarCoin _token) public view returns (uint256) {
       require(_token != address(0));
       return _token.balanceOf(this);
   }
   
   /**
     * @title createWallet()
     * @dev KStarLive Media 웹의 회원정보(유저ID, 유저명)을 불러옴
     */
   function getWalletInfo() public view returns (string, string) {
       return (_userId, _userNm);
   }
   
   /**
     * @title onKSCReceived()
     * @dev 컨트랙트에서 KSC 를 받을 수 있는 상태인지 체크하기 위함... (KStarCoin -> kscTransferFrom...)
     */
   function onKSCReceived(address owner, address spender, uint256 value, KSCReceiveType receiveType) public returns (bool) {
        emit LogOnReceivedKSC("I received KstarCoin.", owner, spender, value, receiveType);
        return true;
   }
  
}