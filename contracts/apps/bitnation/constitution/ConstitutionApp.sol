pragma solidity ^0.4.13;

/**
* @author Eliott Teissonniere (Bitnation)
* @description Let the DBVN timestamp its constitution on chain.
* The DBVN can:
*  -  add an article
*  -  repeal an article
* Anyone can see the articles
*/

import "../../Application.sol";

import "./IConstitutionApp.sol";

contract ConstitutionApp is IConstitutionApp, Application {
    struct Article {
        string summary;
        string reference;

        uint addedOn;
        uint repealedOn;
    }

    Article[] public allArticles;

    function ConstitutionApp(address dao) Application(dao) {
    }

    /**
    * @notice add an article
    * @param articleSummary summary of the article
    * @param articleReference ipfs hash to a doc associated
    * @return articleID id of the new article (also in the event log)
    */
    function addArticle(string articleSummary, string articleReference) onlyDAO external returns (uint articleID) {
        articleID = allArticles.length++;

        allArticles[articleID] = Article({summary: articleSummary, reference: articleReference, addedOn: now, repealedOn: 0});

        ArticleChanged(articleID, true);
    }

    /**
    * @notice repeal (invalid) an article, also trigger an event
    * @param articleID id of the article to repeal
    */
    function repealArticle(uint articleID) onlyDAO external {
        require(isValid(articleID)); // Do not repeal already repealed articles

        allArticles[articleID].repealedOn = now;

        ArticleChanged(articleID, false);
    }

    /**
    * @notice simple getter to get an article by its ID
    * @param articleID id of the article
    */
    function getArticle(uint articleID) constant returns (string articleSummary, string articleReference, uint addedOn, uint repealedOn) {
        articleSummary = allArticles[articleID].summary;
        articleReference = allArticles[articleID].reference;
        addedOn = allArticles[articleID].addedOn;
        repealedOn = allArticles[articleID].repealedOn;
    }

    function isValid(uint articleID) constant returns (bool isValid) {
        return allArticles[articleID].addedOn > 0 && allArticles[articleID].repealedOn == 0;
    }
}
