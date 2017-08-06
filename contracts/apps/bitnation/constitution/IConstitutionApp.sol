pragma solidity ^0.4.13;

/**
* @author Eliott Teissonniere (Bitnation)
*/

contract IConstitutionApp {
    event ArticleChanged(uint indexed articleID, bool isValidArticle);

    function addArticle(string articleSummary, string articleReference) external returns (uint articleID);
    function repealArticle(uint articleID) external;

    function getArticle(uint articleID) constant returns (string articleSummary, string articleReference, uint addedOn, uint repealedOn);
    function isValidArticle(uint articleID) constant returns (bool isValidArticle);
}
