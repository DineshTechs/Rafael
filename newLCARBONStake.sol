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


    uint256 public price = 75*1e16; // 0.75 usdt initial token price 
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
            user[msg.sender].isExist = true;
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

        _transfer(address(this), msg.sender, user[msg.sender].lockedAmount);
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

      struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 rewardCalcTime;
        uint256 lockTime;
        uint256 plan;

    }

    mapping(address => Stake[]) public stakes;
    mapping(uint256 => uint256) public rewardRates;
    mapping(uint256 => uint256) public lockTime;
    uint256 public amountStillInStake = 0;
    uint256 internal rewardInterval = 86400 * 1;


    constructor(){
        rewardRates[1] = 3300;    // 0.03% = amount/3300 =  per day reward
        rewardRates[2] = 2000;    // 0.05% = amount/2000 = per day reward
        rewardRates[3] = 1000; //   0.1% = amount/1000 = per day reward
        rewardRates[4] = 400; //   0.25% = amount/400 = per day reward

        lockTime[1] = block.timestamp + 30 days;
        lockTime[2] = block.timestamp + 90 days;
        lockTime[3] = block.timestamp + 365 days;
        lockTime[4] = block.timestamp + 730 days;
    }

    function stake(uint256 amount, uint256 _plan) external{
        require(amount > 0, 'Amount should be greater than 0');
        require(user[msg.sender].lockedAmount >= amount, "Cannot stake more than purchased amount");
        require(_plan < 5 && _plan > 0,"Invalid Plan");

        user[msg.sender].lockedAmount = user[msg.sender].lockedAmount - amount;
        amountStillInStake = amountStillInStake + amount;

        stakes[msg.sender].push(Stake({
        amount: amount,
        startTime: block.timestamp,
        rewardCalcTime: block.timestamp,
        lockTime: lockTime[_plan],
        plan: _plan
    }));

    }

    function unstakeAll() public {
        Stake[] memory userStakes = stakes[msg.sender];
        require(userStakes.length > 0, 'No active stakes');

        uint256 totalAmount = 0;
        uint256 reward = 0;

        // Loop through each stake, calculate reward, and add to total amount
        for (uint256 i = 0; i < userStakes.length; i++) {
            if(amountStillInStake >= userStakes[i].amount){
                amountStillInStake = amountStillInStake - userStakes[i].amount;
            }
            if(userStakes[i].lockTime > block.timestamp){
                totalAmount += userStakes[i].amount.div(2); // 50% penality and no rewards
            }
            else{
                reward = calculateSingleStakeReward(msg.sender,i);
                totalAmount += userStakes[i].amount + reward;
            }
            
         }

        // Clear all stakes for the user
        delete stakes[msg.sender];
        _transfer(address(this),msg.sender,totalAmount);

        
    }

    function calculateAllStakeRewards(address staker) public view returns (uint256) {
        Stake[] memory userStakes = stakes[staker];
        require(userStakes.length > 0, 'No active stakes');

        uint256 totalReward = 0;

        for (uint256 i = 0; i < userStakes.length; i++) {
            Stake memory stakeInfo = userStakes[i];
            uint256 timeDiff = block.timestamp - stakeInfo.rewardCalcTime;
            uint256 intervals = timeDiff.div(rewardInterval);
            uint256 perIntervalReward = stakeInfo.amount.div(rewardRates[stakeInfo.plan]); 
            uint256 reward = intervals.mul(perIntervalReward);
            totalReward += reward;
        }

        return totalReward;
    }
    
    function withdrawAllStakeReward(address staker) public{
        Stake[] memory userStakes = stakes[staker];
        require(userStakes.length > 0, 'No active stakes');

        uint256 totalReward = 0;

        for (uint256 i = 0; i < userStakes.length; i++) {
            Stake memory stakeInfo = userStakes[i];
            uint256 timeDiff = block.timestamp - stakeInfo.rewardCalcTime;
            stakeInfo.rewardCalcTime = block.timestamp;
            uint256 intervals = timeDiff.div(rewardInterval);
            uint256 perIntervalReward = stakeInfo.amount.div(rewardRates[stakeInfo.plan]); 
            uint256 reward = intervals.mul(perIntervalReward);
            totalReward += reward;
        }        
        _transfer(address(this),msg.sender,totalReward);
        //stakeInfo.rewardCalcTime = block.timestamp;
        //return totalReward;

    }

    function unstakeSingleStake(uint256 index) public {
        require(index < stakes[msg.sender].length, 'Invalid index');

        Stake memory stakeInfo = stakes[msg.sender][index];

        if(amountStillInStake >= stakeInfo.amount){
                amountStillInStake = amountStillInStake - stakeInfo.amount;
        }

        if(stakeInfo.lockTime > block.timestamp){
            _transfer(address(this),msg.sender,stakeInfo.amount.div(2)); // 50% penality and no rewards
        }
        else{
            uint256 reward = calculateSingleStakeReward(msg.sender,index);
            uint256 totalAmount = stakeInfo.amount + reward;
            _transfer(address(this),msg.sender,totalAmount);
        }               

        // Remove the stake from the array by swapping and popping
        stakes[msg.sender][index] = stakes[msg.sender][stakes[msg.sender].length - 1];
        stakes[msg.sender].pop();

    }

    function calculateSingleStakeReward(address staker,uint256 index) internal view returns (uint256) {
            Stake memory stakeInfo = stakes[staker][index];
            uint256 timeDiff = block.timestamp - stakeInfo.rewardCalcTime;
            uint256 intervals = timeDiff.div(rewardInterval);
            uint256 perIntervalReward = stakeInfo.amount.div(rewardRates[stakeInfo.plan]); 
            uint256 reward = intervals.mul(perIntervalReward);
            return reward;
    }

    function withdrawSingleStakeReward(address staker,uint256 index) public{
            require(index < stakes[msg.sender].length, 'Invalid index');

            Stake memory stakeInfo = stakes[staker][index];
            uint256 timeDiff = block.timestamp - stakeInfo.rewardCalcTime;
            uint256 intervals = timeDiff.div(rewardInterval);
            uint256 perIntervalReward = stakeInfo.amount.div(rewardRates[stakeInfo.plan]); 
            uint256 reward = intervals.mul(perIntervalReward);

             _transfer(address(this),msg.sender,reward);
             stakeInfo.rewardCalcTime = block.timestamp;

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
      
}



abstract contract Token {
    function transferFrom(address sender, address recipient, uint256 amount) virtual external;
    function transfer(address recipient, uint256 amount) virtual external;
    function balanceOf(address account) virtual external view returns (uint256)  ;

}