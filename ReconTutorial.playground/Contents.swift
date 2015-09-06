import Recon

// Parse RECON strings using the `Value.parseRecon` factory method.
let event = Value.parseRecon("@event(onClick),@command")!

// Serialize RECON values using the `recon` method.
event.recon

// Use the `reconBlock` method to flatten any top-level records.
event.reconBlock

// Subscripts get indexed and keyed values.
let msg = Value.parseRecon("{from: me, to: you}")!
msg[0]
msg["to"]

// Values are implicitly convertible from array, string, numeric, and boolean literals.
Value(Attr("img", [Slot("src", "...")]), Slot("width", 10), Slot("height", 10), [Attr("caption", [Slot("lang", "en")]), "English Caption"], [Attr("caption", [Slot("lang", "es")]), "Spanish Caption"])
