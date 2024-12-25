
#[test_only]
module game::hero_tests;

#[test]
fun slay_boar_test() {
    use sui::test_scenario;
    use sui::coin::{Self};
    use game::hero::{new_game, GameInfo, acquire_hero, GameAdmin, send_boar, Boar, Hero, slay};

    let admin = @0xAD014;
    let player = @0x0;

    let mut scenario_val = test_scenario::begin(admin);
    let scenario = &mut scenario_val;
    // Run the create new game 
    test_scenario::next_tx(scenario, admin);
    {
        new_game(test_scenario::ctx(scenario));
    };
    // Tạo Hero 
    test_scenario::next_tx(scenario, player);
    {
        let game = test_scenario::take_immutable<GameInfo>(scenario);
        let game_ref = &game;
        let coin = coin::mint_for_testing(500, test_scenario::ctx(scenario));
        acquire_hero(game_ref, coin, test_scenario::ctx(scenario));
        test_scenario::return_immutable(game);
    };
    // Admin tạo boar cho Player 
    test_scenario::next_tx(scenario, admin);
    {
        let game = test_scenario::take_immutable<GameInfo>(scenario);
        let game_ref = &game;
        let mut admin_cap = test_scenario::take_from_sender<GameAdmin>(scenario);
        send_boar(game_ref, &mut admin_cap, 10, 10, player, test_scenario::ctx(scenario));
        test_scenario::return_to_sender(scenario, admin_cap);
        test_scenario::return_immutable(game);
    };
    // Player slays the boar!
    test_scenario::next_tx(scenario, player);
    {
        let game = test_scenario::take_immutable<GameInfo>(scenario);
        let game_ref = &game;
        let mut hero = test_scenario::take_from_sender<Hero>(scenario);
        let boar = test_scenario::take_from_sender<Boar>(scenario);
        slay(game_ref, &mut hero, boar, test_scenario::ctx(scenario));
        test_scenario::return_to_sender(scenario, hero);
        test_scenario::return_immutable(game);
    };
    test_scenario::end(scenario_val);
}
