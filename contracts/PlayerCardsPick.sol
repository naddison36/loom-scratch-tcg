pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import {CryptoBeastsTypes} from "./CryptoBeastsTypes.sol";
import {Cards} from "./Cards.sol";

contract PlayerCardsPick is CryptoBeastsTypes {

    struct PlayerCard {
        uint cardId;

        uint16 health;
        uint16 defence;
        uint16 mana;

        uint16 attack;
        uint16 specialAttack;
    }

    struct PlayerDeck {
        PlayerCard[] playerCards;
        uint8 currentCard;
    }

    Cards cardsContract;
    address public player1;
    address public player2;
    mapping (address => PlayerDeck) public playerDecks;
    bool public cardsPicked;
    address public playersTurn;

    constructor(address _player1, address _player2, address cardsAddress) public {
        player1 = _player1;
        player2 = _player2;

        cardsContract = Cards(cardsAddress);
    }

    function _setPlayerCard(PlayerCard[] storage playerCards, uint cardId) internal {

        Card memory card = cardsContract.getCard(cardId);

        playerCards.push( PlayerCard({
            cardId: cardId,
            health: card.initHealth,
            defence: card.initDefence,
            mana: card.initMana,
            attack: card.attack,
            specialAttack: card.specialAttack
        }));
    }

    function getPlayerCurrentCard(address player) public view returns (PlayerCard memory) {

        uint8 deckNumber = playerDecks[player].currentCard;

        return playerDecks[player].playerCards[deckNumber];
    }

    function getPlayersCurrentCardNumber(address player) public view returns (uint8) {
        return playerDecks[player].currentCard;
    }

    function getPlayerDeck(address player) public view returns (PlayerDeck memory) {
        return playerDecks[player];
    }

    function pickPayerCards(uint[5] memory desiredCards) public {

        PlayerCard[] storage playerCards = playerDecks[msg.sender].playerCards;
        require(playerCards.length == 0, 'Player has already picked their cards');

        if (player1 == msg.sender) {
            if (playerDecks[player2].playerCards.length > 0) {
                cardsPicked = true;
            }
        }
        else if (player2 == msg.sender) {
            if (playerDecks[player1].playerCards.length > 0) {
                cardsPicked = true;
            }
        } else {
            revert('Transaction sender must be player 1 or 2');
        }

        uint[3] memory pickedCardNumbers = [
            desiredCards[0],
            desiredCards[1],
            desiredCards[2]];

        _setPlayerCard(playerCards, desiredCards[0]);
        _setPlayerCard(playerCards, desiredCards[1]);
        _setPlayerCard(playerCards, desiredCards[2]);

        emit PickPayerCards(desiredCards, pickedCardNumbers);

        if (cardsPicked) {
            startBattle();
        }
    }

    event PickPayerCards(uint[5] desiredCards, uint[3] pickedCards);

    function startBattle() internal {
        require(cardsPicked, 'Both players have to have picked their cards');

        uint16 player1MaxSpeed = calcMaxSpeed(playerDecks[player1].playerCards);
        uint16 player2MaxSpeed = calcMaxSpeed(playerDecks[player2].playerCards);

        if (player1MaxSpeed >= player2MaxSpeed) {
            playersTurn = player1;
        }
        else {
            playersTurn = player2;
        }
    }

    function calcMaxSpeed(PlayerCard[] memory playerCards) public returns (uint16) {

        uint16 maxSpeed = 0;

        for (uint i=0; i<playerCards.length; i++) {

            uint16 cardSpeed = cardsContract.getCard(playerCards[i].cardId).speed;

            if (cardSpeed > maxSpeed) {
                maxSpeed = cardSpeed;
            }
        }

        return maxSpeed;
    }
}