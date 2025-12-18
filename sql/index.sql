CREATE INDEX IF NOT EXISTS idx_viewings_agent ON viewings(agent_id);
CREATE INDEX IF NOT EXISTS idx_deals_agent_date ON deals(agent_id, deal_date);
CREATE INDEX IF NOT EXISTS idx_viewings_client ON viewings(client_id);
