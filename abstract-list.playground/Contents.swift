// (abstract list)
//  The playground called to present standard everyday list operations under a different point of view

// - What is List?

// -------------------------------------------------- s_list start
indirect enum List<E> {
    case empty
    // E -> List<E>, i.e. Linked List
    case list(E, List<E>)
}
// -------------------------------------------------- s_list end

// - API for List

// -------------------------------------------------- s_listapi start
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
// -------------------------------------------------- s_listapi end

// - List construction

// -------------------------------------------------- s_cons start
func cons<E>(_ element: E, _ list: List<E>) -> List<E> {
    return .list(element, list)
}

let listOfInts = cons(1, cons(2, cons(3, .empty)))
// -------------------------------------------------- s_cons end

// - List debug description

// -------------------------------------------------- s_describe start
func describe<E>(_ list: List<E>) -> String { // Will back to this later
    return isEmpty(list) ?
        ".empty" :
    "cons(\(first(list)), \(describe(rest(list))))"
}

extension List: CustomDebugStringConvertible {
    var debugDescription: String { return describe(self) }
}
// -------------------------------------------------- s_describe end

// - List Equatable

// -------------------------------------------------- s_eq start
extension List: Equatable where E: Equatable {
    static func == (lhs: List<E>, rhs: List<E>) -> Bool {
        return isEmpty(lhs) && isEmpty(rhs) ?
            true :
            first(lhs) == first(rhs) && rest(lhs) == rest(rhs)
    }
}
// -------------------------------------------------- s_eq end

// - Better construct

// -------------------------------------------------- s_cons_better start
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
// -------------------------------------------------- s_cons_better end

// - Player

// -------------------------------------------------- s_player end
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

// NOTE: Try to play with cons before
let players: List<Player> = [Player(name: "Andrew", score: 22),
                             Player(name: "Petro", score: 10),
                             Player(name: "James", score: 35)]
// -------------------------------------------------- s_player end

// - Add1

// -------------------------------------------------- s_add1 start
func add1(_ n: Int) -> Int {
    return n + 1
}
// -------------------------------------------------- s_add1 end

// Traversing the list by using so-called `natural` (or structural) recursion

// -------------------------------------------------- s_add1toeach_head start
func add1ToEach(_ list: List<Int>) -> List<Int> {
    // -------------------------------------------------- s_add1toeach_body start
    return isEmpty(list) ?
        .empty :
        cons(add1(first(list)),
             add1ToEach(rest(list)))
    // -------------------------------------------------- s_add1toeach_body end
}
// -------------------------------------------------- s_add1toeach_head end

add1ToEach(listOfInts)

// -------------------------------------------------- s_add1score start
func add1ScoreToPlayer(player: Player) -> Player {
    return Player(name: player.name,
                  score: add1(player.score))
}
// -------------------------------------------------- s_add1score end

// -------------------------------------------------- s_add1scoretoeach start
func add1ScoreToEachPlayer(players: List<Player>) -> List<Player> {
    return isEmpty(players) ?
        .empty :
        cons(add1ScoreToPlayer(player: first(players)),
             add1ScoreToEachPlayer(players: rest(players)))
}
// -------------------------------------------------- s_add1scoretoeach end

// - Similarities??
// - Map

// -------------------------------------------------- s_map start
func map<E, R>(_ list: List<E>, transform: (E) -> R) -> List<R> {
    return isEmpty(list) ?
        .empty :
        cons(transform(first(list)),
             map(rest(list), transform: transform))
}
// -------------------------------------------------- s_map end

// -------------------------------------------------- s_map_add1 start
func add1ToEach_v1(_ list: List<Int>) -> List<Int> {
    return map(list, transform: add1)
}

add1ToEach(listOfInts) == add1ToEach_v1(listOfInts)

func add1ScoreToEachPlayer_v1(players: List<Player>) -> List<Player> {
    return map(players, transform: add1ScoreToPlayer)
}

add1ScoreToEachPlayer(players: players) == add1ScoreToEachPlayer_v1(players: players)
// -------------------------------------------------- s_map_add1 end

// - The same abstracting rules but for extract

// -------------------------------------------------- s_extract start
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
// -------------------------------------------------- s_extract end

// - Filter

// -------------------------------------------------- s_filter start
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
// -------------------------------------------------- s_filter end

// - OK, map and filter done. What's left?

// - Product of ints

// -------------------------------------------------- s_product start
func product(_ list: List<Int>) -> Int {
    return isEmpty(list) ?
        1 :
        first(list) * product(rest(list))
}
// -------------------------------------------------- s_product end

product(listOfInts)

// NOTE: Look on describe

// - Similarities??

// - Reduce

// -------------------------------------------------- s_reduce start
func reduce<E, R>(_ list: List<E>, base: R, combine: (E, R) -> R) -> R {
    return isEmpty(list) ?
        base :
        combine(first(list),
                reduce(rest(list), base: base, combine: combine))
}

func product_v1(_ list: List<Int>) -> Int {
    return reduce(list, base: 1, combine: *)
}
// -------------------------------------------------- s_reduce end

product(listOfInts) == product_v1(listOfInts)

// - Better describe

// -------------------------------------------------- s_describe_reduce start
func describe_v1<E>(_ list: List<E>) -> String {
    return reduce(list, base: ".empty") { return "cons(\($0), \($1))" }
}

describe(listOfInts) == describe_v1(listOfInts)
// -------------------------------------------------- s_describe_reduce end

// Additionally map & filter possible to express in rules of reduce

// These functions are abstractions on general recursive list travesing.
// Such different kind of view instead of reducing state variable from `for` loop.

/*:
 ### Links:
 [what?](https://htdp.org/2018-01-06/Book/part_three.html)
 
 [so, what?](https://github.com/pointfreeco/swift-nonempty)
 */
