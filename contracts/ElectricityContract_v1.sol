pragma solidity ^0.4.18;

import "./EternalStorage.sol";

contract ElectricityContract_v1 is EternalStorage {
    
    function initialize(uint _rate) public {
        require(!initialized());

        uintStorage[keccak256("rate")] = _rate;
        boolStorage[keccak256("ElectricityContract_v1_initialized")] = true;

        setPayer(address(0));
    }

    function initialized() public view returns (bool) {
        return boolStorage[keccak256("ElectricityContract_v1_initialized")];
    }

    function newPayer(address _payer) public {
        require(_payer != address(0));
        require(addressStorage[keccak256("payer",_payer)] == address(0));

        uintStorage[keccak256("numPayers")] += 1;
        setPayer(_payer);
    }

    function numPayers() public view returns (uint) {
        return uintStorage[keccak256("numPayers")];
    }
    
    function setPayer(address _payer) internal {

        bytes32 numPayments = keccak256("numPayments",_payer);

        addressStorage[keccak256("payer",_payer)] = _payer;
        uintStorage[keccak256("lastIndex",_payer)] = 0;
        uintStorage[keccak256("debt",_payer)] = 0;
        uintStorage[keccak256("overpayment",_payer)] = 0;
        uintStorage[numPayments] = 0;

        uint paymentId = uintStorage[numPayments];
        setPayment(_payer, paymentId, 0, 0, 0, 0, 0);
    }

    function newPayment(address _payer, uint _newIndex) public payable {
        require(_payer != address(0));
        require(addressStorage[keccak256("payer",_payer)] != address(0));
        
        bytes32 lastIndex = keccak256("lastIndex",_payer);
        bytes32 debt = keccak256("debt",_payer);
        bytes32 overpayment = keccak256("overpayment",_payer);
        bytes32 numPayments = keccak256("numPayments",_payer);

        require(_newIndex >= uintStorage[lastIndex]);

        uint amount = getAmountToPay(_newIndex, uintStorage[lastIndex]);

        if (msg.value > amount){
            uint _overpayment = msg.value - amount;
            if (uintStorage[debt] > _overpayment){
                uintStorage[debt] -= _overpayment;
            } else {
                uintStorage[overpayment] += _overpayment - uintStorage[debt];
                uintStorage[debt] = 0;
            }
        } else {
            uint _debt = amount - msg.value;
            if (uintStorage[overpayment] > _debt){
                uintStorage[overpayment] -= _debt;
            } else {
                uintStorage[debt] += _debt - uintStorage[overpayment];
                uintStorage[overpayment] = 0;
            }
        } 

        uint paymentId = uintStorage[numPayments] + 1;
        setPayment(_payer, paymentId, _newIndex, uintStorage[lastIndex], uintStorage[keccak256("rate")], amount, msg.value);
        
        uintStorage[lastIndex] = _newIndex;
        uintStorage[numPayments] = paymentId;
    }

    
    function setPayment(address payer, uint paymentId, uint indexNew, uint indexOld, uint rate, uint amount, uint payed) internal {

        uintStorage[keccak256("indexNew",payer,paymentId)] = indexNew;
        uintStorage[keccak256("indexOld",payer,paymentId)] = indexOld;
        uintStorage[keccak256("rate",payer,paymentId)] = rate;
        uintStorage[keccak256("amount",payer,paymentId)] = amount;
        uintStorage[keccak256("payed",payer,paymentId)] = payed;
        uintStorage[keccak256("time",payer,paymentId)] = block.timestamp;
    }
    
    function getAmountToPay(uint _newIndex, uint _oldIndex) constant public returns (uint amount) {
        require(_newIndex >= _oldIndex);
        amount = (_newIndex - _oldIndex)*uintStorage[keccak256("rate")]; // amount to pay is return variable
    }
    
    function getPayment(address _payer, uint _index) constant public returns (uint indexOld, uint indexNew, uint rate, uint amount, uint payed, uint time) {
        require(_payer != address(0));
        require(addressStorage[keccak256("payer",_payer)] != address(0));
    
        indexNew = uintStorage[keccak256("indexNew",_payer,_index)];
        indexOld = uintStorage[keccak256("indexOld",_payer,_index)];
        rate = uintStorage[keccak256("rate",_payer,_index)];
        amount = uintStorage[keccak256("amount",_payer,_index)];
        payed = uintStorage[keccak256("payed",_payer,_index)];
        time = uintStorage[keccak256("time",_payer,_index)];
    }

}