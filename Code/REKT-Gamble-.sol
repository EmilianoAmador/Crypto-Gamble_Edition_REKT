pragma solidity >0.4.0;
contract REKTBet {
   address public owner;
   uint256 public minimumBet = 100 finney;            // Equal to 0.1 ether
   uint256 public totalBet;
   uint256 public numberOfBets;
   uint public maxAmountOfBets = 4;
   uint public constant LIMIT_AMOUNT_BETS = 4;   // The max amount of bets that cannot be exceeded to avoid excessive gas consumption
   uint256 public triumphantTeam;
   address[] public players;
   struct Player {                                        //created to keep track of players bet amount and their team selection
      uint256 amountBet;
      uint256 teamSelected;
   }
   modifier onEndGame(){                              // Modifier to only allow the execution of functions when the bets are completed
      if(numberOfBets >= maxAmountOfBets) _;         // **normally its a time restriction but for presentation make bet amount the restrictor
   } 
      
   // The address of the player and => the user info   
   mapping(address => Player) public playerInfo;          // created so that python and other functions can access its properties like so, playerInfo[here_goes_his_address].amountBet
   function() public payable {}                                  // fallback function that acts as treasury of the contract.
   
   // Constructor because its same name as the contract
   constructor (uint256 _minimumBet) public {                   // here users place amount they desire to bet.
      owner = msg.sender;
      if(_minimumBet != 0 ) minimumBet = _minimumBet;              // if minimum bet is not 0 then continue
   }
   
   function kill() public {
      if(msg.sender == owner) selfdestruct(owner);
   }
   
   function checkPlayerExists(address player) public constant returns(bool){
      for(uint256 i = 0; i < players.length; i++){
         if(players[i] == player) return true;
      }
      return false;
   }
   // To bet for a team                                        //add verification that same address
   function bet(uint256 teamSelected) public payable {           // Here they select which team to bet on.
      require(!checkPlayerExists(msg.sender));
      require(msg.value >= minimumBet);
      require(teamSelected >= 0 && teamSelected <= 1);                                                          // This is possible because of the mapping declared above.
      playerInfo[msg.sender].amountBet = msg.value;                 // Defines the amount Bet.
      playerInfo[msg.sender].teamSelected = teamSelected;            //stores teamSelected
      numberOfBets++;                                                //Increases the numberOfBets by 1 each time. Allows us to stop it when reaches max number of bets
      players.push(msg.sender);                                      //array.push() used to increase array in Player struct
      totalBet += msg.value;                                         //Increases the funds in the pot that user has recently placed.
    }
   
   // Gets a 1 or 0 from python depending who won     
   function getTeamVictor(uint256 _teamVictor) public {          //This is where python will tell contract which user won based on which basketball team won.
      triumphantTeam = _teamVictor;                                  //python will decide to send address of all the W 
      distributePrizes(triumphantTeam);
   }
   // Sends the corresponding ether to the bet winning user
   function distributePrizes(uint256 numberWinner) public onEndGame {
      address[4] memory winners;                                  // We have to create a temporary in memory array with fixed size
      uint256 count = 0;                                            // This is the count for the array of winners
      for(uint256 i = 0; i < players.length; i++){
         address playerAddress = players[i];
         if(playerInfo[playerAddress].teamSelected == numberWinner){
            winners[count] = playerAddress;
            count++;
         }
         delete playerInfo[playerAddress];                           // Delete all the players
      }
      players.length = 0;                                            // Delete all the players array
      uint256 winnerEtherAmount = totalBet / winners.length;         // How much each winner gets
      for(uint256 j = 0; j < count; j++){
         if(winners[j] != address(0))                                // Check that the address in this fixed array is not empty
         winners[j].transfer(winnerEtherAmount);                     // sends the corresponding amount of ether for each winner
      }
   }
}