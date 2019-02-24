//: Playground - noun: a place where people can play

// Called to present standard every day things ander different point of view

indirect enum List<T> {
    case empty
    case list(T, List<T>)
}

// MARK: - API

func isEmpty<T>(_ list: List<T>) -> Bool {
    switch list {
    case .empty: return true
    default: return false
    }
}

func first<T>(_ list: List<T>) -> T {
    switch list {
    case .empty: fatalError("first on empty list")
    case .list(let first, _): return first
    }
}

func rest<T>(_ list: List<T>) -> List<T> {
    switch list {
    case .empty: fatalError("last on empty list")
    case .list(_, let last): return last
    }
}

// MARK: - Construction

func construct<T>(_ value: T, _ list: List<T>) -> List<T> {
    return .list(value, list)
}

// Name `construct` as `cons` for short
func cons<T>(_ value: T, _ list: List<T>) -> List<T> {
    return construct(value, list)
}

// MARK: - Examples of what list could contains and what operations we can do

let listOfInts = cons(1, cons(2, cons(3, .empty)))

// MARK: - Add1

func add1(_ n: Int) -> Int {
    return n + 1
}

// Traversing the list by using so-called natural (or structural) recursion
func add1ToEach(_ list: List<Int>) -> List<Int> {
    return isEmpty(list) ?
        .empty :
        cons(add1(first(list)),
             add1ToEach(rest(list)))
}

add1ToEach(listOfInts)

// MARK: - Extract players

struct Player {
    let name: String
    let score: Int
}

// MARK: - Better construct

extension List: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = T
    init(arrayLiteral elements: T...) {
        // recude with base `.empty` and flipped cons
        self = elements.reduce(.empty, flippedCons)
    }
}

// Better to use generalized flip application on cons instead
func flippedCons<T>(_ list: List<T>, _ value: T) -> List<T> {
    return cons(value, list)
}

// MARK: - Return to extract players

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

// MARK: - Map

func add1ScoreToPlayer(player: Player) -> Player {
    return Player(name: player.name, score: add1(player.score))
}

func add1ScoreToEachPlayer(players: List<Player>) -> List<Player> {
    return isEmpty(players) ?
        .empty :
        cons(add1ScoreToPlayer(player: first(players)),
             add1ScoreToEachPlayer(players: rest(players)))
}

// MARK: - Similarities??

//func add1ToEach(_ list: List<Int>) -> List<Int> {
//    return isEmpty(list) ?
//        .empty :
//        cons(add1(first(list)),
//             add1ToEach(rest(list)))
//}

func map<T, U>(_ list: List<T>, transform: (T) -> U) -> List<U> {
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

add1ToEach_v1(listOfInts)


// MARK: - The same abstracting rules applies to extract(players:withGreaterThan:)

// MARK: - Filter

func filter<T>(_ list: List<T>, predicate: (T) -> Bool) -> List<T> {
    if isEmpty(list) {
        return .empty
    } else {
        return predicate(first(list)) ?
            cons(first(list), filter(rest(list), predicate: predicate)) :
            filter(rest(list), predicate: predicate)
    }
}

func extract_v1(players: List<Player>, withGreaterThan score: Int) -> List<Player> {
    return filter(players) { $0.score > score }
}

extract_v1(players: players, withGreaterThan: 0)
extract_v1(players: players, withGreaterThan: 20)
extract_v1(players: players, withGreaterThan: 50)

// MARK: - Sum of ints

func sum(_ list: List<Int>) -> Int {
    return isEmpty(list) ?
        0 :
        first(list) + sum(rest(list))
}

sum(listOfInts)

// MARK: - Reduce

// What simmilar between Ex. 1 and Ex. 4?
// Another examples are product, strings concat.

func reduce<T, R>(_ list: List<T>, base: R, combine: (T, R) -> R) -> R {
    return isEmpty(list) ?
        base :
        combine(first(list),
                reduce(rest(list), base: base, combine: combine))
}

func sum_v1(_ list: List<Int>) -> Int {
    return reduce(list, base: 0, combine: +)
}

sum(listOfInts) == sum_v1(listOfInts)

// Additionally map & filter possible to express in rules of reduce

// First class functions are abstractions on general resurcive list travesing.
// Such different kind of view instead of reducing state from `for` loop.
