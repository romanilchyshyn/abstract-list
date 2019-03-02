// (abstract list)
//  The playground called to present standard everyday list operations under a different point of view

// - What is List?

indirect enum List<E> {
    case empty
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
    case .list(_, let last): return last
    }
}

// - List construction

func construct<E>(_ element: E, _ list: List<E>) -> List<E> {
    return .list(element, list)
}

// Name `construct` as `cons` for short
func cons<E>(_ element: E, _ list: List<E>) -> List<E> {
    return construct(element, list)
}

// - Examples of what list could contains and what operations we can do

let listOfInts = cons(1, cons(2, cons(3, .empty)))

// - Add1

func add1(_ n: Int) -> Int {
    return n + 1
}

// Traversing the list by using so-called `natural` (or structural) recursion
func add1ToEach(_ list: List<Int>) -> List<Int> {
    return isEmpty(list) ?
        .empty :
        cons(add1(first(list)),
             add1ToEach(rest(list)))
}

add1ToEach(listOfInts)

// - Extract players

struct Player {
    let name: String
    let score: Int
}

// - Better construct (try to play with cons before)

extension List: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = E
    init(arrayLiteral elements: E...) {
        // recude with base `.empty` and flipped cons
        self = elements.reduce(.empty, flippedCons)
    }
}

// Better to use generalized flip application on cons instead
func flippedCons<E>(_ list: List<E>, _ element: E) -> List<E> {
    return cons(element, list)
}

// - Return to extract players

let players: List<Player> = [Player(name: "Andrew", score: 22),
                             Player(name: "Petro", score: 10),
                             Player(name: "James", score: 35)]

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

// - Map

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

// - Similarities??

//func add1ToEach(_ list: List<Int>) -> List<Int> {
//    return isEmpty(list) ?
//        .empty :
//        cons(add1(first(list)),
//             add1ToEach(rest(list)))
//}

func map<E, R>(_ list: List<E>, transform: (E) -> R) -> List<R> {
    return isEmpty(list) ?
        .empty :
        cons(transform(first(list)),
             map(rest(list), transform: transform))
}

func add1ScoreToEachPlayer_v1(players: List<Player>) -> List<Player> {
    return map(players, transform: add1ScoreToPlayer)
}

func add1ToEach_v1(_ list: List<Int>) -> List<Int> {
    return map(list, transform: add1)
}

// - List Equtable

extension List: Equatable where E: Equatable {
    static func == (lhs: List<E>, rhs: List<E>) -> Bool {
        return isEmpty(lhs) && isEmpty(rhs) ?
            true :
            first(lhs) == first(rhs) && rest(lhs) == rest(rhs)
    }
}

add1ToEach(listOfInts) == add1ToEach_v1(listOfInts)

extension Player: Equatable {}
add1ScoreToEachPlayer(players: players) == add1ScoreToEachPlayer_v1(players: players)

// - The same abstracting rules applies to extract(players:withGreaterThan:)

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

// - Sum of ints

func sum(_ list: List<Int>) -> Int {
    return isEmpty(list) ?
        0 :
        first(list) + sum(rest(list))
}

sum(listOfInts)

// - Product of ints

func product(_ list: List<Int>) -> Int {
    return isEmpty(list) ?
        1 :
        first(list) * product(rest(list))
}

product(listOfInts)

// - Similarities??

// - Reduce

func reduce<E, R>(_ list: List<E>, base: R, combine: (E, R) -> R) -> R {
    return isEmpty(list) ?
        base :
        combine(first(list),
                reduce(rest(list), base: base, combine: combine))
}

func sum_v1(_ list: List<Int>) -> Int {
    return reduce(list, base: 0, combine: +)
}

sum(listOfInts) == sum_v1(listOfInts)

func product_v1(_ list: List<Int>) -> Int {
    return reduce(list, base: 1, combine: *)
}

product(listOfInts) == product_v1(listOfInts)

// Additionally map & filter possible to express in rules of reduce

// These functions are abstractions on general recursive list travesing.
// Such different kind of view instead of reducing state from `for` loop.

/*:
 ### Links:
 [what?](https://htdp.org/)
 
 [so, what?](https://github.com/pointfreeco/swift-nonempty)
 */
