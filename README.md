# Investment Portfolio Tracker — SQL Server Relational Analytics

An independent SQL Server/T-SQL portfolio data model with nine related tables, indexed transaction history, analytical stored procedures and reproducible sample records.

## Database design

| Table | Grain / purpose |
|---|---|
| `users` | One account holder per row |
| `portfolios` | Portfolio owned by a user |
| `securities` | Unique tradable instrument |
| `transactions` | Individual BUY/SELL trade |
| `holdings` | Current stored position by portfolio and security |
| `dividends` | Portfolio-level dividend entitlement |
| `price_history` | Closing price by security and date |
| `portfolio_snapshots` | Stored portfolio value by date |
| `watchlists` | Saved user/security pair |

The schema uses primary and foreign keys, uniqueness checks, nonnegative amount constraints, and indexes for transaction lookups. `price_history` has a composite `(security_id, price_date)` key.

## Run in SQL Server

Run the scripts **in this order** against a new empty database, using SQL Server Management Studio or another client supporting T-SQL `GO` separators:

1. `01_schema.sql` — create nine tables, constraints and indexes.
2. `02_sample_data.sql` — insert one fictional account, one portfolio, three securities and sample holdings/prices.
3. `03_analytics.sql` — create two stored procedures and run the monthly transaction summary query.

Example:

```sql
EXEC dbo.usp_PortfolioValuation @portfolio_id = 1;
EXEC dbo.usp_PortfolioAllocation @portfolio_id = 1;

SELECT portfolio_id, security_id, quantity, avg_cost
FROM dbo.holdings
WHERE portfolio_id = 1;
```

The valuation procedure uses `ROW_NUMBER()` to select each security's most recent available closing price and computes market value, cost basis, unrealized gain/loss and fractional return. The allocation procedure computes each position's share of total market value using a windowed `SUM(... ) OVER ()`.

## Assumptions and limitations

- All included account details and transactions are **illustrative sample data**, not a broker feed or investment advice.
- The seed script assumes a **fresh database** with identity keys beginning at 1; it is not intended to be rerun unchanged.
- Stored `holdings` are populated separately; there is **no automatic position-reconciliation process** from transactions. They must be maintained consistently in a real deployment.
- Latest recorded prices are used without an `as_of` restriction; historical point-in-time portfolio valuation is not implemented.
- Realized P&L, taxes, corporate actions, live price ingestion and production authentication are outside the present implementation.
- These scripts target SQL Server; cross-engine compatibility has not been claimed.

This repository demonstrates database modeling and analytical SQL. It is not presented as a deployed brokerage platform.
