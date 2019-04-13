// (abstract list)
//  The playground called to present standard everyday list operations under a different point of view

// - What is List?

indirect enum List<E> {
    case empty
    // E -> List<E>, i.e. Linked List
    case list(E, List<E>)
}

// - API for List

func isEmpty<E>(_ list: List<E>) -> Bool {
    switch list {
    case .empty: return true
    default: return false
    }
}

func first<E>(_ list: List<E>) -> E {
    switch list {
    case .empty: fatalError("first on empty list")
    case .list(let first, _): return first
    }
}

func rest<E>(_ list: List<E>) -> List<E> {
    switch list {
    case .empty: fatalError("last on empty list")
    case .list(_, let rest): return rest
    }
}

// - List construction

func cons<E>(_ element: E, _ list: List<E>) -> List<E> {
    return .list(element, list)
}

let listOfInts = cons(1, cons(2, cons(3, .empty)))

// - List debug description

func describe<E>(_ list: List<E>) -> String { // Will back to this later
    return isEmpty(list) ?
        ".empty" :
        "cons(\(first(list)), \(describe(rest(list))))"
}

extension List: CustomDebugStringConvertible {
    var debugDescription: String { return describe(self) }
}

// - List Equatable

extension List: Equatable where E: Equatable {
    static func == (lhs: List<E>, rhs: List<E>) -> Bool {
        return isEmpty(lhs) && isEmpty(rhs) ?
            true :
            first(lhs) == first(rhs) && rest(lhs) == rest(rhs)
    }
}

// - Better construct

extension List: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = E
    init(arrayLiteral elements: E...) {
        // recude with base `.empty` and flipped cons
        self = elements.reduce(.empty, flippedCons)
    }
}

// NOTE: Better to use generalized flip application on cons instead
func flippedCons<E>(_ list: List<E>, _ element: E) -> List<E> {
    return cons(element, list)
}

// - Player

struct Player {
    let name: String
    let score: Int
}

extension Player: Equatable {}

extension Player: CustomStringConvertible {
    var description: String {
        return "Player(name: \(name), score: \(score))"
    }
}

let players: List<Player> = [Player(name: "Andrew", score: 22),
                             Player(name: "Petro", score: 10),
                             Player(name: "James", score: 35)]

// - Add1

func add1(_ n: Int) -> Int {
    return n + 1
}

func add1ToEach(_ list: List<Int>) -> List<Int> {
    return isEmpty(list) ?
        .empty :
        cons(add1(first(list)),
             add1ToEach(rest(list)))
}

add1ToEach(listOfInts)

func add1ScoreToPlayer(player: Player) -> Player {
    return Player(name: player.name,
                  score: add1(player.score))
}

func add1ScoreToEachPlayer(players: List<Player>) -> List<Player> {
    return isEmpty(players) ?
        .empty :
        cons(add1ScoreToPlayer(player: first(players)),
             add1ScoreToEachPlayer(players: rest(players)))
}

add1ScoreToEachPlayer(players: players)

// - Map

func map<E, R>(_ list: List<E>, transform: (E) -> R) -> List<R> {
    return isEmpty(list) ?
        .empty :
        cons(transform(first(list)),
             map(rest(list), transform: transform))
}

func add1ToEach_v1(_ list: List<Int>) -> List<Int> {
    return map(list, transform: add1)
}

add1ToEach(listOfInts) == add1ToEach_v1(listOfInts)

func add1ScoreToEachPlayer_v1(players: List<Player>) -> List<Player> {
    return map(players, transform: add1ScoreToPlayer)
}

add1ScoreToEachPlayer(players: players) == add1ScoreToEachPlayer_v1(players: players)

// - The same abstracting rules but for extract

func extract(players: List<Player>, withGreaterThan score: Int) -> List<Player> {
    if isEmpty(players) {
        return .empty
    } else {
        return first(players).score > score ?
            cons(first(players),
                 extract(players: rest(players), withGreaterThan: score)) :
            extract(players: rest(players), withGreaterThan: score)
    }
}

extract(players: players, withGreaterThan: 0)
extract(players: players, withGreaterThan: 20)
extract(players: players, withGreaterThan: 50)

// - Filter

func filter<E>(_ list: List<E>, predicate: (E) -> Bool) -> List<E> {
    if isEmpty(list) {
        return .empty
    } else {
        return predicate(first(list)) ?
            cons(first(list),
                 filter(rest(list), predicate: predicate)) :
            filter(rest(list),
                   predicate: predicate)
    }
}

func extract_v1(players: List<Player>, withGreaterThan score: Int) -> List<Player> {
    return filter(players) { $0.score > score }
}

extract(players: players, withGreaterThan: 0) == extract_v1(players: players, withGreaterThan: 0)
extract(players: players, withGreaterThan: 20) == extract_v1(players: players, withGreaterThan: 20)
extract(players: players, withGreaterThan: 50) == extract_v1(players: players, withGreaterThan: 50)

// - OK, map and filter done. What's left?

// - Product of Ints

func product(_ list: List<Int>) -> Int {
    return isEmpty(list) ?
        1 :
        first(list) * product(rest(list))
}

product(listOfInts)

// NOTE: Look on describe
// - Similarities??

// - Reduce

func reduce<E, R>(_ list: List<E>, base: R, combine: (E, R) -> R) -> R {
    return isEmpty(list) ?
        base :
        combine(first(list),
                reduce(rest(list), base: base, combine: combine))
}

func product_v1(_ list: List<Int>) -> Int {
    return reduce(list, base: 1, combine: *)
}

product(listOfInts) == product_v1(listOfInts)

// - Better describe

func describe_v1<E>(_ list: List<E>) -> String {
    return reduce(list, base: ".empty") { return "cons(\($0), \($1))" }
}

describe(listOfInts) == describe_v1(listOfInts)

// Additionally map & filter possible to express in rules of reduce

// These functions are abstractions on general recursive list travesing.

/*:
 ### Links:
 [what?](https://htdp.org/2018-01-06/Book/part_three.html)
 [so, what?](http://learnyouahaskell.com/higher-order-functions)
 */
