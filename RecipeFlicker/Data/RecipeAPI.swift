//
//  API.swift
//  RecipeFlicker
//
//  Created by Kenta Kodashima on 2018-10-16.
//  Copyright © 2018 Kenta Kodashima. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct RecipeAPI {
  private let BASE_SEARCH_URL = "https://api.edamam.com/search?"
  private let APP_ID = EDAMAM_APP_ID
  private let APP_KEY = EDAMAM_APP_KEY
  private let DEFAULT_QUERY_PARAM = ["q=quick", "q=easy", "q=fast"]
  private var REQUEST_STRING: String {
    return BASE_SEARCH_URL + DEFAULT_QUERY_PARAM.randomElement()! + APP_ID + APP_KEY
  }
  
  func getRandomRecipes(completionHandler: @escaping ([Recipe]?, Error?) -> ()) {
    var recipeStore = [Recipe]()
    var randomRecipes = [Recipe]()
    let toParam = "&to=100"
    let fromParam = "&from=0"
    let requestString = REQUEST_STRING + fromParam + toParam
    
    Alamofire.request(requestString)
      .validate()
      .responseJSON { response in
        print(response.result)
        switch response.result {
        case .success(let value):
          let json = JSON(value)
          for result in json["hits"].arrayValue {
            var recipe = result["recipe"]
            let originalRecipeUrl = recipe["url"].stringValue
            let title = recipe["label"].stringValue
            let image = recipe["image"].stringValue
            let recipeObj = Recipe(originalRecipeUrl: originalRecipeUrl, title: title, image: image, isFavorite: false)
            recipeStore.append(recipeObj)
          }
          while randomRecipes.count < 15 {
            let randomRecipe = recipeStore.randomElement()!
            randomRecipes.append(randomRecipe)
            recipeStore.remove(at: recipeStore.firstIndex(of: randomRecipe)!)
          }
          print(randomRecipes.count)
          completionHandler(randomRecipes, nil)
        case .failure(let error):
          completionHandler(nil, error)
        }
      }
  }
}
