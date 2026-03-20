# Changelog

## 1.1.0

### New Algorithms
- **BFS (Breadth-First Search)** — queue-based, guarantees shortest path
- **DFS (Depth-First Search)** — stack-based, explores deeply before backtracking
- **Greedy Best-First Search** — heuristic-only, fast but not always optimal
- **Bidirectional BFS** — searches from both start and end simultaneously

### UI/UX Redesign
- Replaced stacked FABs with a clean bottom toolbar using tool chips
- Added collapsible algorithm info panel explaining how each algorithm works with shortest-path guarantee indicators
- Added color legend bar for grid cell states
- Added dark theme support
- Removed debug banner

### Street Map Rendering
- Walls render as 3D buildings with drop shadows and isometric depth
- Empty cells appear as warm-toned road surface with subtle lane markings
- Path renders as a connected asphalt road with yellow dashed center line
- Start/End displayed as circular map pins with shadows
- Visited cells shown as translucent overlay on roads

### Performance
- Replaced 625 individual widgets with a single CustomPaint for the entire grid
- Grid state stored as plain list instead of per-cell ValueNotifiers
- Algorithm animation batches multiple cell updates per frame
- Grid increased to 50x50 (2500 cells) while maintaining smooth performance

### Interaction Improvements
- Clear button immediately stops any running animation
- Speed slider adjusts animation in real-time (changes take effect mid-animation)
- Speed range widened to 0ms–500ms (instant to very slow)
- Single taps now place blocks (not just drag)
- Drawing blocked during algorithm animation

### Tests
- Added 42 unit tests covering all 6 algorithms (A*, Dijkstra, BFS, DFS, Greedy Best-First, Bidirectional BFS)
- Tests cover path finding, wall avoidance, blocked grids, adjacency, and edge cases
