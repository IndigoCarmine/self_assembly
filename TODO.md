# Design TODO List

## Core Architecture
- [ ] **World (Forge2D)**
    - [ ] Design the main loop for physical updates (leveraging `Forge2DGame`).
    - [ ] Integrate `PeriodicBoundarySystem` for topological management.
    - [ ] Define injection mechanism for `ConnectionSystem` and `BreakSystem`.
    - [ ] Ensure attraction and detachment logic runs within the World update.

- [ ] **EntityManager**
    - [ ] Design `BodyComponent` management (Flame wrapper for Body).
    - [ ] Define `PolygonPart` management per Body.
    - [ ] Design logic for merging Fixtures or regenerating Bodies upon combination (handling `BodyComponent` lifecycle: remove old, add new).

## Components
- [ ] **PolygonPart**
    - [ ] Define data structure for a single polygon part.
    - [ ] Design `Connector` holding mechanism.
    - [ ] Define Fixture properties for Forge2D integration.

- [ ] **Connector**
    - [ ] Define data structure (position, type, orientation, state).
    - [ ] Design the "pair type" logic (must be a matching pair).
    - [ ] Define connection state management.

## Systems
- [ ] **ConnectionSystem**
    - [ ] Design the connector scanning algorithm (neighbor search).
    - [ ] Implement Attraction Model (B):
        - [ ] Calculate distance `d` (considering periodic boundary).
        - [ ] Apply force `F(d)` (short-range strong, long-range weak).
    - [ ] Implement Alignment Logic (A):
        - [ ] Define conditions for connection (distance, angle).
        - [ ] Design position correction (snap to exact match).
        - [ ] Design angle correction.
        - [ ] Design Body integration (merging fixtures and updating `BodyComponent`s).

- [ ] **BreakSystem**
    - [ ] Design detachment probability model (time-based).
    - [ ] Implement detachment logic:
        - [ ] Decompose Body into `PolygonPart`s.
        - [ ] Regenerate Bodies (create new `BodyComponent`s).
    - [ ] Define event notification priority (Priority A).

- [ ] **EventBus**
    - [ ] Define event types: `ConnectionEvent`, `DetachmentEvent`.
    - [ ] Design subscription mechanism for World, EntityManager, UI (using Dart Streams or ValueNotifiers).

## Space & Physics
- [ ] **PeriodicBoundarySystem**
    - [ ] Design coordinate mapping to torus space.
    - [ ] Implement shortest distance calculation considering boundaries.
    - [ ] Ensure attraction and connection logic uses boundary-aware distances.
    - [ ] Implement `body.setTransform` logic for wrapping bodies at edges.
