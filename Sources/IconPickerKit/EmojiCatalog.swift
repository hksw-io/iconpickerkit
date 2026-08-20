import Foundation

/// A searchable emoji with a display name and keywords.
public nonisolated struct EmojiItem: Identifiable, Sendable {
    public let id: String
    public let emoji: String
    public let name: String
    public let keywords: [String]

    public init(emoji: String, name: String, keywords: [String] = []) {
        self.id = emoji
        self.emoji = emoji
        self.name = name
        self.keywords = keywords
    }
}

/// Curated emoji catalog used by ``IconPickerView``.
public enum EmojiCatalog {
    /// Items whose name or keywords contain `query`. An empty query returns the full catalog.
    public static func search(_ query: String) -> [EmojiItem] {
        guard !query.isEmpty else { return self.all }
        let lowercased = query.lowercased()
        return self.all.filter { item in
            item.name.lowercased().contains(lowercased) ||
                item.keywords.contains { $0.lowercased().contains(lowercased) }
        }
    }

    public static let all: [EmojiItem] = smileys + gestures + animals + food + activities + objects + symbols

    public static let smileys: [EmojiItem] = [
        EmojiItem(emoji: "😀", name: "Grinning Face", keywords: ["smile", "happy"]),
        EmojiItem(emoji: "😃", name: "Grinning Face with Big Eyes", keywords: ["smile", "happy"]),
        EmojiItem(emoji: "😄", name: "Grinning Face with Smiling Eyes", keywords: ["smile", "happy"]),
        EmojiItem(emoji: "😁", name: "Beaming Face", keywords: ["smile", "grin"]),
        EmojiItem(emoji: "😆", name: "Grinning Squinting Face", keywords: ["laugh"]),
        EmojiItem(emoji: "😅", name: "Grinning Face with Sweat", keywords: ["nervous", "laugh"]),
        EmojiItem(emoji: "🤣", name: "Rolling on the Floor Laughing", keywords: ["lol", "laugh"]),
        EmojiItem(emoji: "😂", name: "Face with Tears of Joy", keywords: ["laugh", "cry"]),
        EmojiItem(emoji: "🙂", name: "Slightly Smiling Face", keywords: ["smile"]),
        EmojiItem(emoji: "😊", name: "Smiling Face with Smiling Eyes", keywords: ["blush", "happy"]),
        EmojiItem(emoji: "😇", name: "Smiling Face with Halo", keywords: ["angel", "innocent"]),
        EmojiItem(emoji: "🥰", name: "Smiling Face with Hearts", keywords: ["love", "adore"]),
        EmojiItem(emoji: "😍", name: "Heart Eyes", keywords: ["love", "crush"]),
        EmojiItem(emoji: "🤩", name: "Star-Struck", keywords: ["excited", "star"]),
        EmojiItem(emoji: "😘", name: "Face Blowing a Kiss", keywords: ["kiss", "love"]),
        EmojiItem(emoji: "😋", name: "Face Savoring Food", keywords: ["yum", "delicious"]),
        EmojiItem(emoji: "😎", name: "Smiling Face with Sunglasses", keywords: ["cool", "sunglasses"]),
        EmojiItem(emoji: "🤓", name: "Nerd Face", keywords: ["geek", "glasses"]),
        EmojiItem(emoji: "🧐", name: "Face with Monocle", keywords: ["thinking", "curious"]),
        EmojiItem(emoji: "🤔", name: "Thinking Face", keywords: ["think", "hmm"]),
        EmojiItem(emoji: "🤨", name: "Face with Raised Eyebrow", keywords: ["skeptical"]),
        EmojiItem(emoji: "😐", name: "Neutral Face", keywords: ["meh", "indifferent"]),
        EmojiItem(emoji: "😑", name: "Expressionless Face", keywords: ["blank"]),
        EmojiItem(emoji: "😶", name: "Face Without Mouth", keywords: ["silent", "speechless"]),
        EmojiItem(emoji: "🙄", name: "Face with Rolling Eyes", keywords: ["eyeroll"]),
        EmojiItem(emoji: "😏", name: "Smirking Face", keywords: ["smirk", "suggestive"]),
        EmojiItem(emoji: "😴", name: "Sleeping Face", keywords: ["sleep", "zzz"]),
        EmojiItem(emoji: "🤤", name: "Drooling Face", keywords: ["drool", "hungry"]),
        EmojiItem(emoji: "😷", name: "Face with Medical Mask", keywords: ["sick", "mask"]),
        EmojiItem(emoji: "🤒", name: "Face with Thermometer", keywords: ["sick", "fever"]),
        EmojiItem(emoji: "🤕", name: "Face with Head-Bandage", keywords: ["hurt", "injured"]),
        EmojiItem(emoji: "🤢", name: "Nauseated Face", keywords: ["sick", "green"]),
        EmojiItem(emoji: "🤮", name: "Face Vomiting", keywords: ["sick", "vomit"]),
        EmojiItem(emoji: "🥵", name: "Hot Face", keywords: ["hot", "sweating"]),
        EmojiItem(emoji: "🥶", name: "Cold Face", keywords: ["cold", "freezing"]),
        EmojiItem(emoji: "😵", name: "Face with Crossed-Out Eyes", keywords: ["dizzy", "dead"]),
        EmojiItem(emoji: "🤯", name: "Exploding Head", keywords: ["mind blown", "shocked"]),
        EmojiItem(emoji: "🥳", name: "Partying Face", keywords: ["party", "celebrate"]),
        EmojiItem(emoji: "😈", name: "Smiling Face with Horns", keywords: ["devil", "evil"]),
        EmojiItem(emoji: "👿", name: "Angry Face with Horns", keywords: ["devil", "angry"]),
        EmojiItem(emoji: "👻", name: "Ghost", keywords: ["halloween", "boo"]),
        EmojiItem(emoji: "💀", name: "Skull", keywords: ["death", "dead"]),
        EmojiItem(emoji: "👽", name: "Alien", keywords: ["ufo", "space"]),
        EmojiItem(emoji: "🤖", name: "Robot", keywords: ["bot", "machine"]),
        EmojiItem(emoji: "🎃", name: "Jack-O-Lantern", keywords: ["halloween", "pumpkin"]),
    ]

    public static let gestures: [EmojiItem] = [
        EmojiItem(emoji: "👍", name: "Thumbs Up", keywords: ["like", "good", "ok"]),
        EmojiItem(emoji: "👎", name: "Thumbs Down", keywords: ["dislike", "bad"]),
        EmojiItem(emoji: "👊", name: "Oncoming Fist", keywords: ["punch", "fist bump"]),
        EmojiItem(emoji: "✊", name: "Raised Fist", keywords: ["fist", "power"]),
        EmojiItem(emoji: "🤛", name: "Left-Facing Fist", keywords: ["fist bump"]),
        EmojiItem(emoji: "🤜", name: "Right-Facing Fist", keywords: ["fist bump"]),
        EmojiItem(emoji: "👏", name: "Clapping Hands", keywords: ["applause", "clap"]),
        EmojiItem(emoji: "🙌", name: "Raising Hands", keywords: ["celebration", "hooray"]),
        EmojiItem(emoji: "👐", name: "Open Hands", keywords: ["hug"]),
        EmojiItem(emoji: "🤲", name: "Palms Up Together", keywords: ["prayer"]),
        EmojiItem(emoji: "🤝", name: "Handshake", keywords: ["deal", "agreement"]),
        EmojiItem(emoji: "🙏", name: "Folded Hands", keywords: ["pray", "please", "thanks"]),
        EmojiItem(emoji: "✌️", name: "Victory Hand", keywords: ["peace", "v"]),
        EmojiItem(emoji: "🤞", name: "Crossed Fingers", keywords: ["luck", "hope"]),
        EmojiItem(emoji: "🤟", name: "Love-You Gesture", keywords: ["love", "rock"]),
        EmojiItem(emoji: "🤘", name: "Sign of the Horns", keywords: ["rock", "metal"]),
        EmojiItem(emoji: "👌", name: "OK Hand", keywords: ["perfect", "okay"]),
        EmojiItem(emoji: "🤌", name: "Pinched Fingers", keywords: ["italian", "chef"]),
        EmojiItem(emoji: "👈", name: "Pointing Left", keywords: ["left"]),
        EmojiItem(emoji: "👉", name: "Pointing Right", keywords: ["right"]),
        EmojiItem(emoji: "👆", name: "Pointing Up", keywords: ["up"]),
        EmojiItem(emoji: "👇", name: "Pointing Down", keywords: ["down"]),
        EmojiItem(emoji: "☝️", name: "Index Pointing Up", keywords: ["one", "attention"]),
        EmojiItem(emoji: "✋", name: "Raised Hand", keywords: ["stop", "high five"]),
        EmojiItem(emoji: "🖐️", name: "Hand with Fingers Splayed", keywords: ["five"]),
        EmojiItem(emoji: "🖖", name: "Vulcan Salute", keywords: ["spock", "star trek"]),
        EmojiItem(emoji: "👋", name: "Waving Hand", keywords: ["hello", "bye", "wave"]),
        EmojiItem(emoji: "🤚", name: "Raised Back of Hand", keywords: ["stop"]),
        EmojiItem(emoji: "💪", name: "Flexed Biceps", keywords: ["strong", "muscle", "workout"]),
        EmojiItem(emoji: "🦾", name: "Mechanical Arm", keywords: ["robot", "prosthetic"]),
    ]

    public static let animals: [EmojiItem] = [
        EmojiItem(emoji: "🐶", name: "Dog Face", keywords: ["puppy", "pet"]),
        EmojiItem(emoji: "🐱", name: "Cat Face", keywords: ["kitten", "pet"]),
        EmojiItem(emoji: "🐭", name: "Mouse Face", keywords: ["rat"]),
        EmojiItem(emoji: "🐹", name: "Hamster", keywords: ["pet"]),
        EmojiItem(emoji: "🐰", name: "Rabbit Face", keywords: ["bunny"]),
        EmojiItem(emoji: "🦊", name: "Fox", keywords: ["firefox"]),
        EmojiItem(emoji: "🐻", name: "Bear", keywords: ["teddy"]),
        EmojiItem(emoji: "🐼", name: "Panda", keywords: ["bear"]),
        EmojiItem(emoji: "🐨", name: "Koala", keywords: ["bear"]),
        EmojiItem(emoji: "🐯", name: "Tiger Face", keywords: ["cat"]),
        EmojiItem(emoji: "🦁", name: "Lion", keywords: ["king"]),
        EmojiItem(emoji: "🐮", name: "Cow Face", keywords: ["moo"]),
        EmojiItem(emoji: "🐷", name: "Pig Face", keywords: ["oink"]),
        EmojiItem(emoji: "🐸", name: "Frog", keywords: ["toad"]),
        EmojiItem(emoji: "🐵", name: "Monkey Face", keywords: ["ape"]),
        EmojiItem(emoji: "🙈", name: "See-No-Evil Monkey", keywords: ["hide"]),
        EmojiItem(emoji: "🙉", name: "Hear-No-Evil Monkey", keywords: ["ignore"]),
        EmojiItem(emoji: "🙊", name: "Speak-No-Evil Monkey", keywords: ["secret"]),
        EmojiItem(emoji: "🐔", name: "Chicken", keywords: ["hen"]),
        EmojiItem(emoji: "🐧", name: "Penguin", keywords: ["linux"]),
        EmojiItem(emoji: "🐦", name: "Bird", keywords: ["twitter"]),
        EmojiItem(emoji: "🐤", name: "Baby Chick", keywords: ["chicken"]),
        EmojiItem(emoji: "🦆", name: "Duck", keywords: ["quack"]),
        EmojiItem(emoji: "🦅", name: "Eagle", keywords: ["bird"]),
        EmojiItem(emoji: "🦉", name: "Owl", keywords: ["night", "wise"]),
        EmojiItem(emoji: "🦇", name: "Bat", keywords: ["batman"]),
        EmojiItem(emoji: "🐺", name: "Wolf", keywords: ["howl"]),
        EmojiItem(emoji: "🐗", name: "Boar", keywords: ["pig"]),
        EmojiItem(emoji: "🐴", name: "Horse Face", keywords: ["pony"]),
        EmojiItem(emoji: "🦄", name: "Unicorn", keywords: ["magic", "rainbow"]),
        EmojiItem(emoji: "🐝", name: "Honeybee", keywords: ["bee", "insect"]),
        EmojiItem(emoji: "🐛", name: "Bug", keywords: ["insect", "caterpillar"]),
        EmojiItem(emoji: "🦋", name: "Butterfly", keywords: ["insect", "beautiful"]),
        EmojiItem(emoji: "🐌", name: "Snail", keywords: ["slow"]),
        EmojiItem(emoji: "🐙", name: "Octopus", keywords: ["sea"]),
        EmojiItem(emoji: "🦑", name: "Squid", keywords: ["sea"]),
        EmojiItem(emoji: "🦐", name: "Shrimp", keywords: ["seafood"]),
        EmojiItem(emoji: "🐠", name: "Tropical Fish", keywords: ["sea"]),
        EmojiItem(emoji: "🐟", name: "Fish", keywords: ["sea"]),
        EmojiItem(emoji: "🐬", name: "Dolphin", keywords: ["sea", "flipper"]),
        EmojiItem(emoji: "🐳", name: "Spouting Whale", keywords: ["sea"]),
        EmojiItem(emoji: "🦈", name: "Shark", keywords: ["sea", "jaws"]),
        EmojiItem(emoji: "🐊", name: "Crocodile", keywords: ["alligator"]),
        EmojiItem(emoji: "🐢", name: "Turtle", keywords: ["slow"]),
        EmojiItem(emoji: "🦎", name: "Lizard", keywords: ["gecko"]),
        EmojiItem(emoji: "🐍", name: "Snake", keywords: ["python"]),
        EmojiItem(emoji: "🦖", name: "T-Rex", keywords: ["dinosaur"]),
        EmojiItem(emoji: "🦕", name: "Sauropod", keywords: ["dinosaur"]),
    ]

    public static let food: [EmojiItem] = [
        EmojiItem(emoji: "🍎", name: "Red Apple", keywords: ["fruit", "healthy"]),
        EmojiItem(emoji: "🍐", name: "Pear", keywords: ["fruit"]),
        EmojiItem(emoji: "🍊", name: "Tangerine", keywords: ["orange", "fruit"]),
        EmojiItem(emoji: "🍋", name: "Lemon", keywords: ["fruit", "sour"]),
        EmojiItem(emoji: "🍌", name: "Banana", keywords: ["fruit"]),
        EmojiItem(emoji: "🍉", name: "Watermelon", keywords: ["fruit", "summer"]),
        EmojiItem(emoji: "🍇", name: "Grapes", keywords: ["fruit", "wine"]),
        EmojiItem(emoji: "🍓", name: "Strawberry", keywords: ["fruit", "berry"]),
        EmojiItem(emoji: "🫐", name: "Blueberries", keywords: ["fruit", "berry"]),
        EmojiItem(emoji: "🍒", name: "Cherries", keywords: ["fruit"]),
        EmojiItem(emoji: "🍑", name: "Peach", keywords: ["fruit"]),
        EmojiItem(emoji: "🥭", name: "Mango", keywords: ["fruit", "tropical"]),
        EmojiItem(emoji: "🍍", name: "Pineapple", keywords: ["fruit", "tropical"]),
        EmojiItem(emoji: "🥥", name: "Coconut", keywords: ["fruit", "tropical"]),
        EmojiItem(emoji: "🥑", name: "Avocado", keywords: ["fruit", "guacamole"]),
        EmojiItem(emoji: "🍆", name: "Eggplant", keywords: ["vegetable", "aubergine"]),
        EmojiItem(emoji: "🥕", name: "Carrot", keywords: ["vegetable"]),
        EmojiItem(emoji: "🌽", name: "Corn", keywords: ["vegetable", "maize"]),
        EmojiItem(emoji: "🌶️", name: "Hot Pepper", keywords: ["spicy", "chili"]),
        EmojiItem(emoji: "🥒", name: "Cucumber", keywords: ["vegetable"]),
        EmojiItem(emoji: "🥬", name: "Leafy Green", keywords: ["vegetable", "salad"]),
        EmojiItem(emoji: "🥦", name: "Broccoli", keywords: ["vegetable"]),
        EmojiItem(emoji: "🍄", name: "Mushroom", keywords: ["fungus"]),
        EmojiItem(emoji: "🥜", name: "Peanuts", keywords: ["nut"]),
        EmojiItem(emoji: "🍞", name: "Bread", keywords: ["toast"]),
        EmojiItem(emoji: "🥐", name: "Croissant", keywords: ["bread", "french"]),
        EmojiItem(emoji: "🥖", name: "Baguette", keywords: ["bread", "french"]),
        EmojiItem(emoji: "🧀", name: "Cheese", keywords: ["dairy"]),
        EmojiItem(emoji: "🥚", name: "Egg", keywords: ["breakfast"]),
        EmojiItem(emoji: "🍳", name: "Cooking", keywords: ["egg", "breakfast"]),
        EmojiItem(emoji: "🥓", name: "Bacon", keywords: ["breakfast", "meat"]),
        EmojiItem(emoji: "🍔", name: "Hamburger", keywords: ["burger", "fast food"]),
        EmojiItem(emoji: "🍟", name: "French Fries", keywords: ["fast food", "chips"]),
        EmojiItem(emoji: "🍕", name: "Pizza", keywords: ["italian", "fast food"]),
        EmojiItem(emoji: "🌭", name: "Hot Dog", keywords: ["fast food"]),
        EmojiItem(emoji: "🥪", name: "Sandwich", keywords: ["lunch"]),
        EmojiItem(emoji: "🌮", name: "Taco", keywords: ["mexican"]),
        EmojiItem(emoji: "🌯", name: "Burrito", keywords: ["mexican"]),
        EmojiItem(emoji: "🍜", name: "Steaming Bowl", keywords: ["ramen", "noodles"]),
        EmojiItem(emoji: "🍝", name: "Spaghetti", keywords: ["pasta", "italian"]),
        EmojiItem(emoji: "🍣", name: "Sushi", keywords: ["japanese"]),
        EmojiItem(emoji: "🍱", name: "Bento Box", keywords: ["japanese"]),
        EmojiItem(emoji: "🍩", name: "Doughnut", keywords: ["donut", "dessert"]),
        EmojiItem(emoji: "🍪", name: "Cookie", keywords: ["dessert"]),
        EmojiItem(emoji: "🎂", name: "Birthday Cake", keywords: ["dessert", "party"]),
        EmojiItem(emoji: "🍰", name: "Shortcake", keywords: ["dessert"]),
        EmojiItem(emoji: "🧁", name: "Cupcake", keywords: ["dessert"]),
        EmojiItem(emoji: "🍫", name: "Chocolate Bar", keywords: ["candy", "dessert"]),
        EmojiItem(emoji: "🍬", name: "Candy", keywords: ["sweet"]),
        EmojiItem(emoji: "🍭", name: "Lollipop", keywords: ["candy", "sweet"]),
        EmojiItem(emoji: "🍦", name: "Soft Ice Cream", keywords: ["dessert"]),
        EmojiItem(emoji: "☕", name: "Hot Beverage", keywords: ["coffee", "tea"]),
        EmojiItem(emoji: "🍵", name: "Teacup", keywords: ["tea", "green tea"]),
        EmojiItem(emoji: "🧃", name: "Beverage Box", keywords: ["juice"]),
        EmojiItem(emoji: "🥤", name: "Cup with Straw", keywords: ["soda", "drink"]),
        EmojiItem(emoji: "🍺", name: "Beer Mug", keywords: ["drink", "alcohol"]),
        EmojiItem(emoji: "🍻", name: "Clinking Beer Mugs", keywords: ["cheers", "drink"]),
        EmojiItem(emoji: "🥂", name: "Clinking Glasses", keywords: ["champagne", "toast"]),
        EmojiItem(emoji: "🍷", name: "Wine Glass", keywords: ["drink", "alcohol"]),
    ]

    public static let activities: [EmojiItem] = [
        EmojiItem(emoji: "⚽", name: "Soccer Ball", keywords: ["football", "sport"]),
        EmojiItem(emoji: "🏀", name: "Basketball", keywords: ["sport"]),
        EmojiItem(emoji: "🏈", name: "American Football", keywords: ["sport"]),
        EmojiItem(emoji: "⚾", name: "Baseball", keywords: ["sport"]),
        EmojiItem(emoji: "🥎", name: "Softball", keywords: ["sport"]),
        EmojiItem(emoji: "🎾", name: "Tennis", keywords: ["sport"]),
        EmojiItem(emoji: "🏐", name: "Volleyball", keywords: ["sport"]),
        EmojiItem(emoji: "🏉", name: "Rugby Football", keywords: ["sport"]),
        EmojiItem(emoji: "🥏", name: "Flying Disc", keywords: ["frisbee"]),
        EmojiItem(emoji: "🎱", name: "Pool 8 Ball", keywords: ["billiards"]),
        EmojiItem(emoji: "🏓", name: "Ping Pong", keywords: ["table tennis"]),
        EmojiItem(emoji: "🏸", name: "Badminton", keywords: ["sport"]),
        EmojiItem(emoji: "🏒", name: "Ice Hockey", keywords: ["sport"]),
        EmojiItem(emoji: "🥅", name: "Goal Net", keywords: ["hockey", "soccer"]),
        EmojiItem(emoji: "⛳", name: "Flag in Hole", keywords: ["golf"]),
        EmojiItem(emoji: "🎿", name: "Skis", keywords: ["skiing", "winter"]),
        EmojiItem(emoji: "🛷", name: "Sled", keywords: ["winter"]),
        EmojiItem(emoji: "🥊", name: "Boxing Glove", keywords: ["boxing"]),
        EmojiItem(emoji: "🎮", name: "Video Game", keywords: ["gaming", "controller"]),
        EmojiItem(emoji: "🕹️", name: "Joystick", keywords: ["gaming", "arcade"]),
        EmojiItem(emoji: "🎲", name: "Game Die", keywords: ["dice", "casino"]),
        EmojiItem(emoji: "♟️", name: "Chess Pawn", keywords: ["chess", "game"]),
        EmojiItem(emoji: "🎯", name: "Bullseye", keywords: ["darts", "target"]),
        EmojiItem(emoji: "🎳", name: "Bowling", keywords: ["sport"]),
        EmojiItem(emoji: "🎸", name: "Guitar", keywords: ["music", "rock"]),
        EmojiItem(emoji: "🎹", name: "Musical Keyboard", keywords: ["piano", "music"]),
        EmojiItem(emoji: "🥁", name: "Drum", keywords: ["music"]),
        EmojiItem(emoji: "🎺", name: "Trumpet", keywords: ["music", "brass"]),
        EmojiItem(emoji: "🎷", name: "Saxophone", keywords: ["music", "jazz"]),
        EmojiItem(emoji: "🎻", name: "Violin", keywords: ["music", "classical"]),
        EmojiItem(emoji: "🎨", name: "Artist Palette", keywords: ["art", "painting"]),
        EmojiItem(emoji: "🎭", name: "Performing Arts", keywords: ["theater", "drama"]),
        EmojiItem(emoji: "🎪", name: "Circus Tent", keywords: ["circus"]),
        EmojiItem(emoji: "🎬", name: "Clapper Board", keywords: ["movie", "film"]),
        EmojiItem(emoji: "🎤", name: "Microphone", keywords: ["karaoke", "singing"]),
        EmojiItem(emoji: "🎧", name: "Headphones", keywords: ["music", "audio"]),
    ]

    public static let objects: [EmojiItem] = [
        EmojiItem(emoji: "📱", name: "Mobile Phone", keywords: ["phone", "iphone"]),
        EmojiItem(emoji: "💻", name: "Laptop", keywords: ["computer", "mac"]),
        EmojiItem(emoji: "🖥️", name: "Desktop Computer", keywords: ["pc"]),
        EmojiItem(emoji: "🖨️", name: "Printer", keywords: ["print"]),
        EmojiItem(emoji: "⌨️", name: "Keyboard", keywords: ["type"]),
        EmojiItem(emoji: "🖱️", name: "Computer Mouse", keywords: ["click"]),
        EmojiItem(emoji: "💾", name: "Floppy Disk", keywords: ["save"]),
        EmojiItem(emoji: "💿", name: "Optical Disk", keywords: ["cd", "dvd"]),
        EmojiItem(emoji: "📷", name: "Camera", keywords: ["photo"]),
        EmojiItem(emoji: "📹", name: "Video Camera", keywords: ["film"]),
        EmojiItem(emoji: "🎥", name: "Movie Camera", keywords: ["film", "cinema"]),
        EmojiItem(emoji: "📺", name: "Television", keywords: ["tv"]),
        EmojiItem(emoji: "📻", name: "Radio", keywords: ["music"]),
        EmojiItem(emoji: "📞", name: "Telephone Receiver", keywords: ["phone", "call"]),
        EmojiItem(emoji: "☎️", name: "Telephone", keywords: ["phone", "call"]),
        EmojiItem(emoji: "🔋", name: "Battery", keywords: ["power"]),
        EmojiItem(emoji: "🔌", name: "Electric Plug", keywords: ["power"]),
        EmojiItem(emoji: "💡", name: "Light Bulb", keywords: ["idea", "lamp"]),
        EmojiItem(emoji: "🔦", name: "Flashlight", keywords: ["light", "torch"]),
        EmojiItem(emoji: "🕯️", name: "Candle", keywords: ["light"]),
        EmojiItem(emoji: "📚", name: "Books", keywords: ["read", "library"]),
        EmojiItem(emoji: "📖", name: "Open Book", keywords: ["read"]),
        EmojiItem(emoji: "📝", name: "Memo", keywords: ["note", "write"]),
        EmojiItem(emoji: "✏️", name: "Pencil", keywords: ["write", "draw"]),
        EmojiItem(emoji: "🖊️", name: "Pen", keywords: ["write"]),
        EmojiItem(emoji: "📌", name: "Pushpin", keywords: ["pin"]),
        EmojiItem(emoji: "📎", name: "Paperclip", keywords: ["attach"]),
        EmojiItem(emoji: "✂️", name: "Scissors", keywords: ["cut"]),
        EmojiItem(emoji: "📁", name: "File Folder", keywords: ["directory"]),
        EmojiItem(emoji: "🗂️", name: "Card Index Dividers", keywords: ["files"]),
        EmojiItem(emoji: "📅", name: "Calendar", keywords: ["date", "schedule"]),
        EmojiItem(emoji: "📆", name: "Tear-Off Calendar", keywords: ["date"]),
        EmojiItem(emoji: "🔑", name: "Key", keywords: ["lock", "password"]),
        EmojiItem(emoji: "🔒", name: "Locked", keywords: ["security", "private"]),
        EmojiItem(emoji: "🔓", name: "Unlocked", keywords: ["security"]),
        EmojiItem(emoji: "🔐", name: "Locked with Key", keywords: ["security"]),
        EmojiItem(emoji: "🔨", name: "Hammer", keywords: ["tool"]),
        EmojiItem(emoji: "🔧", name: "Wrench", keywords: ["tool", "settings"]),
        EmojiItem(emoji: "🔩", name: "Nut and Bolt", keywords: ["tool"]),
        EmojiItem(emoji: "⚙️", name: "Gear", keywords: ["settings", "cog"]),
        EmojiItem(emoji: "🧲", name: "Magnet", keywords: ["attract"]),
        EmojiItem(emoji: "💎", name: "Gem Stone", keywords: ["diamond", "jewel"]),
        EmojiItem(emoji: "💰", name: "Money Bag", keywords: ["cash", "dollar"]),
        EmojiItem(emoji: "💵", name: "Dollar Banknote", keywords: ["money", "cash"]),
        EmojiItem(emoji: "💳", name: "Credit Card", keywords: ["payment"]),
        EmojiItem(emoji: "🎁", name: "Wrapped Gift", keywords: ["present"]),
        EmojiItem(emoji: "🎈", name: "Balloon", keywords: ["party"]),
        EmojiItem(emoji: "🎉", name: "Party Popper", keywords: ["celebration"]),
        EmojiItem(emoji: "🎊", name: "Confetti Ball", keywords: ["party"]),
        EmojiItem(emoji: "🏆", name: "Trophy", keywords: ["winner", "award"]),
        EmojiItem(emoji: "🥇", name: "1st Place Medal", keywords: ["gold", "winner"]),
        EmojiItem(emoji: "🥈", name: "2nd Place Medal", keywords: ["silver"]),
        EmojiItem(emoji: "🥉", name: "3rd Place Medal", keywords: ["bronze"]),
        EmojiItem(emoji: "🎖️", name: "Military Medal", keywords: ["award"]),
        EmojiItem(emoji: "🧹", name: "Broom", keywords: ["clean", "sweep"]),
    ]

    public static let symbols: [EmojiItem] = [
        EmojiItem(emoji: "❤️", name: "Red Heart", keywords: ["love"]),
        EmojiItem(emoji: "🧡", name: "Orange Heart", keywords: ["love"]),
        EmojiItem(emoji: "💛", name: "Yellow Heart", keywords: ["love"]),
        EmojiItem(emoji: "💚", name: "Green Heart", keywords: ["love"]),
        EmojiItem(emoji: "💙", name: "Blue Heart", keywords: ["love"]),
        EmojiItem(emoji: "💜", name: "Purple Heart", keywords: ["love"]),
        EmojiItem(emoji: "🖤", name: "Black Heart", keywords: ["love"]),
        EmojiItem(emoji: "🤍", name: "White Heart", keywords: ["love"]),
        EmojiItem(emoji: "🤎", name: "Brown Heart", keywords: ["love"]),
        EmojiItem(emoji: "💔", name: "Broken Heart", keywords: ["heartbreak"]),
        EmojiItem(emoji: "💕", name: "Two Hearts", keywords: ["love"]),
        EmojiItem(emoji: "💖", name: "Sparkling Heart", keywords: ["love"]),
        EmojiItem(emoji: "💗", name: "Growing Heart", keywords: ["love"]),
        EmojiItem(emoji: "💘", name: "Heart with Arrow", keywords: ["love", "cupid"]),
        EmojiItem(emoji: "💝", name: "Heart with Ribbon", keywords: ["love", "gift"]),
        EmojiItem(emoji: "⭐", name: "Star", keywords: ["favorite"]),
        EmojiItem(emoji: "🌟", name: "Glowing Star", keywords: ["sparkle"]),
        EmojiItem(emoji: "✨", name: "Sparkles", keywords: ["magic"]),
        EmojiItem(emoji: "⚡", name: "High Voltage", keywords: ["lightning", "electric"]),
        EmojiItem(emoji: "🔥", name: "Fire", keywords: ["hot", "flame"]),
        EmojiItem(emoji: "💧", name: "Droplet", keywords: ["water"]),
        EmojiItem(emoji: "🌈", name: "Rainbow", keywords: ["pride"]),
        EmojiItem(emoji: "☀️", name: "Sun", keywords: ["sunny", "weather"]),
        EmojiItem(emoji: "🌙", name: "Crescent Moon", keywords: ["night"]),
        EmojiItem(emoji: "⛅", name: "Sun Behind Cloud", keywords: ["weather"]),
        EmojiItem(emoji: "☁️", name: "Cloud", keywords: ["weather"]),
        EmojiItem(emoji: "🌧️", name: "Cloud with Rain", keywords: ["rainy", "weather"]),
        EmojiItem(emoji: "❄️", name: "Snowflake", keywords: ["winter", "cold"]),
        EmojiItem(emoji: "☃️", name: "Snowman", keywords: ["winter"]),
        EmojiItem(emoji: "🌊", name: "Water Wave", keywords: ["ocean", "sea"]),
        EmojiItem(emoji: "✅", name: "Check Mark Button", keywords: ["done", "yes"]),
        EmojiItem(emoji: "❌", name: "Cross Mark", keywords: ["no", "wrong"]),
        EmojiItem(emoji: "❓", name: "Question Mark", keywords: ["help"]),
        EmojiItem(emoji: "❗", name: "Exclamation Mark", keywords: ["alert"]),
        EmojiItem(emoji: "💯", name: "Hundred Points", keywords: ["perfect", "100"]),
        EmojiItem(emoji: "🔴", name: "Red Circle", keywords: ["dot"]),
        EmojiItem(emoji: "🟠", name: "Orange Circle", keywords: ["dot"]),
        EmojiItem(emoji: "🟡", name: "Yellow Circle", keywords: ["dot"]),
        EmojiItem(emoji: "🟢", name: "Green Circle", keywords: ["dot"]),
        EmojiItem(emoji: "🔵", name: "Blue Circle", keywords: ["dot"]),
        EmojiItem(emoji: "🟣", name: "Purple Circle", keywords: ["dot"]),
        EmojiItem(emoji: "⚫", name: "Black Circle", keywords: ["dot"]),
        EmojiItem(emoji: "⚪", name: "White Circle", keywords: ["dot"]),
        EmojiItem(emoji: "🟤", name: "Brown Circle", keywords: ["dot"]),
    ]
}

/// Whether an icon string is an emoji or an SF Symbol name.
public enum IconKind: Equatable, Sendable {
    case emoji
    case symbol

    /// Classifies `value` as an emoji or an SF Symbol name.
    public static func classify(_ value: String) -> IconKind {
        value.isEmoji ? .emoji : .symbol
    }

    /// Color chrome only tints SF Symbols. Emoji keep their own glyphs.
    public static func offersColorChrome(for value: String) -> Bool {
        self.classify(value) == .symbol
    }
}

extension Character {
    var isEmoji: Bool {
        guard let scalar = self.unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || self.unicodeScalars.count > 1)
    }
}

extension String {
    /// `true` when the string starts with an emoji scalar.
    public var isEmoji: Bool {
        guard let firstChar = self.first else { return false }
        return firstChar.isEmoji
    }
}
