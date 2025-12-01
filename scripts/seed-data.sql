-- Redacted seed data for QA/PR environments
INSERT INTO users (id, email, name)
VALUES
  (gen_random_uuid(), 'demo+user1@example.com', 'Demo User 1'),
  (gen_random_uuid(), 'demo+user2@example.com', 'Demo User 2')
ON CONFLICT DO NOTHING;

INSERT INTO feature_flags (key, enabled)
VALUES
  ('demo-mode', true)
ON CONFLICT (key) DO UPDATE SET enabled = EXCLUDED.enabled;
