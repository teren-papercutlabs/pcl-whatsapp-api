-- Fix always online validation: prevent alwaysOnline=true when instance is disconnected
-- This migration ensures that only connected instances can have alwaysOnline=true

-- Update existing settings to force alwaysOnline=false for disconnected instances
UPDATE "Setting" 
SET "alwaysOnline" = CASE 
  WHEN "Instance"."connectionStatus" = 'open' THEN "Setting"."alwaysOnline"
  ELSE false 
END
FROM "Instance" 
WHERE "Setting"."instanceId" = "Instance"."id";

-- Add a comment to document the business rule
COMMENT ON COLUMN "Setting"."alwaysOnline" IS 'Controls whether WhatsApp instance appears always online. Can only be true when connectionStatus is open to prevent notification suppression.';