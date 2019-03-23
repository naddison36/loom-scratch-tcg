pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Cards is Ownable {

    event NewCard(uint cardId, Card card);

    struct Card {
        string name;
        string ability;

        uint16 initHealth;  // 0-1000
        uint16 initDefence; // 0-500
        uint16 initMana;    // 0-20

        uint16 speed;   // 0-500
        uint16 attacks; // 0-120
        uint16 specialAttacks; // 120-240
    }

    Card[] public cards;

    function createCard(Card memory card) public
        onlyOwner()
    {
        uint cardId = cards.push(card) - 1;
        emit NewCard(cardId, card);
    }
}