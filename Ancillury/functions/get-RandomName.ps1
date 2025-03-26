function Get-RandomName {


    $adjectives = @(
        "Happy", "Sleepy", "Brave", "Mighty", "Clever", "Crazy", "Jolly", "Lazy", "Noble", "Quick",
        "Bold", "Fierce", "Gentle", "Lively", "Majestic", "Radiant", "Witty", "Zesty", "Energetic", "Fearless",
        "Shiny", "Daring", "Epic", "Vivid", "Cheerful", "Lucky", "Dynamic", "Brilliant", "Cunning", "Charming",
        "Mysterious", "Funky", "Legendary", "Fantastic", "Glorious", "Whimsical", "Marvelous", "Dashing", "Fiery", "Eager",
        "Gracious", "Swift", "Gallant", "Vibrant", "Elusive", "Magnetic", "Inventive", "Rebellious", "Serene", "Gleaming",
        "Blazing", "Spirited", "Heroic", "Exuberant", "Luminous", "Sizzling", "Tenacious", "Zany", "Wild", "Quirky",
        "Enchanting", "Magical", "Enthusiastic", "Wondrous", "Breezy", "Hearty", "Humble", "Playful", "Radiant", "Nimble",
        "Invincible", "Stellar", "Snappy", "Perceptive", "Sharp", "Gallant", "Crisp", "Savvy", "Diligent", "Suave",
        "Turbulent", "Exotic", "Profound", "Ingenious", "Reckless", "Artistic", "Fanciful", "Exalted", "Regal", "Sly",
        "Dapper", "Hasty", "Lush", "Opulent", "Mellow", "Robust", "Fearless", "Chivalrous", "Daring", "Mirthful",
        "Epic", "Sprightly", "Dazzling", "Elated", "Quaint", "Majestic", "Grandiose", "Spectacular", "Vivacious", "Eccentric"
    )
    
    $nouns = @(
        "Tiger", "Eagle", "Panda", "Otter", "Falcon", "Lion", "Dolphin", "Fox", "Rabbit", "Bear",
        "Mountain", "River", "Ocean", "Desert", "Forest", "Valley", "Canyon", "Island", "Glacier", "Volcano",
        "Bridge", "Castle", "Fortress", "Tower", "Lighthouse", "Cathedral", "Palace", "Mansion", "Museum", "Temple",
        "Rocket", "Satellite", "Spaceship", "Comet", "Meteor", "Planet", "Galaxy", "Nebula", "Asteroid", "Blackhole",
        "Guitar", "Violin", "Piano", "Trumpet", "Drum", "Flute", "Trombone", "Harp", "Cello", "Saxophone",
        "Hammer", "Wrench", "Drill", "Saw", "Chisel", "Screwdriver", "Anvil", "Ladder", "Compass", "Ruler",
        "Chef", "Doctor", "Engineer", "Artist", "Pilot", "Writer", "Explorer", "Astronaut", "Detective", "Sculptor",
        "Computer", "Server", "Network", "Firewall", "Router", "Algorithm", "Database", "Terminal", "Cipher", "Robot",
        "Treasure", "Crown", "Scroll", "Lantern", "Armor", "Shield", "Sword", "Potion", "Key", "Map",
        "Library", "University", "Market", "Cafe", "Hospital", "Theater", "Bakery", "Fountain", "Train", "Airport",
        "Diamond", "Emerald", "Sapphire", "Ruby", "Gold", "Silver", "Bronze", "Crystal", "Pearl", "Obsidian",
        "Storm", "Lightning", "Hurricane", "Blizzard", "Tornado", "Earthquake", "Eclipse", "Sunrise", "Twilight", "Rainbow",
        "Victory", "Wisdom", "Courage", "Honor", "Glory", "Justice", "Destiny", "Harmony", "Freedom", "Fortune"
    )
    

    $randomAdjective = Get-Random -InputObject $adjectives
    $randomNoun = Get-Random -InputObject $nouns

    return "$($randomAdjective)$randomNoun"
}

# Generate a name
# Get-RandomName