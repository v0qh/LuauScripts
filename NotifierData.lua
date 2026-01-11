local Emojis = {
	["26"] = "1459717647007482129",
	["10B"] = "1459721766464131286",
	["Brazil"] = "1459721410745208967",
	["Bubblegum"] = "1459722106312065240",
	["Claws"] = "1459722249610334259",
	["Cometstruck"] = "1459725116052213873",
	["Disco"] = "1459721867358109766",
	["Explosive"] = "1459721966771769478",
	["Fire"] = "1459725256125186140",
	["Fireworks"] = "1459722441977892916",
	["Galactic"] = "1459722538807726121",
	["Glitched"] = "1459722166596665458",
	["Indonesian"] = "1459720426484797533",
	["Jackolantern"] = "1459720074448474297",
	["Lightning"] = "1459721274963263680",
	["Matteo Hat"] = "1459721518060797974",
	["Meowl"] = "1459720226995441775",
	["Nyan"] = "1459722792705724508",
	["Paint"] = "1459720840005288007",
	["RIP Gravestone"] = "1459720153150259250",
	["Reindeer Pet"] = "1459719728615395491",
	["Santa Hat"] = "1459719815114526982",
	["Shark Fin"] = "1459721672918564924",
	["Skeleton"] = "1459720745738567903",
	["Skibidi"] = "1459717670344593513",
	["Sleepy"] = "1459721339450425475",
	["Snow"] = "1459724956832239636",
	["Sombrero"] = "1459720702864134359",
	["Spider"] = "1459721076400459940",
	["Strawberry"] = "1459720932485501152",
	["Taco"] = "1459717586358112261",
	["Tie"] = "1459720599013425152",
	["UFO"] = "1459721163000512512",
	["Wet"] = "1459724844072702105",
	["Witch Hat"] = "1459720530062999583",
	["Zombie"] = "1459722326575812668",
}

local Branding = { 
	["Footer"] = "https://i.imgur.com/pcouB43_d.webp?maxwidth=760&fidelity=grand"
}

local Highlights = {
	["La Grande Combinasion"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/d/d8/Carti.png/revision/latest?cb=20250909171004",
		Min = 50000000,
	},
	["Garama and Madundung"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/e/ee/Garamadundung.png/revision/latest?cb=20250816022557",
		Min = nil,
	},
	["Nuclearo Dinossauro"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/c/c6/Nuclearo_Dinosauro.png/revision/latest?cb=20250902180735",
		Min = nil,
	},
	["Los Combinasionas"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/3/36/Stop_taking_my_chips_im_just_a_baybeh.png/revision/latest?cb=20250909223756",
		Min = 15000000,
	},
	["Dragon Cannelloni"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/3/31/Nah_uh.png/revision/latest?cb=20250919124457",
		Min = nil,
	},
	["Los Hotspotsitos"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/6/69/Loshotspotsitos.png/revision/latest?cb=20251226204212",
		Min = nil,
	},
	["Esok Sekolah"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/2/2a/EsokSekolah2.png/revision/latest?cb=20250819001020",
		Min = 100000000,
	},
	["Nooo My Hotspot"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/9/97/NoMyHotspot.png/revision/latest?cb=20250818145403",
		Min = nil,
	},
	["Ketupat Kepat"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/a/ac/KetupatKepat.png/revision/latest?cb=20251220220246",
		Min = nil,
	},
	["La Supreme Combinasion"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/5/52/SupremeCombinasion.png/revision/latest?cb=20250825130920",
		Min = nil,
	},
	["Ketchuru and Musturu"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/1/14/Ketchuru.png/revision/latest?cb=20251021163857",
		Min = nil,
	},
	["Spaghetti Tualetti"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/b/b8/Spaghettitualetti.png/revision/latest?cb=20251122142032",
		Min = nil,
	},
	["Los Nooo My Hotspotsitos"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/c/cb/LosNooMyHotspotsitos.png/revision/latest?cb=20250903124000",
		Min = nil,
	},
	["Trenostruzzo Turbo 4000"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/b/b0/Trenostruzzo4000.png/revision/latest?cb=20250920025139",
		Min = nil,
	},
	["Fragola La La La"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/a/af/Sammy_the_strawberry.png/revision/latest?cb=20250919134001",
		Min = nil,
	},
	["La Sahur Combinasion"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/e/eb/Sahuria.png/revision/latest?cb=20250920025821",
		Min = nil,
	},
	["Tralaledon"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/7/79/Brr_Brr_Patapem.png/revision/latest?cb=20250909171639",
		Min = nil,
	},
	["Los Bros"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/5/53/BROOOOOOOO.png/revision/latest?cb=20250909152032",
		Min = nil,
	},
	["Los Chicleteiras"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/4/4d/Los_ditos.png/revision/latest?cb=20251221211400",
		Min = nil,
	},
	["67"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/4/40/Fourtyone.png/revision/latest?cb=20251014024859",
		Min = nil,
	},
	["Las Sis"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/e/e8/Las_Sis.png/revision/latest?cb=20250914042020",
		Min = nil,
	},
	["Celularcini Viciosini"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/3/38/DO_NOT_GRAB_MY_PHONE%21%21%21.png/revision/latest?cb=20250914173250",
		Min = nil,
	},
	["La Extinct Grande"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/c/cd/La_Extinct_Grande.png/revision/latest?cb=20250914041757",
		Min = nil,
	},
	["Tacorita Bicicleta"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/0/0f/Gonna_rob_you_twin.png/revision/latest?cb=20251006133721",
		Min = nil,
	},
	["Mariachi Corazoni"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/5/5a/MariachiCora.png/revision/latest?cb=20251006211910",
		Min = nil,
	},
	["Los Tacoritas"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/4/40/My_kids_will_also_rob_you.png/revision/latest?cb=20250921171602",
		Min = nil,
	},
	["Tictac Sahur"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/6/6f/Time_moving_slow.png/revision/latest?cb=20251103171934",
		Min = nil,
	},
	["Money Money Puggy"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/0/09/Money_money_puggy.png/revision/latest?cb=20250928011934",
		Min = nil,
	},
	["Los Primos"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/9/96/LosPrimos.png/revision/latest?cb=20251006044831",
		Min = nil,
	},
	["Tang Tang Keletang"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/8/8f/TangTang.png/revision/latest?cb=20251014024653",
		Min = nil,
	},
	["Chillin Chili"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/e/e0/Chilin.png/revision/latest?cb=20251226231712",
		Min = nil,
	},
	["Los 67"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/d/db/Los-67.png/revision/latest?cb=20251103171526",
		Min = nil,
	},
	["La Secret Combinasion"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/f/f2/Lasecretcombinasion.png/revision/latest?cb=20251006044448",
		Min = nil,
	},
	["Burguro And Fryuro"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/6/65/Burguro-And-Fryuro.png/revision/latest?cb=20251007133840",
		Min = nil,
	},
	["Eviledon"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/7/78/Eviledonn.png/revision/latest?cb=20251012023919",
		Min = nil,
	},
	["La Spooky Grande"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/5/51/Spooky_Grande.png/revision/latest?cb=20251012022949",
		Min = nil,
	},
	["Los Mobilis"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/2/27/Losmobil.png/revision/latest?cb=20251012023251",
		Min = 90000000,
	},
	["Spooky and Pumpky"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/d/d6/Spookypumpky.png/revision/latest?cb=20251012023638",
		Min = nil,
	},
	["Mieteteira Bicicleteira"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/8/86/Mieteteira_Bicicleteira.png/revision/latest?cb=20251125132431",
		Min = 100000000,
	},
	["Quesadillo Vampiro"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/0/0e/VampiroQuesa.png/revision/latest?cb=20251129212633",
		Min = 30000000,
	},
	["Chipso and Queso"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/f/f8/Chipsoqueso.png/revision/latest?cb=20251030022105",
		Min = nil,
	},
	["Noo my Candy"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/1/12/Noo_my_candy_transparent.png/revision/latest?cb=20251105045041",
		Min = 25000000,
	},
	["Los Spooky Combinasionas"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/8/8a/Lospookycombi.png/revision/latest?cb=20251030015823",
		Min = nil,
	},
	["La Casa Boo"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/d/de/Casa_Booo.png/revision/latest?cb=20251220094233",
		Min = nil,
	},
	["Headless Horseman"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/f/ff/Headlesshorseman.png/revision/latest?cb=20251030020338",
		Min = nil,
	},
	["La Taco Combinasion"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/8/84/Latacocombi.png/revision/latest?cb=20251030015001",
		Min = nil,
	},
	["Capitano Moby"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/e/ef/Moby.png/revision/latest?cb=20251101185416",
		Min = nil,
	},
	["Guest 666"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/9/99/Guest666t.png/revision/latest?cb=20251102022619",
		Min = nil,
	},
	["Los Puggies"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/c/c8/LosPuggies2.png/revision/latest?cb=20251109012744",
		Min = nil,
	},
	["Los Spaghettis"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/d/db/LosSpaghettis.png/revision/latest?cb=20251109012155",
		Min = nil,
	},
	["Fragrama and Chocrama"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/5/56/Fragrama.png/revision/latest?cb=20251109011733",
		Min = nil,
	},
	["Swag Soda"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/9/9f/Swag_Soda.png/revision/latest?cb=20251116003702",
		Min = nil,
	},
	["Orcaledon"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/a/a6/Orcaledon.png/revision/latest?cb=20251119170121nk",
		Min = nil,
	},
	["Los Burritos"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/9/97/LosBurritos.png/revision/latest?cb=20251123123907",
		Min = 50000000,
	},
	["Fishino Clownino"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/d/d6/Fishino_Clownino.png/revision/latest?cb=20251123122601",
		Min = nil,
	},
	["Los Planitos"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/8/83/Los_Planitos.png/revision/latest?cb=20251123122230",
		Min = nil,
	},
	["W or L"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/2/28/Win_Or_Lose.png/revision/latest?cb=20251123084507",
		Min = nil,
	},
	["Lavadorito Spinito"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/f/ff/Lavadorito_Spinito.png/revision/latest?cb=20251123122422",
		Min = nil,
	},
	["Gobblino Uniciclino"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/c/c5/Gobblino_Uniciclino.png/revision/latest?cb=20251126164826",
		Min = nil,
	},
	["Cooki and Milki"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/9/9b/Cooki_and_milki.png/revision/latest?cb=20251106165517",
		Min = nil,
	},
	["25"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/5/5c/Rework.png/revision/latest?cb=20251207004831",
		Min = 25000000,
	},
	["List List List Sahur"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/d/d6/List_List_List_Sahur.png/revision/latest?cb=20251207005813",
		Min = 10000000,
	},
	["Chicleteira Noelteira"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/b/b3/Noel.png/revision/latest?cb=20251207005453",
		Min = 100000000,
	},
	["La Jolly Grande"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/5/5f/La_Chrismas_Grande.png/revision/latest?cb=20251207091730",
		Min = nil,
	},
	["Los Candies"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/f/f9/Candy%21.png/revision/latest?cb=20251218124920",
		Min = 100000000,
	},
	["La Ginger Sekolah"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/1/14/Esok_Ginger.png/revision/latest?cb=20251219224302",
		Min = nil,
	},
	["Reinito Sleighito"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/2/27/Reinito.png/revision/latest?cb=20251219225020",
		Min = nil,
	},
	["Los 25"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/9/9b/Transparent_Los_25.png/revision/latest?cb=20251218122100",
		Min = 100000000,
	},
	["Chimnino"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/c/c5/Chimnino.png/revision/latest?cb=20251219223904",
		Min = 100000000,
	},
	["Festive 67"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/c/c8/TransparentFestive67.png/revision/latest?cb=20251219224148",
		Min = nil,
	},
	["Swaggy Bros"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/8/85/Swaggy_Bros.png/revision/latest?cb=20251223161444",
		Min = nil,
	},
	["Dragon Gingerini"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/3/3a/DragonGingerini.png/revision/latest?cb=20251221003419",
		Min = nil,
	},
	["Money Money Reindeer"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/e/ec/MoneyMoneyReindeer.png/revision/latest?cb=20251221003105",
		Min = nil,
	},
	["Los Jolly Combinasionas"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/7/7b/Los_jollycombos.png/revision/latest?cb=20251227115909",
		Min = nil,
	},
	["Jolly Jolly Sahur"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/f/f1/JollyJollySahur.png/revision/latest?cb=20251227120057",
		Min = nil,
	},
	["Ginger Gerat"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/8/85/GingerGerat.png/revision/latest?cb=20251227115546",
		Min = nil,
	},
	["Tuff Toucan"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/3/3e/TuffToucan.png/revision/latest?cb=20260101134815",
		Min = nil,
	},
	["Cerberus"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/4/45/Cerberus.png/revision/latest?cb=20260109170320",
		Min = nil,
	},
	["Skibidi Toilet"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/3/34/Skibidi_toilet.png/revision/latest?cb=20251227221221",
		Min = nil,
	},
	["Meowl"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/b/b8/Clear_background_clear_meowl_image.png/revision/latest?cb=20251022133154",
		Min = nil,
	},
	["Strawberry Elephant"] = {
		Icon = "https://static.wikia.nocookie.net/stealabr/images/5/58/Strawberryelephant.png/revision/latest?cb=20250830235735",
		Min = nil,
	},
}
