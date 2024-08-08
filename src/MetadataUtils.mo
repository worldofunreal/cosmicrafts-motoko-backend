import TypesICRC7 "/icrc7/types";

module MetadataUtils {

    public func getChestMetadata(uuid: Nat, rarity: Nat): TypesICRC7.Metadata {
        switch rarity {
            case (1) {
                return {
                    general = {
                        category = ?#chest({
                            general = {
                                category = null;
                                rarity = ?1;
                                faction = null;
                                id = uuid;
                                name = "Cosmic Cache";
                                description = "A simple box containing basic tokens and resources to kickstart your cosmic journey. Contains between 10 and 20 tokens.";
                                image = "url_to_cosmic_cache_image";
                            };
                            soul = null;
                        });
                        rarity = ?1;
                        faction = null;
                        id = uuid;
                        name = "Cosmic Cache";
                        description = "A simple box containing basic tokens and resources to kickstart your cosmic journey. Contains between 10 and 20 tokens.";
                        image = "url_to_cosmic_cache_image";
                    };
                    basic = null;
                    skills = null;
                    skins = null;
                    soul = null;
                };
            };
            case (2) {
                return {
                    general = {
                        category = ?#chest({
                            general = {
                                category = null;
                                rarity = ?2;
                                faction = null;
                                id = uuid;
                                name = "Stellar Box";
                                description = "A box filled with uncommon tokens and stellar materials for the aspiring explorer. Contains between 21 and 33 tokens.";
                                image = "url_to_stellar_box_image";
                            };
                            soul = null;
                        });
                        rarity = ?2;
                        faction = null;
                        id = uuid;
                        name = "Stellar Box";
                        description = "A box filled with uncommon tokens and stellar materials for the aspiring explorer. Contains between 21 and 33 tokens.";
                        image = "url_to_stellar_box_image";
                    };
                    basic = null;
                    skills = null;
                    skins = null;
                    soul = null;
                };
            };
            case (3) {
                return {
                    general = {
                        category = ?#chest({
                            general = {
                                category = null;
                                rarity = ?3;
                                faction = null;
                                id = uuid;
                                name = "Nebula Cube";
                                description = "A rare cube holding valuable tokens and rare nebula artifacts. Contains between 33 and 47 tokens.";
                                image = "url_to_nebula_cube_image";
                            };
                            soul = null;
                        });
                        rarity = ?3;
                        faction = null;
                        id = uuid;
                        name = "Nebula Cube";
                        description = "A rare cube holding valuable tokens and rare nebula artifacts. Contains between 33 and 47 tokens.";
                        image = "url_to_nebula_cube_image";
                    };
                    basic = null;
                    skills = null;
                    skins = null;
                    soul = null;
                };
            };
            case (4) {
                return {
                    general = {
                        category = ?#chest({
                            general = {
                                category = null;
                                rarity = ?4;
                                faction = null;
                                id = uuid;
                                name = "Galactic Crate";
                                description = "An epic crate brimming with galactic tokens and advanced cosmic treasures. Contains between 49 and 65 tokens.";
                                image = "url_to_galactic_crate_image";
                            };
                            soul = null;
                        });
                        rarity = ?4;
                        faction = null;
                        id = uuid;
                        name = "Galactic Crate";
                        description = "An epic crate brimming with galactic tokens and advanced cosmic treasures. Contains between 49 and 65 tokens.";
                        image = "url_to_galactic_crate_image";
                    };
                    basic = null;
                    skills = null;
                    skins = null;
                    soul = null;
                };
            };
            case (5) {
                return {
                    general = {
                        category = ?#chest({
                            general = {
                                category = null;
                                rarity = ?5;
                                faction = null;
                                id = uuid;
                                name = "Astral Vault";
                                description = "A legendary vault containing exclusive tokens and rare astral relics. Contains between 69 and 87 tokens.";
                                image = "url_to_astral_vault_image";
                            };
                            soul = null;
                        });
                        rarity = ?5;
                        faction = null;
                        id = uuid;
                        name = "Astral Vault";
                        description = "A legendary vault containing exclusive tokens and rare astral relics. Contains between 69 and 87 tokens.";
                        image = "url_to_astral_vault_image";
                    };
                    basic = null;
                    skills = null;
                    skins = null;
                    soul = null;
                };
            };
            case (6) {
                return {
                    general = {
                        category = ?#chest({
                            general = {
                                category = null;
                                rarity = ?6;
                                faction = null;
                                id = uuid;
                                name = "Celestial Locker";
                                description = "A mythical locker filled with celestial tokens and powerful cosmic items. Contains between 93 and 113 tokens.";
                                image = "url_to_celestial_locker_image";
                            };
                            soul = null;
                        });
                        rarity = ?6;
                        faction = null;
                        id = uuid;
                        name = "Celestial Locker";
                        description = "A mythical locker filled with celestial tokens and powerful cosmic items. Contains between 93 and 113 tokens.";
                        image = "url_to_celestial_locker_image";
                    };
                    basic = null;
                    skills = null;
                    skins = null;
                    soul = null;
                };
            };
            case (7) {
                return {
                    general = {
                        category = ?#chest({
                            general = {
                                category = null;
                                rarity = ?7;
                                faction = null;
                                id = uuid;
                                name = "Quantum Chest";
                                description = "An exotic chest holding quantum tokens and exceptionally rare cosmic wonders. Contains between 121 and 143 tokens.";
                                image = "url_to_quantum_chest_image";
                            };
                            soul = null;
                        });
                        rarity = ?7;
                        faction = null;
                        id = uuid;
                        name = "Quantum Chest";
                        description = "An exotic chest holding quantum tokens and exceptionally rare cosmic wonders. Contains between 121 and 143 tokens.";
                        image = "url_to_quantum_chest_image";
                    };
                    basic = null;
                    skills = null;
                    skins = null;
                    soul = null;
                };
            };
            case (8) {
                return {
                    general = {
                        category = ?#chest({
                            general = {
                                category = null;
                                rarity = ?8;
                                faction = null;
                                id = uuid;
                                name = "Ethereal Metacube";
                                description = "A divine metacube containing ethereal tokens and the most coveted cosmic treasures. Contains between 153 and 177 tokens.";
                                image = "url_to_ethereal_metacube_image";
                            };
                            soul = null;
                        });
                        rarity = ?8;
                        faction = null;
                        id = uuid;
                        name = "Ethereal Metacube";
                        description = "A divine metacube containing ethereal tokens and the most coveted cosmic treasures. Contains between 153 and 177 tokens.";
                        image = "url_to_ethereal_metacube_image";
                    };
                    basic = null;
                    skills = null;
                    skins = null;
                    soul = null;
                };
            };
            case (_) {
                // Default to Cosmic Cache if rarity is not recognized
                return {
                    general = {
                        category = ?#chest({
                            general = {
                                category = null;
                                rarity = ?1;
                                faction = null;
                                id = uuid;
                                name = "Cosmic Cache";
                                description = "A simple box containing basic tokens and resources to kickstart your cosmic journey. Contains between 10 and 20 tokens.";
                                image = "url_to_cosmic_cache_image";
                            };
                            soul = null;
                        });
                        rarity = ?1;
                        faction = null;
                        id = uuid;
                        name = "Cosmic Cache";
                        description = "A simple box containing basic tokens and resources to kickstart your cosmic journey. Contains between 10 and 20 tokens.";
                        image = "url_to_cosmic_cache_image";
                    };
                    basic = null;
                    skills = null;
                    skins = null;
                    soul = null;
                };
            };
        }
    };

}
