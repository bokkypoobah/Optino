pragma solidity ^0.6.3;

// ----------------------------------------------------------------------------
// BokkyPooBah's Vanilla Optino 📈 + Factory v0.95-pre-release
//
// Status: Work in progress
//
// A factory to conveniently deploy your own source code verified ERC20 vanilla
// european optinos and the associated collateral optinos
//
// OptinoToken deployment on Ropsten: 0xEd35a0cb41CFAf5a9085541bA7a7A7DA2ca1EF86
// BokkyPooBahsVanillaOptinoFactory deployment on Ropsten: 0x6eF99cf7Af60e8c65907c8d4B1E7813ADeeB6705
//
// https://optino.xyz
//
// https://github.com/bokkypoobah/Optino
//
// TODO:
// * optimise
// * test/check, especially decimals
//
// Note: If you deploy this contract, or derivatives of this contract, please
// forward 50% of the fees you earn from this code to bokkypoobah.eth
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2020. The MIT Licence.
// ----------------------------------------------------------------------------

// import "BokkyPooBahsDateTimeLibrary.sol";
// pragma solidity ^0.6.3;

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.01
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.
// ----------------------------------------------------------------------------

// Only relevant parts included
library BokkyPooBahsDateTimeLibrary {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }
}


// ----------------------------------------------------------------------------
// CloneFactory.sol
// From
// https://github.com/optionality/clone-factory/blob/32782f82dfc5a00d103a7e61a17a5dedbd1e8e9d/contracts/CloneFactory.sol
// ----------------------------------------------------------------------------

/*
The MIT License (MIT)

Copyright (c) 2018 Murray Software, LLC.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//solhint-disable max-line-length
//solhint-disable no-inline-assembly

contract CloneFactory {

  function createClone(address target) internal returns (address result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x37)
    }
  }

  function isClone(address target, address query) internal view returns (bool result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
      mstore(add(clone, 0xa), targetBytes)
      mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

      let other := add(clone, 0x40)
      extcodecopy(query, other, 0, 0x2d)
      result := and(
        eq(mload(clone), mload(other)),
        eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
      )
    }
  }
}


// ----------------------------------------------------------------------------
// Utils
// ----------------------------------------------------------------------------
library Utils {
    bytes constant CALL = "VCO";
    bytes constant PUT = "VPO";
    bytes constant CALLNAME = "Vanilla Call Optino";
    bytes constant PUTNAME = "Vanilla Put Optino";
    bytes constant COLLATERAL = "C";
    bytes constant COLLATERALNAME = "Collateral";
    uint8 constant SPACE = 32;
    uint8 constant DASH = 45;
    uint8 constant DOT = 46;
    uint8 constant ZERO = 48;
    uint8 constant COLON = 58;
    uint8 constant CHAR_T = 84;
    uint8 constant CHAR_Z = 90;

    function _numToBytes(uint strike, uint decimals) internal pure returns (bytes memory b) {
        uint i;
        uint j;
        uint result;
        b = new bytes(40);
        if (strike == 0) {
            b[j++] = byte(ZERO);
        } else {
            i = decimals + 18;
            do {
                uint num = strike / 10 ** i;
                result = result * 10 + num % 10;
                if (result > 0) {
                    b[j++] = byte(uint8(num % 10 + ZERO));
                    if (j > 1 && (strike % num) == 0 && i <= decimals) {
                        break;
                    }
                } else {
                    if (i == decimals) {
                        b[j++] = byte(ZERO);
                        b[j++] = byte(DOT);
                    }
                    if (i < decimals) {
                        b[j++] = byte(ZERO);
                    }
                }
                if (decimals != 0 && decimals == i && result > 0 && i > 0) {
                    b[j++] = byte(DOT);
                }
                i--;
            } while (i >= 0);
        }
    }
    function _dateTimeToBytes(uint timestamp) internal pure returns (bytes memory b) {
        (uint year, uint month, uint day, uint hour, uint min, uint sec) = BokkyPooBahsDateTimeLibrary.timestampToDateTime(timestamp);

        b = new bytes(20);
        uint i;
        uint j;
        uint num;

        i = 4;
        do {
            i--;
            num = year / 10 ** i;
            b[j++] = byte(uint8(num % 10 + ZERO));
        } while (i > 0);
        b[j++] = byte(DASH);
        i = 2;
        do {
            i--;
            num = month / 10 ** i;
            b[j++] = byte(uint8(num % 10 + ZERO));
        } while (i > 0);
        b[j++] = byte(DASH);
        i = 2;
        do {
            i--;
            num = day / 10 ** i;
            b[j++] = byte(uint8(num % 10 + ZERO));
        } while (i > 0);
        b[j++] = byte(CHAR_T);
        i = 2;
        do {
            i--;
            num = hour / 10 ** i;
            b[j++] = byte(uint8(num % 10 + ZERO));
        } while (i > 0);
        b[j++] = byte(COLON);
        i = 2;
        do {
            i--;
            num = min / 10 ** i;
            b[j++] = byte(uint8(num % 10 + ZERO));
        } while (i > 0);
        b[j++] = byte(COLON);
        i = 2;
        do {
            i--;
            num = sec / 10 ** i;
            b[j++] = byte(uint8(num % 10 + ZERO));
        } while (i > 0);
        b[j++] = byte(CHAR_Z);
    }
    function _toSymbol(bool cover, uint callPut, uint id) internal pure returns (string memory s) {
        bytes memory b = new bytes(64);
        uint i;
        uint j;
        uint num;
        if (callPut == 0) {
            for (i = 0; i < CALL.length; i++) {
                b[j++] = CALL[i];
            }
        } else {
            for (i = 0; i < PUT.length; i++) {
                b[j++] = PUT[i];
            }
        }
        if (cover) {
            for (i = 0; i < COLLATERAL.length; i++) {
                b[j++] = COLLATERAL[i];
            }
        }
        i = 8;
        do {
            i--;
            num = id / 10 ** i;
            b[j++] = byte(uint8(num % 10 + ZERO));
        } while (i > 0);
        s = string(b);
    }
    function _toName(string memory description, bool cover, uint callPut, uint expiry, uint strike, uint decimals) internal pure returns (string memory s) {

        bytes memory b = new bytes(128);
        uint i;
        uint j;
        if (callPut == 0) {
            for (i = 0; i < CALLNAME.length; i++) {
                b[j++] = CALLNAME[i];
            }
        } else {
             for (i = 0; i < PUTNAME.length; i++) {
                b[j++] = PUTNAME[i];
            }
        }
        b[j++] = byte(SPACE);

        if (cover) {
            for (i = 0; i < COLLATERALNAME.length; i++) {
                b[j++] = COLLATERALNAME[i];
            }
            b[j++] = byte(SPACE);
        }

        bytes memory _description = bytes(description);
        for (i = 0; i < _description.length; i++) {
            b[j++] = _description[i];
        }
        b[j++] = byte(SPACE);

        bytes memory b1 = _dateTimeToBytes(expiry);
        for (i = 0; i < b1.length; i++) {
            b[j++] = b1[i];
        }
        b[j++] = byte(SPACE);

        bytes memory b2 = _numToBytes(strike, decimals);
        for (i = 0; i < b2.length; i++) {
            b[j++] = b2[i];
        }
        s = string(b);
    }
}


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function _add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a, "SafeMath._add: Overflow");
    }
    function _sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a, "SafeMath._sub: Underflow");
        c = a - b;
    }
}


// ----------------------------------------------------------------------------
// Owned contract, with token recovery
// ----------------------------------------------------------------------------
contract Owned {
    bool initialised;
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner, "Owned.onlyOwner: Not owner");
        _;
    }

    function init(address _owner) internal {
        require(!initialised, "Owned.init: Already initialised");
        owner = address(uint160(_owner));
        initialised = true;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner, "Owned.acceptOwnership: Not new owner");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
    function recoverTokens(address token, uint tokens) public onlyOwner {
        if (token == address(0)) {
            payable(owner).transfer((tokens == 0 ? address(this).balance : tokens));
        } else {
            ERC20Interface(token).transfer(owner, tokens == 0 ? ERC20Interface(token).balanceOf(address(this)) : tokens);
        }
    }
}


// ----------------------------------------------------------------------------
// Config - [baseToken, quoteToken, priceFeed] => [maxTerm, fee, description]
// ----------------------------------------------------------------------------
library ConfigLibrary {
    struct Config {
        uint timestamp;
        uint index;
        bytes32 key;
        address baseToken;
        address quoteToken;
        address priceFeed;
        uint baseDecimals;
        uint quoteDecimals;
        uint rateDecimals;
        uint maxTerm;
        uint fee;
        string description;
    }
    struct Data {
        bool initialised;
        mapping(bytes32 => Config) entries;
        bytes32[] index;
    }

    event ConfigAdded(bytes32 indexed configKey, address indexed baseToken, address indexed quoteToken, address priceFeed, uint baseDecimals, uint quoteDecimals, uint rateDecimals, uint maxTerm, uint fee, string description);
    event ConfigRemoved(bytes32 indexed configKey, address indexed baseToken, address indexed quoteToken, address priceFeed);
    event ConfigUpdated(bytes32 indexed configKey, address indexed baseToken, address indexed quoteToken, address priceFeed, uint maxTerm, uint fee, string description);

    function _init(Data storage self) internal {
        require(!self.initialised, "ConfigLibrary._init: Cannot re-initialise");
        self.initialised = true;
    }
    function _generateKey(address baseToken, address quoteToken, address priceFeed) internal pure returns (bytes32 hash) {
        return keccak256(abi.encodePacked(baseToken, quoteToken, priceFeed));
    }
    function _hasKey(Data storage self, bytes32 key) internal view returns (bool) {
        return self.entries[key].timestamp > 0;
    }
    function _add(Data storage self, address baseToken, address quoteToken, address priceFeed, uint baseDecimals, uint quoteDecimals, uint rateDecimals, uint maxTerm, uint fee, string memory description) internal {
        require(baseToken != quoteToken, "ConfigLibrary.add: baseToken cannot be the same as quoteToken");
        require(priceFeed != address(0), "ConfigLibrary.add: priceFeed cannot be null");
        require(maxTerm > 0, "ConfigLibrary.add: maxTerm must be > 0");
        bytes memory _description = bytes(description);
        require(_description.length <= 48, "ConfigLibrary.add: description length must be <= 48 characters");
        bytes32 key = _generateKey(baseToken, quoteToken, priceFeed);
        require(self.entries[key].timestamp == 0, "ConfigLibrary.add: Cannot add duplicate");
        self.index.push(key);
        self.entries[key] = Config(block.timestamp, self.index.length - 1, key, baseToken, quoteToken, priceFeed, baseDecimals, quoteDecimals, rateDecimals, maxTerm, fee, description);
        emit ConfigAdded(key, baseToken, quoteToken, priceFeed, baseDecimals, quoteDecimals, rateDecimals, maxTerm, fee, description);
    }
    function _remove(Data storage self, address baseToken, address quoteToken, address priceFeed) internal {
        bytes32 key = _generateKey(baseToken, quoteToken, priceFeed);
        require(self.entries[key].timestamp > 0, "ConfigLibrary:_remove: Invalid key");
        uint removeIndex = self.entries[key].index;
        emit ConfigRemoved(key, baseToken, quoteToken, priceFeed);
        uint lastIndex = self.index.length - 1;
        bytes32 lastIndexKey = self.index[lastIndex];
        self.index[removeIndex] = lastIndexKey;
        self.entries[lastIndexKey].index = removeIndex;
        delete self.entries[key];
        if (self.index.length > 0) {
            self.index.pop();
        }
    }
    function _update(Data storage self, address baseToken, address quoteToken, address priceFeed, uint maxTerm, uint fee, string memory description) internal {
        bytes32 key = _generateKey(baseToken, quoteToken, priceFeed);
        Config storage _value = self.entries[key];
        require(_value.timestamp > 0, "ConfigLibrary._update: Invalid key");
        _value.timestamp = block.timestamp;
        _value.maxTerm = maxTerm;
        _value.fee = fee;
        _value.description = description;
        emit ConfigUpdated(key, baseToken, quoteToken, priceFeed, maxTerm, fee, description);
    }
    function _length(Data storage self) internal view returns (uint) {
        return self.index.length;
    }
}


// ----------------------------------------------------------------------------
// Series - [(baseToken, quoteToken, priceFeed), callPut, expiry, strike] =>
// [description, optinoToken, optinoCollateralToken]
// ----------------------------------------------------------------------------
library SeriesLibrary {
    struct Series {
        uint timestamp;
        uint index;
        bytes32 key;
        bytes32 configKey;
        uint callPut;
        uint expiry;
        uint strike;
        address optinoToken;
        address optinoCollateralToken;
        uint spot;
    }
    struct Data {
        bool initialised;
        mapping(bytes32 => Series) entries;
        bytes32[] index;
    }

    event SeriesAdded(bytes32 indexed seriesKey, bytes32 indexed configKey, uint callPut, uint expiry, uint strike, address optinoToken, address optinoCollateralToken);
    event SeriesRemoved(bytes32 indexed seriesKey, bytes32 indexed configKey, uint callPut, uint expiry, uint strike);
    event SeriesUpdated(bytes32 indexed seriesKey, bytes32 indexed configKey, uint callPut, uint expiry, uint strike, string description);
    event SeriesSpotUpdated(bytes32 indexed seriesKey, bytes32 indexed configKey, uint callPut, uint expiry, uint strike, uint spot);

    function _init(Data storage self) internal {
        require(!self.initialised, "SeriesLibrary._init: Cannot re-initialise");
        self.initialised = true;
    }
    function _generateKey(bytes32 configKey, uint callPut, uint expiry, uint strike) internal pure returns (bytes32 hash) {
        return keccak256(abi.encodePacked(configKey, callPut, expiry, strike));
    }
    function _hasKey(Data storage self, bytes32 key) internal view returns (bool) {
        return self.entries[key].timestamp > 0;
    }
    function _add(Data storage self, bytes32 configKey, uint callPut, uint expiry, uint strike, address optinoToken, address optinoCollateralToken) internal {
        // require(baseToken != quoteToken, "SeriesLibrary.add: baseToken cannot be the same as quoteToken");
        // require(priceFeed != address(0), "SeriesLibrary.add: priceFeed cannot be null");
        require(callPut < 2, "SeriesLibrary.add: callPut must be 0 (call) or 1 (callPut)");
        require(expiry > block.timestamp, "SeriesLibrary.add: expiry must be in the future");
        require(strike > 0, "SeriesLibrary.add: strike must be non-zero");
        require(optinoToken != address(0), "SeriesLibrary.add: optinoToken cannot be null");
        require(optinoCollateralToken != address(0), "SeriesLibrary.add: optinoCollateralToken cannot be null");

        bytes32 key = _generateKey(configKey, callPut, expiry, strike);
        require(self.entries[key].timestamp == 0, "SeriesLibrary.add: Cannot add duplicate");
        self.index.push(key);
        self.entries[key] = Series(block.timestamp, self.index.length - 1, key, configKey, callPut, expiry, strike, optinoToken, optinoCollateralToken, 0);
        emit SeriesAdded(key, configKey, callPut, expiry, strike, optinoToken, optinoCollateralToken);
    }
    function _remove(Data storage self, bytes32 configKey, uint callPut, uint expiry, uint strike) internal {
        bytes32 key = _generateKey(configKey, callPut, expiry, strike);
        require(self.entries[key].timestamp > 0, "SeriesLibrary._remove: Invalid key");
        uint removeIndex = self.entries[key].index;
        emit SeriesRemoved(key, configKey, callPut, expiry, strike);
        uint lastIndex = self.index.length - 1;
        bytes32 lastIndexKey = self.index[lastIndex];
        self.index[removeIndex] = lastIndexKey;
        self.entries[lastIndexKey].index = removeIndex;
        delete self.entries[key];
        if (self.index.length > 0) {
            self.index.pop();
        }
    }
    // function _update(Data storage self, bytes32 configKey, uint callPut, uint expiry, uint strike, string memory description) internal {
    //     bytes32 key = generateKey(baseToken, quoteToken, priceFeed, callPut, expiry, strike);
    //     Series storage _value = self.entries[key];
    //     require(_value.timestamp > 0, "SeriesLibrary._update: Invalid key");
    //     _value.timestamp = block.timestamp;
    //     _value.description = description;
    //     emit SeriesUpdated(baseToken, quoteToken, priceFeed, callPut, expiry, strike, description);
    // }
    function _updateSpot(Data storage self, bytes32 key, uint spot) internal {
        Series storage _value = self.entries[key];
        require(_value.timestamp > 0, "SeriesLibrary._updateSpot: Invalid key");
        require(_value.expiry <= block.timestamp, "SeriesLibrary._updateSpot: Not expired yet");
        require(_value.spot == 0, "SeriesLibrary._updateSpot: spot cannot be re-set");
        require(spot > 0, "SeriesLibrary._updateSpot: spot cannot be 0");
        _value.timestamp = block.timestamp;
        _value.spot = spot;
        emit SeriesSpotUpdated(key, _value.configKey, _value.callPut, _value.expiry, _value.strike, spot);
    }
    function _length(Data storage self) internal view returns (uint) {
        return self.index.length;
    }
}



// ----------------------------------------------------------------------------
// ApproveAndCall Fallback
// NOTE for contracts implementing this interface:
// 1. An error must be thrown if there are errors executing `transferFrom(...)`
// 2. The calling token contract must be checked to prevent malicious behaviour
// ----------------------------------------------------------------------------
interface ApproveAndCallFallback {
    function receiveApproval(address from, uint256 tokens, address token, bytes calldata data) external;
}


// ----------------------------------------------------------------------------
// PriceFeedAdaptor
// ----------------------------------------------------------------------------
interface PriceFeedAdaptor {
    function spot() external view returns (uint value, bool hasValue);
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
interface ERC20Interface {
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
}


// ----------------------------------------------------------------------------
// Token Interface = symbol + name + decimals + approveAndCall + mint + burn
// Use with ERC20Interface
// ----------------------------------------------------------------------------
interface TokenInterface is ERC20Interface {
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function decimals() external view returns (uint8);
    function approveAndCall(address spender, uint tokens, bytes calldata data) external returns (bool success);
    function mint(address tokenOwner, uint tokens) external returns (bool success);
    // function burn(address tokenOwner, uint tokens) external returns (bool success);
}


contract Token is TokenInterface, Owned {
    using SafeMath for uint;

    string _symbol;
    string  _name;
    uint8 _decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    function _initToken(address tokenOwner, string memory symbol, string memory name, uint8 decimals) internal {
        super.init(tokenOwner);
        _symbol = symbol;
        _name = name;
        _decimals = decimals;
    }
    function symbol() override external view returns (string memory) {
        return _symbol;
    }
    function name() override external view returns (string memory) {
        return _name;
    }
    function decimals() override external view returns (uint8) {
        return _decimals;
    }
    function totalSupply() override external view returns (uint) {
        return _totalSupply._sub(balances[address(0)]);
    }
    function balanceOf(address tokenOwner) override external view returns (uint balance) {
        return balances[tokenOwner];
    }
    function transfer(address to, uint tokens) override external returns (bool success) {
        balances[msg.sender] = balances[msg.sender]._sub(tokens);
        balances[to] = balances[to]._add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    function approve(address spender, uint tokens) override external returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    function transferFrom(address from, address to, uint tokens) override external returns (bool success) {
        balances[from] = balances[from]._sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender]._sub(tokens);
        balances[to] = balances[to]._add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    function allowance(address tokenOwner, address spender) override external view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    // NOTE Only use this call with a trusted spender contract
    function approveAndCall(address spender, uint tokens, bytes calldata data) override external returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallback(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }
    function mint(address tokenOwner, uint tokens) override external onlyOwner returns (bool success) {
        balances[tokenOwner] = balances[tokenOwner]._add(tokens);
        _totalSupply = _totalSupply._add(tokens);
        emit Transfer(address(0), tokenOwner, tokens);
        return true;
    }
    receive() external payable {
    }
}


// ----------------------------------------------------------------------------
// Vanilla Optino Formula
//
// Call optino - 10 units with strike 200, using spot of [150, 200, 250], collateral of 10 ETH
// - 10 OptinoToken created
//   - payoffInQuoteTokenPerUnitBaseToken = max(0, spot-strike) = [0, 0, 50] DAI
//   - payoffInQuoteToken = 10 * [0, 0, 500] DAI
//   * payoffInBaseTokenPerUnitBaseToken = payoffInQuoteTokenPerUnitBaseToken / [150, 200, 250] = [0, 0, 50/250] = [0, 0, 0.2] ETH
//   * payoffInBaseToken = payoffInBaseTokenPerUnitBaseToken * 10 = [0 * 10, 0 * 10, 0.2 * 10] = [0, 0, 2] ETH
// - 10 OptinoCollateralToken created
//   - payoffInQuoteTokenPerUnitBaseToken = spot - max(0, spot-strike) = [150, 200, 200] DAI
//   - payoffInQuoteToken = 10 * [1500, 2000, 2000] DAI
//   * payoffInBaseTokenPerUnitBaseToken = payoffInQuoteTokenPerUnitBaseToken / [150, 200, 250] = [1, 1, 200/250] = [1, 1, 0.8] ETH
//   * payoffInBaseToken = payoffInBaseTokenPerUnitBaseToken * 10 = [1 * 10, 1 * 10, 0.8 * 10] = [10, 10, 8] ETH
//
// Put optino - 10 units with strike 200, using spot of [150, 200, 250], collateral of 2000 DAI
// - 10 OptinoToken created
//   * payoffInQuoteTokenPerUnitBaseToken = max(0, strike-spot) = [50, 0, 0] DAI
//   * payoffInQuoteToken = 10 * [500, 0, 0] DAI
//   - payoffInBaseTokenPerUnitBaseToken = payoffInQuoteTokenPerUnitBaseToken / [150, 200, 250] = [50/150, 0/200, 0/250] = [0.333333333, 0, 0] ETH
//   - payoffInBaseToken = payoffInBaseTokenPerUnitBaseToken * 10 = [0.333333333 * 10, 0 * 10, 0 * 10] = [3.333333333, 0, 0] ETH
// - 10 OptinoCollateralToken created
//   * payoffInQuoteTokenPerUnitBaseToken = strike - max(0, strike-spot) = [150, 200, 200] DAI
//   * payoffInQuoteToken = 10 * [1500, 2000, 2000] DAI
//   - payoffInBaseTokenPerUnitBaseToken = payoffInQuoteTokenPerUnitBaseToken / spot
//   - payoffInBaseTokenPerUnitBaseToken = [150, 200, 200] / [150, 200, 250] = [1, 1, 200/250] = [1, 1, 0.8] ETH
//   - payoffInBaseToken = payoffInBaseTokenPerUnitBaseToken * 10 = [1 * 10, 1 * 10, 0.8 * 10] = [10, 10, 8] ETH
//
// ----------------------------------------------------------------------------
library VanillaOptinoFormulae {
    using SafeMath for uint;

    // ------------------------------------------------------------------------
    // Payoff for baseToken/quoteToken, e.g. ETH/DAI
    //   OptionToken:
    //     Call
    //       payoffInQuoteToken = max(0, spot - strike)
    //       payoffInBaseToken = payoffInQuoteToken / (spot / 10^rateDecimals)
    //     Put
    //       payoffInQuoteToken = max(0, strike - spot)
    //       payoffInBaseToken = payoffInQuoteToken / (spot / 10^rateDecimals)
    //   OptionCollateralToken:
    //     Call
    //       payoffInQuoteToken = spot - max(0, spot - strike)
    //       payoffInBaseToken = payoffInQuoteToken / (spot / 10^rateDecimals)
    //     Put
    //       payoffInQuoteToken = strike - max(0, strike - spot)
    //       payoffInBaseToken = payoffInQuoteToken / (spot / 10^rateDecimals)
    //
    // NOTE:
    //   * strike and spot at rateDecimals decimal places, 18 in this contract
    //   * Deliver baseToken for call and quoteToken for put
    // ------------------------------------------------------------------------
    function payoffInDeliveryToken(uint _callPut, uint _strike, uint _spot, uint _baseTokens, uint _baseDecimals, uint _rateDecimals) internal pure returns (uint _payoff, uint _collateral) {
        if (_callPut == 0) {
            uint _payoffInQuoteToken = (_spot <= _strike) ? 0 : _spot._sub(_strike);
            uint _collateralPayoffInQuoteToken = _spot._sub(_payoffInQuoteToken);

            _payoff = _payoffInQuoteToken * (10 ** _rateDecimals) / _spot;
            _collateral = _collateralPayoffInQuoteToken * (10 ** _rateDecimals) / _spot;

            _payoff = _payoff * _baseTokens / (10 ** _baseDecimals);
            _collateral = _collateral * _baseTokens / (10 ** _baseDecimals);
        } else {
            // Payoff calculated on quote token, delivery of quoteToken
            _payoff = (_spot >= _strike) ? 0 : _strike._sub(_spot);
            _collateral = _strike._sub(_payoff);

            _payoff = _payoff * _baseTokens / (10 ** _baseDecimals);
            _collateral = _collateral * _baseTokens / (10 ** _baseDecimals);
        }
    }
}


// ----------------------------------------------------------------------------
// OptinoToken 📈 = Token + payoff
// ----------------------------------------------------------------------------
contract OptinoToken is Token {
    using SeriesLibrary for SeriesLibrary.Series;
    uint8 public constant OPTIONDECIMALS = 18;
    address private constant ETH = address(0);
    uint public constant COLLECTDUSTMINIMUMDECIMALS = 10; // Collect dust only if token has > 10 decimal places
    uint public constant COLLECTDUSTDECIMALS = 2; // Collect dust if less < 10**2 = 100

    bytes32 public configKey;
    bytes32 public seriesKey;
    address public factory;
    address public pair;
    uint public seriesNumber;
    bool public isCollateral;

    event Close(address indexed optinoToken, address indexed token, address indexed tokenOwner, uint tokens);
    event Payoff(address indexed optinoToken, address indexed token, address indexed tokenOwner, uint tokens);

    function initOptinoToken(address _factory, bytes32 _seriesKey,  address _pair, uint _seriesNumber, bool _isCollateral) public {
        seriesKey = _seriesKey;
        factory = _factory;
        pair = _pair;
        seriesNumber = _seriesNumber;
        isCollateral = _isCollateral;
        (bytes32 _configKey, uint _callPut, uint _expiry, uint _strike, /*_optinoToken*/, /*_optinoCollateralToken*/) = BokkyPooBahsVanillaOptinoFactory(factory).getSeriesByKey(seriesKey);
        configKey = _configKey;
        (/*_baseToken*/, /*_quoteToken*/, /*_priceFeed*/, /*_baseDecimals*/, /*_quoteDecimals*/, /*_rateDecimals*/, /*_maxTerm*/, /*_fee*/, string memory _description, /*_timestamp*/) = BokkyPooBahsVanillaOptinoFactory(factory).getConfigByKey(_configKey);
        string memory _symbol = Utils._toSymbol(_isCollateral, _callPut, _seriesNumber);
        string memory _name = Utils._toName(_description, _isCollateral, _callPut, _expiry, _strike, OPTIONDECIMALS);
        super._initToken(factory, _symbol, _name, OPTIONDECIMALS);
    }

    function burn(address tokenOwner, uint tokens) external returns (bool success) {
        require(msg.sender == tokenOwner || msg.sender == pair || msg.sender == address(this), "OptinoToken.burn: msg.sender not authorised");
        balances[tokenOwner] = balances[tokenOwner]._sub(tokens);
        _totalSupply = _totalSupply._sub(tokens);
        emit Transfer(tokenOwner, address(0), tokens);
        return true;
    }

    function getSeriesData() public view returns (bytes32 _seriesKey, bytes32 _configKey, uint _callPut, uint _expiry, uint _strike, address _optinoToken, address _optinoCollateralToken) {
        _seriesKey = seriesKey;
        (_configKey, _callPut, _expiry, _strike, _optinoToken, _optinoCollateralToken) = BokkyPooBahsVanillaOptinoFactory(factory).getSeriesByKey(seriesKey);
    }
    function getConfigData1() public view returns (address _baseToken, address _quoteToken, address _priceFeed, uint _baseDecimals, uint _quoteDecimals, uint _rateDecimals, uint _maxTerm, uint _fee) {
        (_baseToken, _quoteToken, _priceFeed, _baseDecimals, _quoteDecimals, _rateDecimals, _maxTerm, _fee, /*_description*/, /*_timestamp*/) = BokkyPooBahsVanillaOptinoFactory(factory).getConfigByKey(configKey);
    }
    function getConfigData2() public view returns (string memory _description, uint _timestamp) {
        (/*_baseToken*/, /*_quoteToken*/, /*_priceFeed*/, /*_baseDecimals*/, /*_quoteDecimals*/, /*_rateDecimals*/, /*_maxTerm*/, /*_fee*/, _description, _timestamp) = BokkyPooBahsVanillaOptinoFactory(factory).getConfigByKey(configKey);
    }

    function spot() public view returns (uint _spot) {
        return BokkyPooBahsVanillaOptinoFactory(factory).getSeriesSpot(seriesKey);
    }
    function currentSpot() public view returns (uint _currentSpot) {
        return BokkyPooBahsVanillaOptinoFactory(factory).getSeriesCurrentSpot(seriesKey);
    }
    function setSpot() public returns (uint _spot) {
        return BokkyPooBahsVanillaOptinoFactory(factory).setSeriesSpot(seriesKey);
    }
    function payoffDeliveryInBaseOrQuote() public view returns (uint _callPut) {
        // Call on ETH/DAI - payoff in baseToken (ETH); Put on ETH/DAI - payoff in quoteToken (DAI)
        (/*_configKey*/, _callPut, /*_expiry*/, /*_strike*/, /*_optinoToken*/, /*_optinoCollateralToken*/) = BokkyPooBahsVanillaOptinoFactory(factory).getSeriesByKey(seriesKey);
    }
    function payoffInDeliveryToken(uint _spot, uint _baseTokens) public view returns (uint _payoff, uint _collateral) {
        (bytes32 _configKey, uint _callPut, /*uint _expiry*/, uint _strike, /*_optinoToken*/, /*_optinoCollateralToken*/) = BokkyPooBahsVanillaOptinoFactory(factory).getSeriesByKey(seriesKey);
        (/*_baseToken*/, /*_quoteToken*/, /*_priceFeed*/, uint _baseDecimals, /*_quoteDecimals*/, uint _rateDecimals, /*_maxTerm*/, /*_fee*/, /*_description*/, /*_timestamp*/) = BokkyPooBahsVanillaOptinoFactory(factory).getConfigByKey(_configKey);
        return VanillaOptinoFormulae.payoffInDeliveryToken(_callPut, _strike, _spot, _baseTokens, _baseDecimals, _rateDecimals);
    }

    function currentPayoffPerUnitBaseToken() public view returns (uint _currentPayoffPerUnitBaseToken) {
        uint _spot = currentSpot();
        (bytes32 _configKey, uint _callPut, /*uint _expiry*/, uint _strike, /*_optinoToken*/, /*_optinoCollateralToken*/) = BokkyPooBahsVanillaOptinoFactory(factory).getSeriesByKey(seriesKey);
        (/*_baseToken*/, /*_quoteToken*/, /*_priceFeed*/, uint _baseDecimals, /*_quoteDecimals*/, uint _rateDecimals, /*_maxTerm*/, /*_fee*/, /*_description*/, /*_timestamp*/) = BokkyPooBahsVanillaOptinoFactory(factory).getConfigByKey(_configKey);
        uint _baseTokens = 10 ** _baseDecimals;
        (uint _payoff, uint _collateral) = VanillaOptinoFormulae.payoffInDeliveryToken(_callPut, _strike, _spot, _baseTokens, _baseDecimals, _rateDecimals);
        return isCollateral ? _collateral : _payoff;
    }
    function payoffPerUnitBaseToken() public view returns (uint _payoffPerUnitBaseToken) {
        uint _spot = spot();
        // Not set
        if (_spot == 0) {
            return 0;
        } else {
            (bytes32 _configKey, uint _callPut, /*uint _expiry*/, uint _strike, /*_optinoToken*/, /*_optinoCollateralToken*/) = BokkyPooBahsVanillaOptinoFactory(factory).getSeriesByKey(seriesKey);
            (/*_baseToken*/, /*_quoteToken*/, /*_priceFeed*/, uint _baseDecimals, /*_quoteDecimals*/, uint _rateDecimals, /*_maxTerm*/, /*_fee*/, /*_description*/, /*_timestamp*/) = BokkyPooBahsVanillaOptinoFactory(factory).getConfigByKey(_configKey);
            uint _baseTokens = 10 ** _baseDecimals;
            (uint _payoff, uint _collateral) = VanillaOptinoFormulae.payoffInDeliveryToken(_callPut, _strike, _spot, _baseTokens, _baseDecimals, _rateDecimals);
            return isCollateral ? _collateral : _payoff;
        }
    }
    function collectDust(uint amount, uint balance, uint decimals) pure internal returns (uint) {
        if (decimals > COLLECTDUSTMINIMUMDECIMALS) {
            if (amount < balance && amount + 10**COLLECTDUSTDECIMALS > balance) {
                return balance;
            }
        }
        return amount;
    }
    function close(uint _baseTokens) public {
        _close(msg.sender, _baseTokens);
    }
    function _close(address tokenOwner, uint _baseTokens) public {
        require(msg.sender == tokenOwner || msg.sender == pair || msg.sender == address(this));
        if (!isCollateral) {
            OptinoToken(payable(pair))._close(tokenOwner, _baseTokens);
        } else {
            require(_baseTokens <= ERC20Interface(this).balanceOf(tokenOwner));
            require(_baseTokens <= ERC20Interface(pair).balanceOf(tokenOwner));
            require(OptinoToken(payable(pair)).burn(tokenOwner, _baseTokens));
            require(OptinoToken(payable(this)).burn(tokenOwner, _baseTokens));
            (bytes32 _configKey, uint _callPut, /*uint _expiry*/, uint _strike, /*_optinoToken*/, /*_optinoCollateralToken*/) = BokkyPooBahsVanillaOptinoFactory(factory).getSeriesByKey(seriesKey);
            (address _baseToken, address _quoteToken, /*_priceFeed*/, uint _baseDecimals, uint _quoteDecimals, uint _rateDecimals, /*_maxTerm*/, /*_fee*/, /*_description*/, /*_timestamp*/) = BokkyPooBahsVanillaOptinoFactory(factory).getConfigByKey(_configKey);
            if (_callPut == 0) {
                if (_baseToken == ETH) {
                    _baseTokens = collectDust(_baseTokens, address(this).balance, _baseDecimals);
                    payable(tokenOwner).transfer(_baseTokens);
                    emit Close(pair, _baseToken, tokenOwner, _baseTokens);
                } else {
                    _baseTokens = collectDust(_baseTokens, ERC20Interface(_baseToken).balanceOf(address(this)), _baseDecimals);
                    require(ERC20Interface(_baseToken).transfer(tokenOwner, _baseTokens));
                    emit Close(pair, _baseToken, tokenOwner, _baseTokens);
                }
            } else {
                uint _quoteTokens = _baseTokens * _strike / (10 ** _rateDecimals);
                if (_quoteToken == ETH) {
                    _quoteTokens = collectDust(_quoteTokens, address(this).balance, _quoteDecimals);
                    payable(tokenOwner).transfer(_quoteTokens);
                    emit Close(pair, _quoteToken, tokenOwner, _quoteTokens);
                } else {
                    _quoteTokens = collectDust(_quoteTokens, ERC20Interface(_quoteToken).balanceOf(address(this)), _baseDecimals);
                    require(ERC20Interface(_quoteToken).transfer(tokenOwner, _quoteTokens));
                    emit Close(pair, _quoteToken, tokenOwner, _quoteTokens);
                }
            }
        }
    }
    function settle() public {
        _settle(msg.sender);
    }
    function _settle(address tokenOwner) public {
        require(msg.sender == tokenOwner || msg.sender == pair || msg.sender == address(this));
        if (!isCollateral) {
            OptinoToken(payable(pair))._settle(tokenOwner);
        } else {
            uint optinoTokens = ERC20Interface(pair).balanceOf(tokenOwner);
            uint optinoCollateralTokens = ERC20Interface(this).balanceOf(tokenOwner);
            require (optinoTokens > 0 || optinoCollateralTokens > 0);
            uint _spot = spot();
            if (_spot == 0) {
                setSpot();
                _spot = spot();
            }
            require(_spot > 0);
            uint _payoff;
            uint _collateral;

            (address _baseToken, address _quoteToken, uint _baseDecimals, uint _quoteDecimals, uint _rateDecimals, uint _callPut, uint _strike) = BokkyPooBahsVanillaOptinoFactory(factory).getSeriesAndConfigCalcDataByKey(seriesKey);

            (_payoff, _collateral) = VanillaOptinoFormulae.payoffInDeliveryToken(_callPut, _strike, _spot, optinoTokens, _baseDecimals, _rateDecimals);
            require(OptinoToken(payable(pair)).burn(tokenOwner, optinoTokens));
            if (_callPut == 0) {
                if (_baseToken == ETH) {
                    _payoff = collectDust(_payoff, address(this).balance, _baseDecimals);
                    payable(tokenOwner).transfer(_payoff);
                    emit Payoff(pair, _baseToken, tokenOwner, _payoff);
                } else {
                    _payoff = collectDust(_payoff, ERC20Interface(_baseToken).balanceOf(address(this)), _baseDecimals);
                    require(ERC20Interface(_baseToken).transfer(tokenOwner, _payoff));
                    emit Payoff(pair, _baseToken, tokenOwner, _payoff);
                }
            } else {
                if (_quoteToken == ETH) {
                    _payoff = collectDust(_payoff, address(this).balance, _quoteDecimals);
                    payable(tokenOwner).transfer(_payoff);
                    emit Payoff(pair, _quoteToken, tokenOwner, _payoff);
                } else {
                    _payoff = collectDust(_payoff, ERC20Interface(_quoteToken).balanceOf(address(this)), _quoteDecimals);
                    require(ERC20Interface(_quoteToken).transfer(tokenOwner, _payoff));
                    emit Payoff(pair, _quoteToken, tokenOwner, _payoff);
                }
            }

            (_payoff, _collateral) = VanillaOptinoFormulae.payoffInDeliveryToken(_callPut, _strike, _spot, optinoCollateralTokens, _baseDecimals, _rateDecimals);
            require(OptinoToken(payable(this)).burn(tokenOwner, optinoCollateralTokens));
            if (_callPut == 0) {
                if (_baseToken == ETH) {
                    _collateral = collectDust(_collateral, address(this).balance, _baseDecimals);
                    payable(tokenOwner).transfer(_collateral);
                    emit Payoff(address(this), _baseToken, tokenOwner, _collateral);
                } else {
                    _collateral = collectDust(_collateral, ERC20Interface(_baseToken).balanceOf(address(this)), _baseDecimals);
                    require(ERC20Interface(_baseToken).transfer(tokenOwner, _collateral));
                    emit Payoff(address(this), _baseToken, tokenOwner, _collateral);
                }
            } else {
                if (_quoteToken == ETH) {
                    _collateral = collectDust(_collateral, address(this).balance, _quoteDecimals);
                    payable(tokenOwner).transfer(_collateral);
                    emit Payoff(address(this), _quoteToken, tokenOwner, _collateral);
                } else {
                    _collateral = collectDust(_collateral, ERC20Interface(_quoteToken).balanceOf(address(this)), _quoteDecimals);
                    require(ERC20Interface(_quoteToken).transfer(tokenOwner, _collateral));
                    emit Payoff(address(this), _quoteToken, tokenOwner, _collateral);
                }
            }
        }
    }
}


// ----------------------------------------------------------------------------
// BokkyPooBah's Vanilla Optino 📈 Factory
//
// Note: If `newAddress` is not null, it will point to the upgraded contract
// ----------------------------------------------------------------------------
contract BokkyPooBahsVanillaOptinoFactory is Owned, CloneFactory {
    using SafeMath for uint;
    using ConfigLibrary for ConfigLibrary.Data;
    using ConfigLibrary for ConfigLibrary.Config;
    using SeriesLibrary for SeriesLibrary.Data;
    using SeriesLibrary for SeriesLibrary.Series;

    struct OptinoData {
        address baseToken;
        address quoteToken;
        address priceFeed;
        uint callPut;
        uint expiry;
        uint strike;
        uint baseTokens;
    }

    address private constant ETH = address(0);
    uint public constant FEEDECIMALS = 18;
    // Manually set spot 7 days after expiry, if priceFeed fails (spot == 0 or hasValue == 0)
    uint public constant GRACEPERIOD = 7 * 24 * 60 * 60;

    // Set to new contract address if this contract is deprecated
    address public newAddress;

    address public optinoTokenTemplate;

    ConfigLibrary.Data private configData;
    SeriesLibrary.Data private seriesData;

    // Config copy of events to be generated in the ABI
    event ConfigAdded(bytes32 indexed configKey, address indexed baseToken, address indexed quoteToken, address priceFeed, uint baseDecimals, uint quoteDecimals, uint maxTerm, uint fee, string description);
    event ConfigRemoved(bytes32 indexed configKey, address indexed baseToken, address indexed quoteToken, address priceFeed);
    event ConfigUpdated(bytes32 indexed configKey, address indexed baseToken, address indexed quoteToken, address priceFeed, uint maxTerm, uint fee, string description);
    // SeriesLibrary copy of events to be generated in the ABI
    event SeriesAdded(bytes32 indexed seriesKey, bytes32 indexed configKey, uint callPut, uint expiry, uint strike, address optinoToken, address optinoCollateralToken);
    event SeriesRemoved(bytes32 indexed seriesKey, bytes32 indexed configKey, uint callPut, uint expiry, uint strike);
    event SeriesUpdated(bytes32 indexed seriesKey, bytes32 indexed configKey, uint callPut, uint expiry, uint strike, string description);
    event SeriesSpotUpdated(bytes32 indexed seriesKey, bytes32 indexed configKey, uint callPut, uint expiry, uint strike, uint spot);

    event ContractDeprecated(address _newAddress);
    event EthersReceived(address indexed sender, uint ethers);

    constructor(address _optinoTokenTemplate) public {
        super.init(msg.sender);
        optinoTokenTemplate = _optinoTokenTemplate;
    }
    function deprecateContract(address _newAddress) public onlyOwner {
        require(newAddress == address(0));
        emit ContractDeprecated(_newAddress);
        newAddress = _newAddress;
    }

    // ----------------------------------------------------------------------------
    // Config
    // ----------------------------------------------------------------------------
    function addConfig(address baseToken, address quoteToken, address priceFeed, uint baseDecimals, uint quoteDecimals, uint rateDecimals, uint maxTerm, uint fee, string memory description) public onlyOwner {
        if (!configData.initialised) {
            configData._init();
        }
        configData._add(baseToken, quoteToken, priceFeed, baseDecimals, quoteDecimals, rateDecimals, maxTerm, fee, description);
    }
    function updateConfig(address baseToken, address quoteToken, address priceFeed, uint maxTerm, uint fee, string memory description) public onlyOwner {
        require(configData.initialised);
        configData._update(baseToken, quoteToken, priceFeed, maxTerm, fee, description);
    }
    // function removeConfig(address baseToken, address quoteToken, address priceFeed) public onlyOwner {
    //     require(configData.initialised);
    //     configData._remove(baseToken, quoteToken, priceFeed);
    // }
    function configDataLength() public view returns (uint _length) {
        return configData._length();
    }
    function getConfigByIndex(uint i) public view returns (bytes32 _configKey, address _baseToken, address _quoteToken, address _priceFeed, uint _baseDecimals, uint _quoteDecimals, uint _rateDecimals, uint _maxTerm, uint _fee, string memory _description, uint _timestamp) {
        require(i < configData._length(), "getConfigByIndex: Invalid config index");
        ConfigLibrary.Config memory config = configData.entries[configData.index[i]];
        return (config.key, config.baseToken, config.quoteToken, config.priceFeed, config.baseDecimals, config.quoteDecimals, config.rateDecimals, config.maxTerm, config.fee, config.description, config.timestamp);
    }
    function getConfigByKey(bytes32 key) public view returns (address _baseToken, address _quoteToken, address _priceFeed, uint _baseDecimals, uint _quoteDecimals, uint _rateDecimals, uint _maxTerm, uint _fee, string memory _description, uint _timestamp) {
        ConfigLibrary.Config memory config = configData.entries[key];
        return (config.baseToken, config.quoteToken, config.priceFeed, config.baseDecimals, config.quoteDecimals, config.rateDecimals, config.maxTerm, config.fee, config.description, config.timestamp);
    }
    function _getConfig(OptinoData memory optinoData) internal view returns (ConfigLibrary.Config memory _config) {
        bytes32 key = ConfigLibrary._generateKey(optinoData.baseToken, optinoData.quoteToken, optinoData.priceFeed);
        return configData.entries[key];
    }


    // ----------------------------------------------------------------------------
    // Series
    // ----------------------------------------------------------------------------
    function addSeries(OptinoData memory optinoData,bytes32 configKey, address optinoToken, address optinoCollateralToken) internal {
        if (!seriesData.initialised) {
            seriesData._init();
        }
        seriesData._add(configKey, optinoData.callPut, optinoData.expiry, optinoData.strike, optinoToken, optinoCollateralToken);
    }
    // function updateSeries(address baseToken, address quoteToken, address priceFeed, uint callPut, uint expiry, uint strike, string memory description) internal {
    //     require(seriesData.initialised);
    //     seriesData.update(baseToken, quoteToken, priceFeed, callPut, expiry, strike, description);
    // }
    function getSeriesCurrentSpot(bytes32 seriesKey) public view returns (uint _currentSpot) {
        SeriesLibrary.Series memory series = seriesData.entries[seriesKey];
        ConfigLibrary.Config memory config = configData.entries[series.configKey];
        (uint _spot, bool hasValue) = PriceFeedAdaptor(config.priceFeed).spot();
        if (hasValue) {
            return _spot;
        }
        return 0;
    }
    function getSeriesSpot(bytes32 seriesKey) public view returns (uint _spot) {
        SeriesLibrary.Series memory series = seriesData.entries[seriesKey];
        return series.spot;
    }
    function setSeriesSpot(bytes32 seriesKey) public returns (uint _spot) {
        require(seriesData.initialised);
        _spot = getSeriesCurrentSpot(seriesKey);
        // Following will throw if trying to set the spot before expiry, or if already set
        seriesData._updateSpot(seriesKey, _spot);
    }
    function setSeriesSpotIfPriceFeedFails(bytes32 seriesKey, uint spot) public onlyOwner returns (uint _spot) {
        require(seriesData.initialised);
        SeriesLibrary.Series memory series = seriesData.entries[seriesKey];
        require(block.timestamp >= series.expiry + GRACEPERIOD);
        // Following will throw if trying to set the spot before expiry + failperiod, or if already set
        seriesData._updateSpot(seriesKey, spot);
        return spot;
    }
    function seriesDataLength() public view returns (uint _seriesDataLength) {
        return seriesData._length();
    }
    function getSeriesByIndex(uint i) public view returns (bytes32 _seriesKey, bytes32 _configKey, uint _callPut, uint _expiry, uint _strike, uint _timestamp, address _optinoToken, address _optinoCollateralToken) {
        require(i < seriesData._length(), "getSeriesByIndex: Invalid config index");
        SeriesLibrary.Series memory series = seriesData.entries[seriesData.index[i]];
        ConfigLibrary.Config memory config = configData.entries[series.configKey];
        return (series.key, config.key, series.callPut, series.expiry, series.strike, series.timestamp, series.optinoToken, series.optinoCollateralToken);
    }
    function getSeriesByKey(bytes32 key) public view returns (bytes32 _configKey, uint _callPut, uint _expiry, uint _strike, address _optinoToken, address _optinoCollateralToken) {
        SeriesLibrary.Series memory series = seriesData.entries[key];
        require(series.timestamp > 0, "mintOptinoTokens: invalid series key");
        return (series.configKey, series.callPut, series.expiry, series.strike, series.optinoToken, series.optinoCollateralToken);
    }
    function getSeriesAndConfigCalcDataByKey(bytes32 key) public view returns (address _baseToken, address _quoteToken, uint _baseDecimals, uint _quoteDecimals, uint _rateDecimals, uint _callPut, uint _strike) {
        SeriesLibrary.Series memory series = seriesData.entries[key];
        require(series.timestamp > 0, "mintOptinoTokens: invalid series key");
        ConfigLibrary.Config memory config = configData.entries[series.configKey];
        return (config.baseToken, config.quoteToken, config.baseDecimals, config.quoteDecimals, config.rateDecimals, series.callPut, series.strike);
    }
    function _getSeries(OptinoData memory optinoData) internal view returns (SeriesLibrary.Series storage _series) {
        ConfigLibrary.Config memory config = _getConfig(optinoData);
        require(config.timestamp > 0, "mintOptinoTokens: invalid config");
        bytes32 key = SeriesLibrary._generateKey(config.key, optinoData.callPut, optinoData.expiry, optinoData.strike);
        return seriesData.entries[key];
    }


    // ----------------------------------------------------------------------------
    // Mint optino tokens
    // ----------------------------------------------------------------------------
    function mintOptinoTokens(address baseToken, address quoteToken, address priceFeed, uint callPut, uint expiry, uint strike, uint baseTokens, address uiFeeAccount) public payable returns (address _optinoToken, address _optionCollateralToken) {
        return _mintOptinoTokens(OptinoData(baseToken, quoteToken, priceFeed, callPut, expiry, strike, baseTokens), uiFeeAccount);
    }
    function _mintOptinoTokens(OptinoData memory optinoData, address uiFeeAccount) internal returns (address _optinoToken, address _optionCollateralToken) {
        // Check parameters not checked in SeriesLibrary and ConfigLibrary
        require(optinoData.expiry > block.timestamp, "_mintOptinoTokens: expiry must be in the future");
        require(optinoData.baseTokens > 0, "_mintOptinoTokens: baseTokens must be non-zero");

        // Check config registered
        ConfigLibrary.Config memory config = _getConfig(optinoData);
        require(config.timestamp > 0, "_mintOptinoTokens: Invalid config");

        SeriesLibrary.Series storage series = _getSeries(optinoData);

        OptinoToken optinoToken;
        OptinoToken optinoCollateralToken;
        // Series has not been created yet
        if (series.timestamp == 0) {
            require(optinoData.expiry < (block.timestamp + config.maxTerm), "_mintOptinoTokens: expiry > config.maxTerm");
            optinoToken = OptinoToken(payable(createClone(optinoTokenTemplate)));
            optinoCollateralToken = OptinoToken(payable(createClone(optinoTokenTemplate)));
            addSeries(optinoData, config.key, address(optinoToken), address(optinoCollateralToken));
            series = _getSeries(optinoData);

            optinoToken.initOptinoToken(address(this), series.key, address(optinoCollateralToken), seriesData._length(), false);
            optinoCollateralToken.initOptinoToken(address(this), series.key, address(optinoToken), seriesData._length(), true);
        } else {
            optinoToken = OptinoToken(payable(series.optinoToken));
            optinoCollateralToken = OptinoToken(payable(series.optinoCollateralToken));
        }
        optinoToken.mint(msg.sender, optinoData.baseTokens);
        optinoCollateralToken.mint(msg.sender, optinoData.baseTokens);

        if (optinoData.callPut == 0) {
            uint devFee = optinoData.baseTokens * config.fee / (10 ** FEEDECIMALS);
            uint uiFee;
            if (uiFeeAccount != address(0) && uiFeeAccount != owner) {
                uiFee = devFee / 2;
                devFee = devFee - uiFee;
            }
            if (optinoData.baseToken == ETH) {
                require(msg.value >= (optinoData.baseTokens + uiFee + devFee), "_mintOptinoTokens: Insufficient ETH sent");
                require(payable(optinoCollateralToken).send(optinoData.baseTokens), "_mintOptinoTokens: optinoCollateralToken.send(baseTokens) failure");
                if (uiFee > 0) {
                    require(payable(uiFeeAccount).send(uiFee), "_mintOptinoTokens: uiFeeAccount.send(uiFee) failure");
                }
                // Dev fee left in this factory
                uint refund = msg.value - optinoData.baseTokens - uiFee - devFee;
                if (refund > 0) {
                    require(msg.sender.send(refund), "_mintOptinoTokens: msg.sender.send(refund) failure");
                }
            } else {
                require(ERC20Interface(optinoData.baseToken).transferFrom(msg.sender, address(optinoCollateralToken), optinoData.baseTokens), "_mintOptinoTokens: baseToken.transferFrom(msg.sender, optinoCollateralToken, baseTokens) failure");
                if (uiFee > 0) {
                    require(ERC20Interface(optinoData.baseToken).transferFrom(msg.sender, uiFeeAccount, uiFee), "_mintOptinoTokens: baseToken.transferFrom(msg.sender, uiFeeAccount, uiFee) failure");
                }
                if (devFee > 0) {
                    require(ERC20Interface(optinoData.baseToken).transferFrom(msg.sender, address(this), devFee), "_mintOptinoTokens: baseToken.transferFrom(msg.sender, factory, devFee) failure");
                }
            }
        } else {
            uint quoteTokens = optinoData.baseTokens * optinoData.strike / (10 ** config.rateDecimals);
            uint devFee = quoteTokens * config.fee / (10 ** FEEDECIMALS);
            uint uiFee;
            if (uiFeeAccount != address(0) && uiFeeAccount != owner) {
                uiFee = devFee / 2;
                devFee = devFee - uiFee;
            }
            if (optinoData.quoteToken == ETH) {
                require(msg.value >= (quoteTokens + uiFee + devFee), "_mintOptinoTokens: Insufficient ETH sent");
                require(payable(optinoCollateralToken).send(quoteTokens), "_mintOptinoTokens: optinoCollateralToken.send(quoteTokens) failure");
                if (uiFee > 0) {
                    require(payable(uiFeeAccount).send(uiFee), "_mintOptinoTokens: uiFeeAccount.send(uiFee) failure");
                }
                // Dev fee left in this factory
                uint refund = msg.value - quoteTokens - uiFee - devFee;
                if (refund > 0) {
                    require(msg.sender.send(refund), "_mintOptinoTokens: msg.sender.send(refund) failure");
                }
            } else {
                require(ERC20Interface(optinoData.quoteToken).transferFrom(msg.sender, address(optinoCollateralToken), quoteTokens), "_mintOptinoTokens: quoteToken.transferFrom(msg.sender, optinoCollateralToken, quoteTokens) failure");
                if (uiFee > 0) {
                    require(ERC20Interface(optinoData.quoteToken).transferFrom(msg.sender, uiFeeAccount, uiFee), "_mintOptinoTokens: quoteToken.transferFrom(msg.sender, uiFeeAccount, uiFee) failure");
                }
                if (devFee > 0) {
                    require(ERC20Interface(optinoData.quoteToken).transferFrom(msg.sender, address(this), devFee), "_mintOptinoTokens: quoteToken.transferFrom(msg.sender, factory, devFee) failure");
                }
            }
        }
        return (series.optinoToken, series.optinoCollateralToken);
    }

    function payoffDeliveryInBaseOrQuote(uint _callPut) public pure returns (uint) {
        return _callPut; // Call on ETH/DAI - payoff in baseToken (ETH); Put on ETH/DAI - payoff in quoteToken (DAI)
    }
    function payoffInDeliveryToken(uint _callPut, uint _strike, uint _spot, uint _baseTokens, uint _baseDecimals, uint _rateDecimals) public pure returns (uint _payoff, uint _collateral) {
        return VanillaOptinoFormulae.payoffInDeliveryToken(_callPut, _strike, _spot, _baseTokens, _baseDecimals, _rateDecimals);
    }

    function getTokenInfo(address token, address tokenOwner, address spender) public view returns (string memory _symbol, string memory _name, uint _decimals, uint _totalSupply, uint _balance, uint _allowance) {
        if (token == ETH) {
            return ("ETH", "Ether", 18, 0, tokenOwner.balance, 0);
        } else {
            return (TokenInterface(token).symbol(), TokenInterface(token).name(), TokenInterface(token).decimals(), TokenInterface(token).totalSupply(), TokenInterface(token).balanceOf(tokenOwner), TokenInterface(token).allowance(tokenOwner, spender));
        }
    }
}
