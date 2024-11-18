// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

library SafeMath {
    function percent(uint value,uint numerator, uint denominator, uint precision) internal pure  returns(uint quotient) {
        uint _numerator  = numerator * 10 ** (precision+1);
        uint _quotient =  ((_numerator / denominator) + 5) / 10;
        return (value*_quotient/1000000000000000000);
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
   
    event Transfer(address indexed from, address indexed to, uint256 value);

   
    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

   
    function transfer(address to, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

   
    function approve(address spender, uint256 amount) external returns (bool);

   
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    
    function name() external view returns (string memory);

   
    function symbol() external view returns (string memory);

    
    function decimals() external view returns (uint8);
}

abstract contract Ownable is Context {
    address private _owner;

  
    error OwnableUnauthorizedAccount(address account);

    
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

   
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

   
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract ERC20 is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

   
    constructor(string memory name_, string memory symbol_) Ownable(msg.sender) {
        _name = name_;
        _symbol = symbol_;
    }

    
    function name() public view virtual override returns (string memory) {
        return _name;
    }

   
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

   
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

  


    function transfer(address to, uint256 amount) public virtual override returns (bool) {   
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

   
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

   
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

   
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

  
  

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

   
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
   
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

   
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


contract TOKEN is ERC20 {  


    uint256 public price = 7*1e17; // 0.07 usdt 
    uint256 public tokenSold;
    bool saleActive = true; 
    uint256 unlockDate = block.timestamp + 90 days; // after 3 months
    address public treasuryWallet = 0xe5C77Af24E80CF0D4e7749657ba0B776237F9B09;
    uint256 public numberOfParticipants = 0;

    struct userStruct{
        bool isExist;
        uint256 investment;
        uint256 lockedAmount;
    }
    mapping(address => userStruct) public user;

    Token USDT = Token(0xa7d7594Cf7A7FfCdD19F98b85d9D61AA2B19b768); // USDT Address
   
    constructor() ERC20("LifeCoin Carbon", "LCARBON"){

        uint256 totalSupply = 10000000000;        
        _mint(msg.sender, totalSupply * (10**decimals()));

    }    

    fallback() external  {
        revert();
    }  

    function mint(address account, uint256 amount) onlyOwner public{
        _mint( account,  amount);
    }

    function purchaseTokensWithUSDT(uint256 amount) public {
        require(saleActive == true,"Sale not active!"); 
        USDT.transferFrom(msg.sender,owner(),amount);
        user[msg.sender].investment = user[msg.sender].investment + amount;
        if(!user[msg.sender].isExist){
            numberOfParticipants = numberOfParticipants + 1;
        }
      
        amount = amount * 1e18;
        uint256 usdToTokens = SafeMath.div(amount, price);
        uint256 tokenAmountDecimalFixed = SafeMath.mul(usdToTokens,1e12);

        ////////////////////////////////////
        user[msg.sender].lockedAmount = user[msg.sender].lockedAmount + tokenAmountDecimalFixed;
        ////////////////////////////////////
        //transfer(msg.sender,tokenAmountDecimalFixed);
        tokenSold = tokenSold + tokenAmountDecimalFixed;   
    }

    function claimLockedTokens() public{
        require(unlockDate < block.timestamp,"unlock time not reached!");
        require(user[msg.sender].lockedAmount >= 0 ,"No Amount to Redeem!");

        transfer(msg.sender,user[msg.sender].lockedAmount);
        user[msg.sender].lockedAmount = 0;

    }

    function startStopSale(bool TorF) onlyOwner public{
       saleActive = TorF;
    }
   
    function updateTokenPrice(uint256 tokenPrice) onlyOwner public {
        price = tokenPrice;
    }

    function updateUnlockDate(uint256 dateTimeStamp) onlyOwner public {
        unlockDate = dateTimeStamp;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }


}

contract LCARBON is TOKEN{
     using SafeMath for uint256;

     struct userInvestmentStruct{
        uint256 stakedBal1;
        uint256 stakedBal2;
        uint256 stakedBal3;
        uint256 stakedBal4;

        uint256 stakeTime1;
        uint256 stakeTime2;
        uint256 stakeTime3;
        uint256 stakeTime4;

        uint256 lockTime1;  
        uint256 lockTime2;  
        uint256 lockTime3;  
        uint256 lockTime4;        
    }


    mapping(address => uint256) public rewardsBeforeNewStake1;
    mapping(address => uint256) public rewardsBeforeNewStake2;
    mapping(address => uint256) public rewardsBeforeNewStake3;
    mapping(address => uint256) public rewardsBeforeNewStake4;

    mapping(address => userInvestmentStruct) public userInvestment;  

    uint256 public amountStillInStake = 0;
    uint256 internal rewardInterval = 86400 * 1;
    uint256 public minimunStake1 = 1 *1e18;

    function getTime() internal view returns (uint256) {
        return block.timestamp;
    }

     function stake(uint256 amount, uint256 stakeType) external {
        require(amount >= minimunStake1, "Cannot stake less than minimum stake amount");  
        require(user[msg.sender].lockedAmount >= amount, "Cannot stake less than minimum stake amount");         

        user[msg.sender].lockedAmount = user[msg.sender].lockedAmount - amount;
        amountStillInStake = amountStillInStake + amount;

        if(stakeType == 1){
            if(userInvestment[msg.sender].stakedBal1 > 0){
                rewardsBeforeNewStake1[msg.sender] = IntervalRewardsOf(msg.sender,1);
            }
            userInvestment[msg.sender].stakedBal1 = userInvestment[msg.sender].stakedBal1 + amount;
            userInvestment[msg.sender].lockTime1 = getTime() + 30 days;        
        }
        else if(stakeType == 2){
            if(userInvestment[msg.sender].stakedBal2 > 0){
                rewardsBeforeNewStake2[msg.sender] = IntervalRewardsOf(msg.sender,2);
            }
            userInvestment[msg.sender].stakedBal2 = userInvestment[msg.sender].stakedBal2 + amount;
            userInvestment[msg.sender].lockTime2 = getTime() + 90 days; 
        }
        else if(stakeType == 3){
            if(userInvestment[msg.sender].stakedBal3 > 0){
                rewardsBeforeNewStake3[msg.sender] = IntervalRewardsOf(msg.sender,3);
            }
            userInvestment[msg.sender].stakedBal3 = userInvestment[msg.sender].stakedBal3 + amount;
            userInvestment[msg.sender].lockTime3 = getTime() + 365 days; 
        }       
        else if(stakeType == 4){
            if(userInvestment[msg.sender].stakedBal4 > 0){
                rewardsBeforeNewStake4[msg.sender] = IntervalRewardsOf(msg.sender,4);
            }
            userInvestment[msg.sender].stakedBal4 = userInvestment[msg.sender].stakedBal4 + amount;
            userInvestment[msg.sender].lockTime4 = getTime() + 730 days; 
        }
                

    }

    function IntervalRewardsOf(address account , uint256 plan) public view returns (uint256){
        if(plan == 1){
            uint256 amount = userInvestment[account].stakedBal1;
            uint256 timeDiff = getTime().sub(userInvestment[account].stakeTime1);
            uint256 intervals = timeDiff.div(rewardInterval);
            uint256 perIntervalReward = amount.div(3300); // 0.030% daily(approx)
            return intervals.mul(perIntervalReward);

        }else if(plan == 2){
            uint256 amount = userInvestment[account].stakedBal2;
            uint256 timeDiff = getTime().sub(userInvestment[account].stakeTime2);
            uint256 intervals = timeDiff.div(rewardInterval);
            uint256 perIntervalReward = amount.div(2000); // 0.5% daily
            return intervals.mul(perIntervalReward);

        }
        else if(plan == 3){
            uint256 amount = userInvestment[account].stakedBal3;
            uint256 timeDiff = getTime().sub(userInvestment[account].stakeTime3);
            uint256 intervals = timeDiff.div(rewardInterval);
            uint256 perIntervalReward = amount.div(1000); // 0.1% daily
            return intervals.mul(perIntervalReward);

        }else if(plan == 4){
            uint256 amount = userInvestment[account].stakedBal4;
            uint256 timeDiff = getTime().sub(userInvestment[account].stakeTime4);
            uint256 intervals = timeDiff.div(rewardInterval);
            uint256 perIntervalReward = amount.div(400); // 0.25% daily
            return intervals.mul(perIntervalReward);

        }else{
            return 0;
        }
        
    }  

    function unstake(uint256 plan) external{
        uint256 tokenAmount;
        if(plan == 1){
            require(userInvestment[msg.sender].stakedBal1 > 0, "Account does not have a balance staked");     

            tokenAmount = userInvestment[msg.sender].stakedBal1;
            if(amountStillInStake >= tokenAmount){
                amountStillInStake = amountStillInStake - tokenAmount;
            }
            if(userInvestment[msg.sender].lockTime1 > block.timestamp){
                tokenAmount = tokenAmount - tokenAmount.div(2); // 50% penality
                rewardsBeforeNewStake1[msg.sender] = 0 ;
                _transfer(address(this),msg.sender,tokenAmount);
            }
            else{
                withdrawReward(1);
                _transfer(address(this),msg.sender,tokenAmount);
            }
             
            userInvestment[msg.sender].stakedBal1 = 0;
            userInvestment[msg.sender].stakeTime1 = 0;
            userInvestment[msg.sender].lockTime1 = 0;
        }
        else if(plan == 2){
            require(userInvestment[msg.sender].stakedBal2 > 0, "Account does not have a balance staked");    

            tokenAmount = userInvestment[msg.sender].stakedBal2;
            if(userInvestment[msg.sender].lockTime2 > block.timestamp){
                tokenAmount = tokenAmount - tokenAmount.div(2); // 50% penality
                rewardsBeforeNewStake2[msg.sender] = 0 ;
                _transfer(address(this),msg.sender,tokenAmount);
            }
            else{
                withdrawReward(2);
                _transfer(address(this),msg.sender,tokenAmount);
            }
             
            userInvestment[msg.sender].stakedBal2 = 0;
            userInvestment[msg.sender].stakeTime2 = 0;
            userInvestment[msg.sender].lockTime2 = 0;

        }
        else if(plan == 3){
            require(userInvestment[msg.sender].stakedBal3 > 0, "Account does not have a balance staked");   

            tokenAmount = userInvestment[msg.sender].stakedBal3;
            if(userInvestment[msg.sender].lockTime3 > block.timestamp){
                tokenAmount = tokenAmount - tokenAmount.div(2); // 50% penality
                rewardsBeforeNewStake3[msg.sender] = 0 ;
                _transfer(address(this),msg.sender,tokenAmount);
            }
            else{ 
                withdrawReward(3);
                _transfer(address(this),msg.sender,tokenAmount);
            }
             
            userInvestment[msg.sender].stakedBal3 = 0;
            userInvestment[msg.sender].stakeTime3 = 0;
            userInvestment[msg.sender].lockTime3 = 0;

        }
        else if(plan == 4){
            require(userInvestment[msg.sender].stakedBal4 > 0, "Account does not have a balance staked");    

            tokenAmount = userInvestment[msg.sender].stakedBal4;
            if(userInvestment[msg.sender].lockTime4 > block.timestamp){
                tokenAmount = tokenAmount - tokenAmount.div(2); // 50% penality
                rewardsBeforeNewStake4[msg.sender] = 0 ;
                transfer(msg.sender,tokenAmount);
            }
            else{
                withdrawReward(4);
                transfer(msg.sender,tokenAmount);
            }
             
            userInvestment[msg.sender].stakedBal4 = 0;
            userInvestment[msg.sender].stakeTime4 = 0;
            userInvestment[msg.sender].lockTime4 = 0;

        }else{
            revert("Enter a Valid Plan!");
        }     

    }



    function withdrawReward(uint256 plan) public {
        uint256 rewards;
        uint256 timeDiff;
        uint256 intervals;
        if(plan == 1){
            rewards = IntervalRewardsOf(msg.sender,1);
            rewards = rewards + rewardsBeforeNewStake1[msg.sender]; 

            ////////////////////////////////////////////
            timeDiff = getTime().sub(userInvestment[msg.sender].stakeTime1);
            intervals = timeDiff.div(rewardInterval);
            userInvestment[msg.sender].stakeTime1 = userInvestment[msg.sender].stakeTime1 + (intervals.mul(86400));
            ///////////////////////////////////////////

            require(rewards > 0,"No rewards to withdraw");  
            transfer(msg.sender,rewards);

        }else if(plan == 2){
            rewards = IntervalRewardsOf(msg.sender,2);
            rewards = rewards + rewardsBeforeNewStake2[msg.sender]; 

            ////////////////////////////////////////////
            timeDiff = getTime().sub(userInvestment[msg.sender].stakeTime2);
            intervals = timeDiff.div(rewardInterval);
            userInvestment[msg.sender].stakeTime2 = userInvestment[msg.sender].stakeTime2 + (intervals.mul(86400));
            ///////////////////////////////////////////
             
            require(rewards > 0,"No rewards to withdraw");   
            transfer(msg.sender,rewards);


        }else if(plan == 3){
            rewards = IntervalRewardsOf(msg.sender,3);
            rewards = rewards + rewardsBeforeNewStake3[msg.sender]; 

            ////////////////////////////////////////////
            timeDiff = getTime().sub(userInvestment[msg.sender].stakeTime3);
            intervals = timeDiff.div(rewardInterval);
            userInvestment[msg.sender].stakeTime3 = userInvestment[msg.sender].stakeTime3 + (intervals.mul(86400));
            ///////////////////////////////////////////
             
            require(rewards > 0,"No rewards to withdraw");   
            transfer(msg.sender,rewards);


        }else if(plan == 4){
            rewards = IntervalRewardsOf(msg.sender,4);
            rewards = rewards + rewardsBeforeNewStake4[msg.sender]; 

            ////////////////////////////////////////////
            timeDiff = getTime().sub(userInvestment[msg.sender].stakeTime4);
            intervals = timeDiff.div(rewardInterval);
            userInvestment[msg.sender].stakeTime4 = userInvestment[msg.sender].stakeTime4 + (intervals.mul(86400));
            ///////////////////////////////////////////
             
            require(rewards > 0,"No rewards to withdraw");  
            transfer(msg.sender,rewards);

            
        }else{
            revert("Select a valid plan!");
        }

    }

    

    function removeStuckToken(address _address) external onlyOwner {
        require(
            IERC20(_address).balanceOf(address(this)) > 0,
            "Can't withdraw 0"
        );

        IERC20(_address).transfer(
            treasuryWallet,
            IERC20(_address).balanceOf(address(this))
        );
    }
     
    function updateMinimumStakeAmount(uint256 amount1) public onlyOwner{
        minimunStake1 = amount1;
    }   
}



abstract contract Token {
    function transferFrom(address sender, address recipient, uint256 amount) virtual external;
    function transfer(address recipient, uint256 amount) virtual external;
    function balanceOf(address account) virtual external view returns (uint256)  ;

}