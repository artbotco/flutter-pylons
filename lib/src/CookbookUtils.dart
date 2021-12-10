import 'dart:ffi';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:pylons_sdk/pylons_sdk.dart';
import 'dart:developer';

String cookBookId = "cookbook_arbot_1";

var cookBook = Cookbook(
    creator: "Artbot.tv",
    iD: cookBookId,
    name: "Artbot Cookbook",
    nodeVersion: "v0.1.3",
    description: "Cookbook, maybe this has to be really long too",
    developer: "Artbot.tv",
    version: "v0.0.1",
    supportEmail: "support@artbot.tv",
    enabled: true
);

String createTicketRecipeId = "create_ticket_recipe";
String bronzeRecipeId = "bronzeTicketRecipe";
String silverRecipeId = "silverTicketRecipe";
String goldRecipeId = "goldTicketRecipe";
String decrementTicketRecipeId = "decrement_ticket_recipe";
String transferTicketRecpipeId = "transfer_ticket_recipe";

String itemId = "ticket_id";

var usesInputParam  = LongInputParam(key: "uses", minValue: Int64(0));

enum TicketTier {
  Gold,
  Silver,
  Bronze
}

class PublicInterface {

  static void createCookbook() async{
    var response = await PylonsWallet.instance.txCreateCookbook(cookBook);
    if (response.success) {
    log('cookbook create success');
    } else {
      log('cook create failed');
    }
  }

  static void setupRecipes(){
    var bronzeRecipe = createTicketRecipe(TicketTier.Bronze);
    var silverRecipe = createTicketRecipe(TicketTier.Silver);
    var goldRecipe = createTicketRecipe(TicketTier.Gold);
    TicketCreation.createCreateTicketRecipe(recipe: bronzeRecipe);
    TicketCreation.createCreateTicketRecipe(recipe: silverRecipe);
    TicketCreation.createCreateTicketRecipe(recipe: goldRecipe);

    TicketDecrement.createDecrementTicketRecipe(bronzeTicket);
    TicketDecrement.createDecrementTicketRecipe(silverTicket);
    TicketDecrement.createDecrementTicketRecipe(goldTicket);
  }

  static ItemOutput createTicketForTier(TicketTier tier){

    if (tier == TicketTier.Silver) {
      TicketCreation.executeCreateTicketRecipe(tier: TicketTier.Silver);
      return silverTicket;
    }

    if (tier == TicketTier.Bronze){
      TicketCreation.executeCreateTicketRecipe(tier: TicketTier.Bronze);
      return bronzeTicket;
    }

    if (tier == TicketTier.Gold){
      TicketCreation.executeCreateTicketRecipe(tier: TicketTier.Gold);
      return goldTicket;
    }

    throw 1;
  }

  void decrementTicket(ItemOutput ticket){
    TicketDecrement.executeDecrementTicketRecipe(ticket.iD);
  }
}


var bronzeTicket = ItemOutput(
  iD: "bronzeTicket",
  doubles: [ ],
  longs: [ ],
  strings: [],
  mutableStrings: [],
  transferFee: [],
  tradePercentage: DecString.decStringFromDouble(1),
  tradeable: false,
);
var silverTicket = ItemOutput(
  iD: "silverTicket",
  doubles: [ ],
  longs: [ ],
  strings: [],
  mutableStrings: [],
  transferFee: [],
  tradePercentage: DecString.decStringFromDouble(1),
  tradeable: false,
);
var goldTicket = ItemOutput(
  iD: "goldTicket",
  doubles: [ ],
  longs: [ ],
  strings: [],
  mutableStrings: [],
  transferFee: [],
  tradePercentage: DecString.decStringFromDouble(1),
  tradeable: false,
);


Recipe createTicketRecipe(TicketTier tier){
  var lparam = LongParam(key: "uses");

  var ticketItemOutput;

  var recipeId = "";
  if (tier == TicketTier.Bronze){
    // lparam.setField(0, 1);
    recipeId = bronzeRecipeId;
    ticketItemOutput = bronzeTicket;
  }
  else if (tier == TicketTier.Silver){
    // lparam.setField(0, 3);
    recipeId = silverRecipeId;
    ticketItemOutput = silverTicket;
  }
  else if (tier == TicketTier.Gold){
    // lparam.setField(0, 5);
    recipeId = goldRecipeId;
    ticketItemOutput = goldTicket;
  }

  ticketItemOutput.iD = itemId;
  // ticketItemOutput.longs.add(lparam);

  return Recipe(
      cookbookID: cookBookId,
      iD: recipeId,
      nodeVersion: "v0.1.3",
      name: recipeId,
      description: "Create a ticket and make this at least 20 characters.",
      version: "v0.1.3",
      coinInputs: [],
      itemInputs: [],
      entries: EntriesList(
          coinOutputs: [],
          itemOutputs: [ ticketItemOutput ],
          itemModifyOutputs: []
      ),
      outputs: [ WeightedOutputs(entryIDs: ["ticket"], weight: Int64(1)) ],
      blockInterval: Int64(0),
      enabled: true,
      extraInfo: "extraInfo");
}

ItemModifyOutput getItemModifyOutput({required String id, required String input }){
  return ItemModifyOutput(
      iD: id,
      itemInputRef: input,
      doubles: [],
      longs: [],
      strings: [],
      mutableStrings: [],
      transferFee: [],
      tradePercentage: DecString.decStringFromDouble(0.2),
      quantity: Int64(1));
}

class TicketCreation {
  static void createCreateTicketRecipe({required Recipe recipe}) async {
    var response = await PylonsWallet.instance.txCreateRecipe(recipe);

    log('From App $response', name: 'pylons_sdk');
  }
  static void executeCreateTicketRecipe({required TicketTier tier}) async {
    String recipeId = "";
    if (tier == TicketTier.Bronze) {
      recipeId = bronzeRecipeId;
    }
    else if (tier == TicketTier.Silver) {
      recipeId = silverRecipeId;
    }
    else if (tier == TicketTier.Gold) {
      recipeId = goldRecipeId;
    }

    var response = await PylonsWallet.instance.txExecuteRecipe(
        cookbookId: cookBookId,
        recipeName: recipeId,
        coinInputIndex: 0,
        itemIds: [],
        paymentInfo: []
    );

    log('From App $response', name: 'pylons_sdk');
    if (response.success){
      
    }
  }
}

class TicketDecrement {
  static void createDecrementTicketRecipe(ItemOutput ticketItemOutput) async {
    var uses = ticketItemOutput.longs.first;
    var count = uses.getField(0);
    uses.setField(0, count - 1);
    var input = ItemInput(iD: ticketItemOutput.iD, doubles: [], longs: [], strings: [], conditions: null);

    var recipe = Recipe(cookbookID: cookBookId, iD: decrementTicketRecipeId,
        nodeVersion: "",
        name: decrementTicketRecipeId,
        description: "",
        version: "",
        coinInputs: [],
        itemInputs: [ input ],
        entries: EntriesList(
            coinOutputs: [],
            itemOutputs: [ ticketItemOutput ],
            itemModifyOutputs: []
        ),
        outputs: [ WeightedOutputs(entryIDs: ["ticket"], weight: Int64(1)) ],
        blockInterval: Int64(0),
        enabled: false,
        extraInfo: null);
    var response = await PylonsWallet.instance.txCreateRecipe(recipe);
    log('From App $response', name: 'pylons_sdk');
  }
  static void executeDecrementTicketRecipe(String ticketId){
    PylonsWallet.instance.txExecuteRecipe(cookbookId: cookBookId, recipeName: decrementTicketRecipeId, itemIds: [ ticketId ], coinInputIndex: 0, paymentInfo: []);
  }
}
