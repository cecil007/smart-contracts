pragma solidity ^0.4.18;


contract PermissionLevels {

    address public admin;
    address public pendingAdmin;
    mapping(address=>bool) public operators;
    mapping(address=>bool) public alerters;
    address[] public operatorsGroup;
    address[] public alertersGroup;

    function PermissionLevels() public {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require (msg.sender == admin);
        _;
    }

    modifier onlyOperator() {
        require (operators[msg.sender]);
        _;
    }

    modifier onlyAlerter() {
        require (alerters[msg.sender]);
        _;
    }

    event TransferAdmin( address pendingAdmin );
    /**
     * @dev Allows the current admin to set the pendingAdmin address.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdmin(address newAdmin) public
        onlyAdmin
    {
        require(newAdmin !=  address(0));
        TransferAdmin(pendingAdmin);
        pendingAdmin = newAdmin;
    }

    event ClaimedAdmin( address newAdmin, address previousAdmin);

    /**
     * @dev Allows the pendingAdmin address to finalize the change admin process.
     */
    function claimAdmin() public {
        require(pendingAdmin == msg.sender);
        ClaimedAdmin(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    function addAlerter( address newAlerter ) public
        onlyAdmin
    {
        require(!alerters[newAlerter]); // prevent duplicates.
        alerters[newAlerter] = true;
        alertersGroup.push(newAlerter);
    }

    event RemovedAlerter ( address alerter );

    function removeAlerter ( address alerter ) public
        onlyAdmin
    {
        if (!alerters[alerter]) revert();

        for (uint i = 0; i < alertersGroup.length; ++i)
        {
            if (alertersGroup[i] == alerter)
            {
                alertersGroup[i] = alertersGroup[alertersGroup.length - 1];
                alertersGroup.length -= 1;
                RemovedAlerter(alerter);
                break;
            }
        }
    }

    function addOperator( address newOperator ) public
        onlyAdmin
    {
        require(!operators[newOperator]); // prevent duplicates.
        operators[newOperator] = true;
        operatorsGroup.push(newOperator);
    }

    event RemovedOperator ( address operator );

    function removeOperator ( address operator ) public
        onlyAdmin
    {
        if (!operators[operator]) revert();

        for (uint i = 0; i < operatorsGroup.length; ++i)
        {
            if (operatorsGroup[i] == operator)
            {
                operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];
                operatorsGroup.length -= 1;
                RemovedOperator(operator);
                break;
            }
        }
    }
}
