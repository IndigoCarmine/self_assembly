# Design TODO List

## Core Architecture
- [x] **World (Forge2D)**
    - [x] Design the main loop for physical updates (leveraging `Forge2DGame`).
    - [x] Integrate `PeriodicBoundarySystem` for topological management.
    - [ ] Define injection mechanism for `ConnectionSystem` and `BreakSystem`.
    - [ ] Ensure attraction and detachment logic runs within the World update.

- [x] **EntityManager**
    - [x] Design `BodyComponent` management (Flame wrapper for Body).
    - [x] Define `PolygonPart` management per Body.
    - [ ] Design logic for merging Fixtures or regenerating Bodies upon combination (handling `BodyComponent` lifecycle: remove old, add new).

## Components
- [x] **PolygonPart**
    - [x] Define data structure for a single polygon part.
    - [x] Design `Connector` holding mechanism.
    - [x] Define Fixture properties for Forge2D integration.

- [x] **Connector**
    - [x] Define data structure (position, type, orientation, state).
    - [ ] Design the "pair type" logic (must be a matching pair).
    - [ ] Define connection state management.

## Systems
- [x] **ConnectionSystem**
    - [x] Design the connector scanning algorithm (neighbor search).
    - [x] Implement Attraction Model (B):
        - [x] Calculate distance `d` (considering periodic boundary).
        - [x] Apply force `F(d)` (short-range strong, long-range weak).
    - [x] Implement Alignment Logic (A):
        - [x] Define conditions for connection (distance, angle).
        - [x] Design position correction (snap to exact match).
        - [x] Design angle correction.
        - [x] Design Body integration (merging fixtures and updating `BodyComponent`s).

- [x] **BreakSystem**
    - [x] Design detachment probability model (time-based).
    - [x] Implement detachment logic:
        - [x] Decompose Body into `PolygonPart`s.
        - [x] Regenerate Bodies (create new `BodyComponent`s).
    - [ ] Define event notification priority (Priority A).

- [x] **EventBus**
    - [x] Define event types: `ConnectionEvent`, `DetachmentEvent`.
    - [x] Design subscription mechanism for World, EntityManager, UI (using Dart Streams or ValueNotifiers).

## Space & Physics
- [x] **PeriodicBoundarySystem**
    - [x] Design coordinate mapping to torus space.
    - [ ] Implement shortest distance calculation considering boundaries.
    - [ ] Ensure attraction and connection logic uses boundary-aware distances.
    - [x] Implement `body.setTransform` logic for wrapping bodies at edges.

## UI / UX
- [x] **Camera Controls**
    - [x] Implement Zoom controls (Scroll/Pinch).
    - [x] Ensure fixed world size with zoomable view.
