CREATE TABLE dbo.users (
    user_id INT IDENTITY PRIMARY KEY,
    email NVARCHAR(255) NOT NULL UNIQUE,
    full_name NVARCHAR(120) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.portfolios (
    portfolio_id INT IDENTITY PRIMARY KEY,
    user_id INT NOT NULL,
    portfolio_name NVARCHAR(120) NOT NULL,
    base_currency CHAR(3) NOT NULL DEFAULT 'INR',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_portfolios_users FOREIGN KEY (user_id) REFERENCES dbo.users(user_id),
    CONSTRAINT UQ_user_portfolio UNIQUE (user_id, portfolio_name)
);

CREATE TABLE dbo.securities (
    security_id INT IDENTITY PRIMARY KEY,
    ticker NVARCHAR(32) NOT NULL UNIQUE,
    security_name NVARCHAR(160) NOT NULL,
    asset_class NVARCHAR(40) NOT NULL,
    sector NVARCHAR(80) NULL,
    exchange_code NVARCHAR(20) NULL,
    currency CHAR(3) NOT NULL DEFAULT 'INR'
);

CREATE TABLE dbo.transactions (
    transaction_id BIGINT IDENTITY PRIMARY KEY,
    portfolio_id INT NOT NULL,
    security_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_type VARCHAR(8) NOT NULL CHECK (transaction_type IN ('BUY','SELL')),
    quantity DECIMAL(19,6) NOT NULL CHECK (quantity > 0),
    price DECIMAL(19,6) NOT NULL CHECK (price >= 0),
    fees DECIMAL(19,6) NOT NULL DEFAULT 0 CHECK (fees >= 0),
    CONSTRAINT FK_tx_portfolio FOREIGN KEY (portfolio_id) REFERENCES dbo.portfolios(portfolio_id),
    CONSTRAINT FK_tx_security FOREIGN KEY (security_id) REFERENCES dbo.securities(security_id)
);
CREATE INDEX IX_tx_portfolio_date ON dbo.transactions(portfolio_id, transaction_date);
CREATE INDEX IX_tx_security_date ON dbo.transactions(security_id, transaction_date);

CREATE TABLE dbo.holdings (
    portfolio_id INT NOT NULL,
    security_id INT NOT NULL,
    quantity DECIMAL(19,6) NOT NULL DEFAULT 0,
    avg_cost DECIMAL(19,6) NOT NULL DEFAULT 0,
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_holdings PRIMARY KEY (portfolio_id, security_id),
    CONSTRAINT FK_hold_portfolio FOREIGN KEY (portfolio_id) REFERENCES dbo.portfolios(portfolio_id),
    CONSTRAINT FK_hold_security FOREIGN KEY (security_id) REFERENCES dbo.securities(security_id)
);

CREATE TABLE dbo.dividends (
    dividend_id BIGINT IDENTITY PRIMARY KEY,
    portfolio_id INT NOT NULL,
    security_id INT NOT NULL,
    ex_date DATE NOT NULL,
    payment_date DATE NULL,
    amount_per_share DECIMAL(19,6) NOT NULL CHECK (amount_per_share >= 0),
    shares_eligible DECIMAL(19,6) NOT NULL CHECK (shares_eligible >= 0),
    CONSTRAINT FK_div_portfolio FOREIGN KEY (portfolio_id) REFERENCES dbo.portfolios(portfolio_id),
    CONSTRAINT FK_div_security FOREIGN KEY (security_id) REFERENCES dbo.securities(security_id)
);

CREATE TABLE dbo.price_history (
    security_id INT NOT NULL,
    price_date DATE NOT NULL,
    close_price DECIMAL(19,6) NOT NULL CHECK (close_price >= 0),
    CONSTRAINT PK_price_history PRIMARY KEY (security_id, price_date),
    CONSTRAINT FK_price_security FOREIGN KEY (security_id) REFERENCES dbo.securities(security_id)
);

CREATE TABLE dbo.portfolio_snapshots (
    portfolio_id INT NOT NULL,
    snapshot_date DATE NOT NULL,
    market_value DECIMAL(19,2) NOT NULL,
    cost_basis DECIMAL(19,2) NOT NULL,
    cash_flow DECIMAL(19,2) NOT NULL DEFAULT 0,
    CONSTRAINT PK_portfolio_snapshots PRIMARY KEY (portfolio_id, snapshot_date),
    CONSTRAINT FK_snap_portfolio FOREIGN KEY (portfolio_id) REFERENCES dbo.portfolios(portfolio_id)
);

CREATE TABLE dbo.watchlists (
    user_id INT NOT NULL,
    security_id INT NOT NULL,
    added_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_watchlists PRIMARY KEY (user_id, security_id),
    CONSTRAINT FK_watch_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id),
    CONSTRAINT FK_watch_security FOREIGN KEY (security_id) REFERENCES dbo.securities(security_id)
);
