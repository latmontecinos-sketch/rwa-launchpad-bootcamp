# Entrega semana 4 — RWA Launchpad

**La regla:** cada inversión es de al menos 500. Si es menor, falla con `AmountTooLow` (error #7) y no se cobra nada.

| | |
|---|---|
| Contract ID | [`CDVCA4UCPNX4IPM2ZGNDPSUNEV4S5HW6PFRNOLLMDDBVKVDKRAKUTBEI`](https://stellar.expert/explorer/testnet/contract/CDVCA4UCPNX4IPM2ZGNDPSUNEV4S5HW6PFRNOLLMDDBVKVDKRAKUTBEI) |
| Inversión exitosa | [`3958ca9f…`](https://stellar.expert/explorer/testnet/tx/3958ca9f0d7edfb3ad5331e3dfb4a535609cb659a867d206b3acab88b809a770) |
| Explicación y demo | https://aex-stellar-lab.vercel.app/tareas/rwa-launchpad |

## Qué cambié

- [`src/lib.rs`](src/lib.rs): `check_variation_gate` recibe el monto y rechaza lo menor a `MIN_INVESTMENT = 500`. Error nuevo: `AmountTooLow = 7`.
- [`src/test.rs`](src/test.rs): 100 falla y 500 funciona; 499 falla y 500 pasa.
- [`scripts/`](scripts): hacen el flujo de la tarea sobre la copia `CACCOK…` (ver Datos).

## Cómo correrlo

Desde `dia-3` (en Windows, con Git Bash):

```bash
cargo test                     # 5 tests
bash scripts/admin-tool.sh     # el admin inicializa y aprueba al inversionista
bash scripts/user-tool.sh      # invierte 100 (falla), 500 (funciona) y ve su balance
```

## Datos

- Se paga con XLM de testnet (el programa no publicó un token propio). 500 unidades = 0,00005 XLM = 5 RWA (precio: 100 por RWA).
- La inversión del video se hizo con los botones de la página, en su propia copia del contrato.
- Copia desplegada con los scripts: `CACCOKUX3J426XD745IGWDM4BI7KEBK65QQZD2ALE4OGNP6X5OMLEKMR` (admin `rwa-admin`, inversionista `rwa-inversor`).
- Transacciones de esa copia: [deploy](https://stellar.expert/explorer/testnet/tx/8d87e1c3b02f6d686e5f5410741225a378834ffdc244ad132f8a1e9c0010aee6) · [initialize](https://stellar.expert/explorer/testnet/tx/b2cbee6d380538a15b2fdb004f92f5f1d5a8c0ff2446b62cd9481ef373b179c2) · [whitelist](https://stellar.expert/explorer/testnet/tx/30d0e927ac8ef669538075b2e7dd1141fe1092137d22a58f471c547957e9c019).
- La inversión de 100 no tiene link: falla antes de enviarse.

## Arreglos a los scripts

- Stellar CLI 28 pide los `i128` como texto en el JSON de `initialize`.
- `.gitattributes` mantiene los `.sh` con saltos de línea LF; con CRLF, bash no los corre en Windows.
