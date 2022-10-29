//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;
// import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

// This is the main building block for smart contracts.
contract Refund {
    // Model a Candidate

    event CompletedEvent (
        address employeeaddress
    );

    event FailedEvent (
        address employeeaddress
    );
    // employee data
    struct Employee {
        uint id;
        string employeename;
        address employeeaddress;
    }

    //employer data
    struct Employer {
        uint id;
        string employername;
        address employeraddress;
    }

    //contract data with boundary points , durations , completion checkers
    struct contract_data{
        uint id;
        uint employeelatitude;
        uint employeelonguited;
        uint starting_time;
        uint duration;
        uint gathered_location_count;
        bool contract_truth;
        bool completed;
        // creating struct instances 
        Employee employees;
        Employer employer;
    }
    
    // contracts that have been recorded 
    mapping(address => contract_data) public contracts;
    
    uint public Contractcount;

    // Employees that have been recorded
    mapping(address => Employee) public employees;
    
    mapping (uint => address) public employee_mapping;
 
    uint public Employeecount;

    // employer that have been recorded
    mapping(address => Employer) public employers;
    uint public Employercount;

            // adding employer
    function  initialize_employers(address[] memory m) public {
        for (uint add=0 ; add < m.length; add++){
            addEmployer(string.concat("Employer " , string.toString(add)) , m[add]);
            }
    }
            // adding employee
   function  initialize_employees(address[] memory m) public{
         for (uint add=0 ; add < m.length; add++){
            addEmployee(string.concat("Employee " , string.toString(add)) , m[add]);
            }
    }

    function addEmployer (string memory _name , address user_address) private {
        Employercount ++;
        employers[user_address] = Employer(Employercount, _name, user_address);
    }
    function addEmployee (string memory _name , address user_address) private {
        Employeecount ++;
        employees[user_address] = Employee(Employeecount, _name, user_address);
    }

    function Create_contract_data( uint[2] memory employeelatitude, uint[2] memory employeelonguited, uint duration, string memory employee_name , address employee_address, address employer_address) public{
        if (! (employees[employee_address].id > 0)){
            addEmployee(employee_name, employee_address);
            employee_mapping[Employeecount] = employee_address;
         }
        Contractcount++;
        contracts[employee_address] = contract_data(Contractcount, employeelatitude[0] , employeelonguited[1], block.timestamp ,duration , 0 ,true , false ,employees[employee_address],employers[employer_address]);
    }

    function get_location( uint  longitude, uint  latitude) public  returns (bool){
        
        contract_data memory found_contract = contracts[msg.sender];
        if (found_contract.id > 0){
        if ( found_contract.completed != true){
            uint duration = (block.timestamp - found_contract.starting_time) / 60 ;
            if (duration < found_contract.duration){ 
                found_contract.gathered_location_count = found_contract.gathered_location_count + 1;
                if (! (found_contract.employeelonguited <= longitude && found_contract.employeelatitude <= latitude) ){
                    found_contract.contract_truth = false;
                }
            }else if ( duration >=found_contract.duration){
                check_completion(found_contract);
               
            }
        }
            return true;
            }else{
                return false;
            }
    }

    function check_completion(contract_data memory found_contract) private{
        uint minimum_check = found_contract.duration * 3 / 4 ;
        if (found_contract.contract_truth && minimum_check <= found_contract.gathered_location_count){
                    found_contract.completed = true;
                    emit CompletedEvent(found_contract.employees.employeraddress);
                }
                else{
                    found_contract.completed = false;
                    emit FailedEvent(found_contract.employees.employeraddress);
                }
    }

}