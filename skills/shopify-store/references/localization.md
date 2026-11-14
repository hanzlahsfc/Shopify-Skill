# Localization

Put every locale value in one `site` config (currency, symbol, thresholds, shipping
rates, phone, announcement) and format money through one `formatPrice()`.

## Money formats (match what Shopify stores in that market show)

| Market | Format | Decimals |
|---|---|---|
| US/CA/AU | `$259.00` | 2 |
| UK | `£259.00` | 2 |
| EU | `€259,00` or `€259.00` per locale | 2 |
| Pakistan | `Rs 14,999` | 0 |
| India | `Rs. 1,499.00` / `₹1,499.00` | 2 |
| UAE / KSA | `Dhs. 299.00` / `SAR 299.00` | 2 |
| Kuwait | `KWD 12.500` | 3 |

Price points should look local (PK: 9,999 / 14,999; US: 149.00 / 259.00). When converting a
catalog, rewrite each price deliberately - sequential find/replace corrupts values.

## Pakistan preset (proven)

- Currency PKR, symbol `Rs`, no decimals. Free shipping over Rs 8,000; standard Rs 350
  (3-5 working days), express Rs 750 (1-2 days, major cities).
- **Cash on delivery first and default**; then bank transfer / JazzCash / Easypaisa; cards
  only if a gateway exists. No BNPL/Afterpay/Klarna copy.
- Regions: Punjab, Sindh, Khyber Pakhtunkhwa, Balochistan, Islamabad Capital Territory,
  Gilgit-Baltistan, Azad Jammu and Kashmir. Phone required, `+92 3XX XXXXXXX`. Postal
  code optional.
- Couriers in copy: TCS, Leopards, M&P, PostEx, Trax. "Nationwide delivery".
- COD order flow: call to confirm -> dispatch -> rider collects cash -> mark collected.
  Returns: 7-14 day exchange is common; state who pays return shipping.

## Other markets - checklist

Region list (states/provinces/emirates), postal code required?, phone format, tax line
("Tax included" vs "Taxes calculated at checkout"), typical carriers, common payment
methods (US: cards, Shop Pay, Apple/Google Pay, Afterpay; GCC: COD + cards + Tabby/Tamara;
India: UPI + COD), RTL layout for Arabic/Urdu UI, date format.
