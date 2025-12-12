import Foundation

/*
 PATTERN VERGLEICH: Kaffeemaschine
 
 Use-Case: Kaffee zubereiten
   Bohnen mahlen → Wasser erhitzen → Brühen → Servieren
 
 ...
*/

// =============================================================================
// PATTERN A: PIPES AND FILTERS
// Kaffee "fließt" durch Stationen: [Bohnen] → [Mühle] → [Brüher] → [Tasse]
// =============================================================================

struct Coffee {
    var status: String
    var temperature: Int
}

let grind: (Coffee) -> Coffee = { c in
    print("Bohnen werden gemahlen...")
    return Coffee(status: "gemahlen", temperature: c.temperature)
}

let heat: (Coffee) -> Coffee = { c in
    print("Wasser wird erhitzt...")
    return Coffee(status: c.status + " + heißes Wasser", temperature: 95)
}

let brew: (Coffee) -> Coffee = { c in
    print("Kaffee wird gebrüht...")
    return Coffee(status: "fertiger Kaffee", temperature: c.temperature)
}

func makeCoffee(_ coffee: Coffee, steps: [(Coffee) -> Coffee]) -> Coffee {
    steps.reduce(coffee) { result, step in step(result) }
}

// =============================================================================
// PATTERN B: OBSERVER / EVENT-DRIVEN
// Stationen "lauschen" auf Events und reagieren
// =============================================================================

class CoffeeMachine {
    var observers: [String: [(String) -> Void]] = [:]
    
    func on(_ event: String, _ action: @escaping (String) -> Void) {
        observers[event, default: []].append(action)
    }
    
    func emit(_ event: String, _ data: String = "") {
        observers[event]?.forEach { $0(data) }
    }
}

// =============================================================================
// DEMO
// =============================================================================

@MainActor
func runDemo() {
    let separator = String(repeating: "=", count: 50)
    
    print(separator)
    print("PIPES & FILTERS:")
    print(separator)
    
    let coffee = Coffee(status: "Bohnen", temperature: 20)
    let result = makeCoffee(coffee, steps: [grind, heat, brew])
    print("\(result.status) (\(result.temperature)°C)")
    
    print("\n" + separator)
    print("EVENT-DRIVEN:")
    print(separator)
    
    let machine = CoffeeMachine()
    
    // Stationen registrieren sich für Events
    machine.on("start") { _ in
        print("Bohnen werden gemahlen...")
        machine.emit("ground")
    }
    machine.on("ground") { _ in
        print("Wasser wird erhitzt...")
        machine.emit("heated")
    }
    machine.on("heated") { _ in
        print("Kaffee wird gebrüht...")
        machine.emit("done")
    }
    machine.on("done") { _ in
        print("fertiger Kaffee (95°C)")
    }
    
    // Bestellung auslösen
    machine.emit("start")
}

// Ausführen
runDemo()
