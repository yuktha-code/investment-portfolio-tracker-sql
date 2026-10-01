# Investment Portfolio Tracker — Relational Analytics

SQL Server / T-SQL project implementing a relational portfolio data model and analytical procedures for valuation, allocation, gains/losses and dashboard summaries.

## Data model
Nine tables: users, portfolios, securities, transactions, holdings, dividends, price_history, portfolio_snapshots and watchlists.

## Highlights
- Primary/foreign keys, uniqueness constraints and useful indexes.
- Transaction-level grain with portfolio/security joins.
- Stored procedures for current valuation, allocation and realised/unrealised P&L style summaries.
- Window functions and aggregations for dashboard analytics.

Run `01_schema.sql`, then `02_sample_data.sql`, then `03_analytics.sql` in SQL Server.
