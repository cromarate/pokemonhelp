//
//  Pokemon.swift
//  Pokemon Heldesk
//
//  Created by Carlos Romarate Jr on 15/08/2016.
//  Copyright © 2016 Carlos Romarate Jr. All rights reserved.
//

import Foundation
import Alamofire



class Pokemon {
    private var _name: String!
    private var _pokedexId: Int!
    private var _description: String!
    private var _type: String!
    private var _defense: String!
    private var _height: String!
    private var _weight: String!
    private var _attack: String!
    private var _nextEvolutionTxt: String!
    private var _nextEvolutionID: String!
    private var _pokemonURL: String!
    
    var nextEvolutionID: String {
        if _nextEvolutionID == nil {
            _nextEvolutionID = ""
        }
        return _nextEvolutionID
    }
    
    var nextEvolutionTxt: String {
        if _nextEvolutionTxt == nil {
            _nextEvolutionTxt = ""
        }
        return _nextEvolutionTxt
    }
    
    var attack: String {
        if _attack == nil {
            _attack = ""
        }
        return _attack
    }
    
    var weight: String {
        if _weight == nil {
            _weight = ""
        }
        return _weight
    }
    
    var height: String {
        if _height == nil {
            _height = ""
        }
        return _height
    }
    
    var defense: String {
        if _defense == nil {
            _defense = ""
        }
        return _defense
    }
    
    var type: String {
        if _type == nil {
            _type = ""
        }
        return _type
    }
    
    var description: String {
        if _description == nil {
            _description = ""
        }
        return _description
    }
    
    var name: String {
        return _name
    }
    
    var pokedexId: Int {
        return _pokedexId
    }
    
    init(name: String, pokedexId: Int) {
        self._name = name
        self._pokedexId = pokedexId
        
        _pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(self.pokedexId)/"
    }
    
    func downloadPokemonDetails(completed: DownloadComplete) {
        
        let url = NSURL(string: _pokemonURL)!
        
        Alamofire.request(.GET, url).validate().responseJSON { Response in
            switch Response.result {
            case .Success:
                //print(Response.result.value)
                
                if let dict = Response.result.value as? Dictionary<String, AnyObject> {
                    if let weight = dict["weight"] as? String {
                        self._weight = weight
                    }
                    
                    if let height = dict["height"] as? String {
                        self._height = height
                    }
                    
                    if let attack = dict["attack"] as? Int {
                        self._attack = "\(attack)"
                    }
                    
                    if let defense = dict["defense"] as? Int {
                        self._defense = "\(defense)"
                    }
                    // becuase types is a dictionary with array of dictionaries
                    if let types = dict["types"] as? [Dictionary<String,String>] where types.count > 0 {
                        //print(types.debugDescription)
                        if let name = types[0]["name"] {
                            self._type = name.capitalizedString
                        }
                        
                        if types.count > 1 {
                            for var x=1; x < types.count; x++ {
                                if let name = types[x]["name"] {
                                    self._type! += "/\(name.capitalizedString)"
                                }
                            }
                        } else {
                            self._type = ""
                        }
                        
                        print(self._type)
                    }
//                    print(self._weight)
//                    print(self._height)
//                    print(self._attack)
//                    print(self._defense)
                    if let descArr = dict["descriptions"] as? [Dictionary<String,String>] where descArr.count > 0 {
                        if let url = descArr[0]["resource_uri"] {
                            
                            let url = NSURL(string: "\(URL_BASE)\(url)")!
                            Alamofire.request(.GET, url).validate().responseJSON { Response in
                                switch Response.result {
                                case .Success:
                                    if let descDist = Response.result.value as? Dictionary<String,AnyObject> {
                                        if let finalDesc = descDist["description"] as? String {
                                            self._description = "\(finalDesc)"
                                            print(self._description)
                                        }
                                    }
                                    completed()
                                case .Failure(let error):
                                    print("BOO! Request failed with error: \(error)")
                                }
                            }
                        } else {
                            self._description = ""
                        }
                        
                    }
                    if let evolutions = dict["evolutions"] as? [Dictionary<String,AnyObject>] where evolutions.count > 0 {
                        if let to = evolutions[0]["to"] as? String {
                            if to.rangeOfString("mega") == nil {
                                if let uri = evolutions[0]["resource_uri"] as? String {
                                    let newStr = uri.stringByReplacingOccurrencesOfString("/api/v1/pokemon/", withString: "")
                                    let num = newStr.stringByReplacingOccurrencesOfString("/", withString: "")
                                    
                                    self._nextEvolutionID = "\(num)"
                                    self._nextEvolutionTxt = to
                                    
                                    print(self._nextEvolutionID)
                                    print(self._nextEvolutionTxt)
                                    print(self._pokedexId)
                                }
                            }
                        }
                    }
                }
                
                
            case .Failure(let error):
                print("BOO! Request failed with error: \(error)")
            }
            
        }
        
        
    }

    
}