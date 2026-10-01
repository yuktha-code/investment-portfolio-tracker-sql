INSERT INTO dbo.users(email, full_name)
VALUES ('demo@example.com', 'Demo User');

INSERT INTO dbo.portfolios(user_id, portfolio_name)
VALUES (1, 'Core Portfolio');

INSERT INTO dbo.securities(ticker, security_name, asset_class, sector, exchange_code)
VALUES
('RELIANCE.NS','Reliance Industries','Equity','Conglomerate','NSE'),
('TCS.NS','Tata Consultancy Services','Equity','IT','NSE'),
('HDFCBANK.NS','HDFC Bank','Equity','Financials','NSE');

INSERT INTO dbo.transactions(portfolio_id, security_id, transaction_date, transaction_type, quantity, price, fees)
VALUES
(1,1,'2026-01-10','BUY',10,1400,20),
(1,2,'2026-01-12','BUY',5,3500,20),
(1,3,'2026-01-15','BUY',12,1600,20);

INSERT INTO dbo.holdings(portfolio_id, security_id, quantity, avg_cost)
VALUES (1,1,10,1400),(1,2,5,3500),(1,3,12,1600);

INSERT INTO dbo.price_history(security_id, price_date, close_price)
VALUES
(1,'2026-09-30',1539.80),
(2,'2026-09-30',3850.00),
(3,'2026-09-30',1750.00);
