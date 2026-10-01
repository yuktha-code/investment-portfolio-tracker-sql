CREATE OR ALTER PROCEDURE dbo.usp_PortfolioValuation @portfolio_id INT
AS
BEGIN
    SET NOCOUNT ON;
    WITH LatestPrice AS (
        SELECT ph.security_id, ph.close_price,
               ROW_NUMBER() OVER (PARTITION BY ph.security_id ORDER BY ph.price_date DESC) AS rn
        FROM dbo.price_history ph
    )
    SELECT h.portfolio_id, s.ticker, s.security_name, h.quantity, h.avg_cost,
           lp.close_price AS latest_price,
           h.quantity * lp.close_price AS market_value,
           h.quantity * h.avg_cost AS cost_basis,
           h.quantity * (lp.close_price - h.avg_cost) AS unrealised_pnl,
           CASE WHEN h.avg_cost = 0 THEN NULL
                ELSE (lp.close_price / h.avg_cost - 1.0) END AS return_pct
    FROM dbo.holdings h
    JOIN dbo.securities s ON s.security_id = h.security_id
    JOIN LatestPrice lp ON lp.security_id = h.security_id AND lp.rn = 1
    WHERE h.portfolio_id = @portfolio_id;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_PortfolioAllocation @portfolio_id INT
AS
BEGIN
    SET NOCOUNT ON;
    WITH LatestPrice AS (
        SELECT ph.security_id, ph.close_price,
               ROW_NUMBER() OVER (PARTITION BY ph.security_id ORDER BY ph.price_date DESC) AS rn
        FROM dbo.price_history ph
    ), MV AS (
        SELECT h.security_id, h.quantity * lp.close_price AS market_value
        FROM dbo.holdings h
        JOIN LatestPrice lp ON lp.security_id = h.security_id AND lp.rn = 1
        WHERE h.portfolio_id = @portfolio_id
    )
    SELECT s.ticker, s.sector, mv.market_value,
           mv.market_value / NULLIF(SUM(mv.market_value) OVER (),0) AS portfolio_weight
    FROM MV mv
    JOIN dbo.securities s ON s.security_id = mv.security_id
    ORDER BY portfolio_weight DESC;
END;
GO

-- Dashboard-style transaction summary by month
SELECT t.portfolio_id,
       DATEFROMPARTS(YEAR(t.transaction_date), MONTH(t.transaction_date), 1) AS month_start,
       COUNT(*) AS transaction_count,
       SUM(CASE WHEN t.transaction_type='BUY' THEN t.quantity*t.price+t.fees ELSE 0 END) AS gross_buys,
       SUM(CASE WHEN t.transaction_type='SELL' THEN t.quantity*t.price-t.fees ELSE 0 END) AS gross_sells
FROM dbo.transactions t
GROUP BY t.portfolio_id, DATEFROMPARTS(YEAR(t.transaction_date), MONTH(t.transaction_date), 1)
ORDER BY t.portfolio_id, month_start;
