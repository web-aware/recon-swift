import Recon

// Parse a RECON-encoded string by invoking the `recon` function.
let event = recon("@event(onClick),@command")!

// Serialize a RECON value using its `recon` method.
event.recon

// The `reconBlock` method behaves like the `recon` method, but flattens top-level records.
event.reconBlock

// Subscripts get a record's children by index, or by key.
let msg = recon("{from: me, to: you}")!
msg[0]
msg["to"]

// Subscripting a non-existent key returns `Value.Absent`.
msg["cc"]
msg[2]
recon("2.0")!["number"]

// Because `Value.Absent` is a value, subscripting is a "closed" operation.
recon("{foo: {bar: {baz: win}}}")!["foo"]["bar"]["baz"]

// Implicit conversion from Swift literals to RECON values makes record construction easy.
Value(Attr("img", [Slot("src", "...")]), Slot("width", 10), Slot("height", 10), [Attr("caption", [Slot("lang", "en")]), "English Caption"], [Attr("caption", [Slot("lang", "es")]), "Spanish Caption"])
