#![cfg(test)]

use super::*;
use soroban_sdk::{
    testutils::Address as _,
    token::{StellarAssetClient, TokenClient},
    Address, Env, Symbol,
};

fn setup_with_payment_token(env: &Env) -> (Address, Address, Address, RwaLaunchpadClient<'_>) {
    let contract_id = env.register(RwaLaunchpad, ());
    let client = RwaLaunchpadClient::new(env, &contract_id);

    let admin = Address::generate(env);
    let sac = env.register_stellar_asset_contract_v2(admin.clone());
    let payment_token = sac.address();

    let asset = AssetInfo {
        name: Symbol::new(env, "RWAToken"),
        total_supply: 1_000_000,
        price_per_unit: 100,
        payment_token: payment_token.clone(),
        paused: false,
    };

    env.mock_all_auths();
    client.initialize(&admin, &asset);

    (admin, payment_token, contract_id, client)
}

#[test]
fn test_invest() {
    let env = Env::default();
    let (admin, payment_token, _contract_id, client) = setup_with_payment_token(&env);
    let investor = Address::generate(&env);

    let token_admin = StellarAssetClient::new(&env, &payment_token);
    let token = TokenClient::new(&env, &payment_token);
    token_admin.mint(&investor, &1_000);

    env.mock_all_auths();
    client.set_whitelist(&admin, &investor, &true);

    let minted = client.invest(&investor, &500);
    assert_eq!(minted, 5);
    assert_eq!(client.balance(&investor), 5);
    assert_eq!(token.balance(&investor), 500);
}

#[test]
fn test_withdraw() {
    let env = Env::default();
    let (admin, payment_token, _contract_id, client) = setup_with_payment_token(&env);
    let investor = Address::generate(&env);
    let treasury = Address::generate(&env);

    let token_admin = StellarAssetClient::new(&env, &payment_token);
    let token = TokenClient::new(&env, &payment_token);
    token_admin.mint(&investor, &1_000);

    env.mock_all_auths();
    client.set_whitelist(&admin, &investor, &true);
    client.invest(&investor, &500);

    client.withdraw(&admin, &treasury, &500);

    assert_eq!(token.balance(&treasury), 500);
}

#[test]
#[should_panic(expected = "Error(Contract, #5)")]
fn test_invest_not_whitelisted() {
    let env = Env::default();
    let (_admin, payment_token, _contract_id, client) = setup_with_payment_token(&env);
    let investor = Address::generate(&env);

    let token_admin = StellarAssetClient::new(&env, &payment_token);
    token_admin.mint(&investor, &1_000);

    env.mock_all_auths();
    client.invest(&investor, &500);
}

fn funded_whitelisted_investor(
    env: &Env,
    admin: &Address,
    payment_token: &Address,
    client: &RwaLaunchpadClient<'_>,
) -> Address {
    let investor = Address::generate(env);
    StellarAssetClient::new(env, payment_token).mint(&investor, &1_000);
    env.mock_all_auths();
    client.set_whitelist(admin, &investor, &true);
    investor
}

#[test]
fn test_invest_100_fails_and_500_works() {
    let env = Env::default();
    let (admin, payment_token, contract_id, client) = setup_with_payment_token(&env);
    let investor = funded_whitelisted_investor(&env, &admin, &payment_token, &client);
    let token = TokenClient::new(&env, &payment_token);

    assert_eq!(
        client.try_invest(&investor, &100),
        Err(Ok(Error::AmountTooLow.into()))
    );
    assert_eq!(client.balance(&investor), 0);
    assert_eq!(token.balance(&investor), 1_000);
    assert_eq!(token.balance(&contract_id), 0);

    assert_eq!(client.invest(&investor, &500), 5);
    assert_eq!(client.balance(&investor), 5);
    assert_eq!(token.balance(&investor), 500);
    assert_eq!(token.balance(&contract_id), 500);
}

#[test]
fn test_invest_minimum_is_inclusive() {
    let env = Env::default();
    let (admin, payment_token, _contract_id, client) = setup_with_payment_token(&env);
    let investor = funded_whitelisted_investor(&env, &admin, &payment_token, &client);

    assert_eq!(
        client.try_invest(&investor, &(MIN_INVESTMENT - 1)),
        Err(Ok(Error::AmountTooLow.into()))
    );
    assert_eq!(client.invest(&investor, &MIN_INVESTMENT), 5);
}
