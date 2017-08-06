pragma solidity ^0.4.13;

/**
* @author Eliott Teissonniere (Bitnation)
*/

contract ICodeOfLawApp {
    event LawChanged(uint indexed lawID, bool isValid);

    function addLaw(string lawSummary, string lawReference) external returns (uint lawID);
    function repealLaw(uint lawID) external;

    function getLaw(uint lawID) constant returns (string lawSummary, string lawReference, uint addedOn, uint repealedOn);
    function isValid(uint lawID) constant returns (bool isValid);
}
