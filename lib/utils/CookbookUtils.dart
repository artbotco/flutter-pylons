import 'dart:ffi';

import 'package:pylons_sdk/pylons_sdk.dart';

String cookBookId = "artbot_cookbook_0";

var cookBook = Cookbook(
    creator: "",
    iD: cookBookId,
    name: "Artbot Cookbook",
    nodeVersion: "v0.1.3",
    description: "Cookbook",
    developer: "Artbot.tv",
    version: "v0.0.1",
    supportEmail: "support@artbot.tv",
    costPerBlock: Coin(denom: "upylon", amount: "1000000"),
    enabled: true);

class CookbookUtils {
  void createCookBook() async {
    var response = await PylonsWallet.instance.txCreateCookbook(cookBook);
  }

  void getCookbook() async {
    var sdkResponse = await PylonsWallet.instance.getCookbook(cookBookId);
    // log(sdkResponse.toString(), name: 'pylons_sdk');
  }

  void updateCookBook() async {
    var response = await PylonsWallet.instance.txUpdateCookbook(cookBook);
    // log('From App $response', name: 'pylons_sdk');
  }
}

/*
tickets and recipes
 */

String createTicketRecipeId = "create_ticket_recipe";
String decrementTicketRecipeId = "decrement_ticket_recipe";
String transferTicketRecpipeId = "transfer_ticket_recipe";

String itemId = "ticket_id";

var usesInputParam = LongInputParam(key: "uses", minValue: Int64(0));

ItemInput createTicketItemInput(int ticketUses) {
  return ItemInput(
      iD: itemId,
      doubles: [],
      longs: [usesInputParam],
      strings: [],
      conditions: ConditionList(doubles: [], longs: [], strings: []));
}

var ticketItemOutput = ItemOutput(
  iD: itemId,
  doubles: [],
  longs: [],
  strings: [],
  mutableStrings: [],
  transferFee: [],
  tradePercentage: DecString.decStringFromDouble(1),
  tradeable: false,
);

Recipe createTicketRecipe() {
  return Recipe(
      cookbookID: cookBookId,
      iD: createTicketRecipeId,
      nodeVersion: "v0.1.3",
      name: "CreateTicketRecipe",
      description: "Create a ticket",
      version: "v0.1.3",
      coinInputs: [],
      itemInputs: [],
      entries: EntriesList(
          coinOutputs: [],
          itemOutputs: [ticketItemOutput],
          itemModifyOutputs: []),
      outputs: [
        WeightedOutputs(entryIDs: ["ticket"], weight: Int64(1))
      ],
      blockInterval: Int64(0),
      enabled: true,
      extraInfo: "extraInfo");
}

Recipe createDecrementTicketRecipe(ItemInput item) {
  return Recipe(
      cookbookID: cookBookId,
      iD: decrementTicketRecipeId,
      nodeVersion: "v0.1.3",
      name: "DecrementTicketRecipe",
      description: "Decrement a ticket",
      version: "v0.1.3",
      coinInputs: [],
      itemInputs: [item],
      entries: EntriesList(
          coinOutputs: [],
          itemOutputs: [ticketItemOutput],
          itemModifyOutputs: []),
      outputs: [
        WeightedOutputs(entryIDs: ["ticket"], weight: Int64(1))
      ],
      blockInterval: Int64(0),
      enabled: true,
      extraInfo: "extraInfo");
}

ItemModifyOutput getItemModifyOutput(
    {required String id, required String input}) {
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

class RecipeUtils {
  void createRecipe({required Recipe recipe}) async {
    var response = await PylonsWallet.instance.txCreateRecipe(recipe);

    // log('From App $response', name: 'pylons_sdk');
  }

  void executeRecipe({required String recipeId}) async {
    var response = await PylonsWallet.instance.txExecuteRecipe(
        cookbookId: cookBookId,
        recipeName: recipeId,
        coinInputIndex: 0,
        itemIds: [],
        paymentInfo: []);

    // log('From App $response', name: 'pylons_sdk');
  }

  void updateRecipe({required Recipe recipe}) async {
    var response = await PylonsWallet.instance.txUpdateRecipe(recipe);
    // log('From App $response', name: 'pylons_sdk');
  }
}

class TicketTier {}

class PublicInterface {
  void setupRecipes() {
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

  ItemOutput createTicketForTier(TicketTier tier) {
    if (tier == TicketTier.Silver) {
      TicketCreation.executeCreateTicketRecipe(tier: TicketTier.Silver);
      return silverTicket;
    }

    if (tier == TicketTier.Bronze) {
      TicketCreation.executeCreateTicketRecipe(tier: TicketTier.Bronze);
      return bronzeTicket;
    }

    if (tier == TicketTier.Gold) {
      TicketCreation.executeCreateTicketRecipe(tier: TicketTier.Gold);
      return goldTicket;
    }

    throw 1;
  }

  void decrementTicket(ItemOutput ticket) {
    TicketDecrement.executeDecrementTicketRecipe(ticket.iD);
  }
}
