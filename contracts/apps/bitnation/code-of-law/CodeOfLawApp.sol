pragma solidity ^0.4.13;

/**
* @author Eliott Teissonniere (Bitnation)
* @description Let the DBVN timestamp its code of laws on chain.
* The DBVN can:
*  -  add a law
*  -  repeal a law
* Anyone can see the laws
*/

import "../../Application.sol";

import "./ICodeOfLawApp.sol";

contract CodeOfLawApp is ICodeOfLawApp, Application {
    struct Law {
        string summary;
        string reference;

        uint addedOn;
        uint repealedOn;
    }

    Law[] public allLaws;

    function CodeOfLawApp(address dao) Application(dao) {
    }

    /**
    * @notice add a law
    * @param lawSummary summary of the law
    * @param lawReference ipfs hash to a doc associated
    * @return lawID id of the new law (also in the event log)
    */
    function addLaw(string lawSummary, string lawReference) onlyDAO external returns (uint lawID) {
        lawID = allLaws.length++;

        allLaws[lawID] = Law({summary: lawSummary, reference: lawReference, addedOn: now, repealedOn: 0});

        LawChanged(lawID, true);
    }

    /**
    * @notice repeal (invalid) a law, also trigger an event
    * @param lawID id of the law to repeal
    */
    function repealLaw(uint lawID) onlyDAO external {
        require(isValidLaw(lawID)); // Do not repeal already repealed laws

        allLaws[lawID].repealedOn = now;

        LawChanged(lawID, false);
    }

    /**
    * @notice simple getter to get a law by its ID
    * @param lawID id of the law
    */
    function getLaw(uint lawID) constant returns (string lawSummary, string lawReference, uint addedOn, uint repealedOn) {
        lawSummary = allLaws[lawID].summary;
        lawReference = allLaws[lawID].reference;
        addedOn = allLaws[lawID].addedOn;
        repealedOn = allLaws[lawID].repealedOn;
    }

    function isValidLaw(uint lawID) constant returns (bool isValidLaw) {
        return allLaws[lawID].addedOn > 0 && allLaws[lawID].repealedOn == 0;
    }
}
