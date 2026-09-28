# Entrega semana 4 — RWA Launchpad en testnet

Tarea final de Stellar Elite Bolivia: desplegar el launchpad de `dia-3/` con una regla de inversión y demostrar que funciona.

## La regla

Cada inversión debe ser de **al menos 500 unidades del token de pago**. Si es menor, `invest` falla con el error nuevo `AmountTooLow` (`Error(Contract, #7)`) y no se mueve ningún token.

- [`src/lib.rs`](src/lib.rs): `MIN_INVESTMENT = 500`, `Error::AmountTooLow = 7` y `check_variation_gate`, que ahora recibe el monto. `invest` la llama antes de cobrar.
- [`src/test.rs`](src/test.rs):
  - `test_invest_100_fails_and_500_works`: 100 falla con `AmountTooLow` sin tocar saldos; luego 500 funciona (5 RWA, el contrato recibe 500).
  - `test_invest_minimum_is_inclusive`: 499 falla y 500 pasa.

```bash
cd dia-3
cargo test            # 5 tests
stellar contract build
```

## Despliegue en testnet

| | |
|---|---|
| Contract ID | [`CACCOKUX3J426XD745IGWDM4BI7KEBK65QQZD2ALE4OGNP6X5OMLEKMR`](https://stellar.expert/explorer/testnet/contract/CACCOKUX3J426XD745IGWDM4BI7KEBK65QQZD2ALE4OGNP6X5OMLEKMR) |
| WASM (sha256) | `6b8fea5729c604af7673f1727cecbe7d3e4a6329dde363dfaefe9eeeb90ae1bf` |
| Token de pago | XLM nativo (SAC `CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC`); 1 unidad = 1 stroop |
| Precio | 100 unidades por RWA: 500 unidades = 5 RWA |
| Admin | `GDFALAAENVMLT62TJGD7RIT3PIAEIY2X7JCC7DVBUXDCCKTLSC3ZHPKU` (identidad `rwa-admin`) |
| Inversionista | `GBAI5EARC3PGRVMGD4CV5XTVMA3QKM2QZFWEVVGCPWXKGLM5EGY75TCC` (identidad `rwa-inversor`) |

El token de pago es el XLM nativo porque el programa no publicó la dirección del token del instructor: el inversionista lo recibe de Friendbot y no hace falta emitir nada.

## Flujo completo

Los scripts ya traen los valores de este despliegue (se pueden cambiar con variables de entorno). En Windows se corren desde Git Bash.

```bash
cd dia-3
bash scripts/admin-tool.sh     # initialize + set_whitelist del inversionista
bash scripts/user-tool.sh      # invest 100 (falla), invest 500, balance
```

| Paso | Transacción |
|---|---|
| Deploy | [`8d87e1c3…`](https://stellar.expert/explorer/testnet/tx/8d87e1c3b02f6d686e5f5410741225a378834ffdc244ad132f8a1e9c0010aee6) |
| `initialize` | [`b2cbee6d…`](https://stellar.expert/explorer/testnet/tx/b2cbee6d380538a15b2fdb004f92f5f1d5a8c0ff2446b62cd9481ef373b179c2) |
| `set_whitelist` | [`30d0e927…`](https://stellar.expert/explorer/testnet/tx/30d0e927ac8ef669538075b2e7dd1141fe1092137d22a58f471c547957e9c019) |
| `invest 100` | falla en la simulación con `Error(Contract, #7)` = `AmountTooLow`: no se envía ninguna transacción |
| `invest 500` | _pendiente_ |

## Cambios en los scripts

- `admin-tool.sh` y `user-tool.sh` aceptan un paso (`./admin-tool.sh whitelist`, `./user-tool.sh invest 500`); sin argumento corren el flujo de la tarea.
- `initialize` pasa `total_supply` y `price_per_unit` como texto: Stellar CLI 28 rechaza un número JSON para un `i128`.
- `.gitattributes` fuerza LF en los `.sh`; con CRLF, bash no los puede correr en Windows.
