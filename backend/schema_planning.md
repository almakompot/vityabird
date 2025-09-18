# Backend Schema Planning Notes

## High-Level Architecture Goals
- Support cross-platform progression sync for single-player narrative with optional live updates.
- Provide content telemetry to inform satire effectiveness and pacing adjustments.
- Ensure mod-friendly data exposure without compromising core saves.

## Core Services & Modules
- **Authentication**: account linking, anonymous play upgrade path, token refresh cadence.
- **Player Profile**: progression states, unlocked lore, choices, cosmetics.
- **Narrative State Machine**: branching decisions, quest flags, timed events.
- **Economy & Inventory**: currencies, items, crafting components with anti-cheat considerations.
- **Telemetry & Analytics**: event schema, batching strategy, opt-out handling.
- **Content Delivery**: hotfix patching, seasonal drops, localization updates.

## Data Model Sketch
- `players` table: account_id (PK), display_name, platform_links, created_at, last_seen.
- `save_slots` table: slot_id (PK), account_id (FK), narrative_state JSONB, progression_version.
- `inventory_items` table: entry_id (PK), slot_id (FK), item_id, quantity, metadata.
- `quests` table: quest_id (PK), title, description, required_flags, reward_bundle.
- `quest_progress` table: entry_id (PK), slot_id (FK), quest_id (FK), status enum, last_updated.
- `telemetry_events` table: event_id (PK), account_id (FK), event_type, payload JSONB, timestamp.
- `content_packages` table: package_id (PK), version, release_notes, checksum, required_client_version.

## API Considerations
- REST or GraphQL for client interactions; document endpoints per module.
- Webhook or message bus for telemetry ingestion into analytics pipeline.
- Rate limiting policy and pagination guidelines.

## Security & Compliance Notes
- GDPR/CCPA data retention matrix and deletion workflows.
- Encryption at rest for sensitive fields, TLS everywhere in transit.
- Role-based access controls for admin tools and content management.

## Tooling & Workflow
- Schema migration strategy (e.g., Prisma, Alembic) with rollback plan.
- Seed data procedures for testing narrative branches.
- Local development environment requirements (Docker compose services, mock auth).

## Open Questions
- Offline mode expectations and reconciliation rules when reconnecting.
- Cross-save support for modded clients.
- Future multiplayer extension hooks and data partitioning.
