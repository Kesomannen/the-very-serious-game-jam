# Game Design Document

## Working Title

**Viewer Discretion Advised**

## High Concept

A short 3D comedy game where parents sit outside a schoolyard fence during recess, secretly betting on children playing manhunt. The player is one of these parents. They scout the game with binoculars, place a bet, buy an absurd contraband snack, then sprint from the bench and vault the fence to interfere with the match.

The core joke is that normal recess is being treated like a professional underground sport by wildly over-invested parents.

## One-Sentence Pitch

Bet on a kid playing schoolyard manhunt, then vault the fence and sabotage recess when your odds go bad.

## Target Scope

This design is scoped for a 7-day jam with two programmers.

The goal is not to build a deep simulation. The goal is to build one funny, readable, repeatable round that creates chaotic stories.

## Genre

3D third-person comedy chase game with light betting and AI simulation.

## Core Fantasy

The player is a parent on a bench outside the school fence, watching recess through binoculars like a sports scout. Once the bet is placed, they break onto school property, chase down kids, and apply ridiculous status-effect items to push the match toward their chosen outcome.

The fence vault is the signature moment. It should feel like the player is launching a tactical operation over something that should obviously not be crossed.

## Theme Fit

The jam theme is **Spin It To Win It**.

The game fits through:
- Betting on a volatile outcome.
- Trying to "spin" a bad bet into a winning one through interference.
- Optional playground spinner/roundabout as a simple arena feature if time allows.

The theme does not require a literal roulette system for MVP.

## Core Pillars

### 1. Readable Recess Chaos

Eight kids play manhunt while the player tries to understand who is winning, who is in danger, and who needs interference.

### 2. Fence-Vault Interference

The player starts outside the fence. To affect the game, they must physically sprint in, vault the fence, catch a target, and use an item.

### 3. Simple Betting Pressure

The player has a bankroll, places one main bet before each round, and wins or loses based on the final kid standing.

### 4. Fake Contraband, Big Effects

Items are silly playground snacks and objects with obvious status effects. They should be funny, visual, and easy to understand.

## Core Loop

1. **Scout**
   - Player stands at the parent bench outside the fence.
   - Binocular view shows kids, names, simple stats, and odds.

2. **Bet**
   - Player chooses one kid to win.
   - Player chooses a bet amount.

3. **Buy One Item**
   - Player buys/selects one interference item for the round.
   - Keeping this to one item preserves scope and makes the decision clear.

4. **Recess Starts**
   - Kids play manhunt.
   - Player watches the match begin from outside the fence.

5. **Vault and Interfere**
   - Player sprints from the bench.
   - Player vaults the fence.
   - Player chases a kid and applies the item at close range.

6. **Resolve**
   - Last untagged kid wins.
   - Bet pays out or fails.
   - Player returns to the bench for the next round.

## MVP Round Rules

Use a simple elimination-style manhunt:

- 8 kids start on the playground.
- 1 kid starts as **It**.
- Runners avoid hunters.
- When tagged, a runner becomes a hunter.
- The last remaining runner wins.

This naturally escalates without needing complex objectives.

## Player

The player is a parent.

Required actions:
- Move.
- Sprint.
- Vault fence.
- Chase kids.
- Apply selected item.
- Open binocular/betting view before the round.

The player should be a little slower and clumsier than the fastest kids, so catching the right target takes planning.

## Fence Vault

This is required for MVP.

Implementation:
- A fence trigger sits between the parent bench and playground.
- When the player sprints into it or presses interact near it, control is briefly locked.
- A vault animation or placeholder arc plays.
- The player lands inside the playground and regains control.

Important details:
- The vault should be fast.
- It should have a strong sound effect.
- It should be visually obvious and funny.
- Returning over the fence can be automatic after the round, not a full mechanic.

## Kids

Eight kids should feel different through stats, color, name labels, and simple behavior weighting.

Recommended stats:
- **Speed**: top movement speed.
- **Stamina**: how long they can sprint.
- **Agility**: turning and route handling.
- **Boldness**: willingness to use risky playground triggers.
- **Focus**: resistance to confusion effects.

Example roster:

### Mia "The Missile"
- Fast, low stamina.
- Strong early, weaker late.

### Jayden "No Brakes"
- Fast and bold.
- Takes risky routes.

### Priya "Spreadsheet"
- High focus.
- Reliable and cautious.

### Max "Shortcut"
- Good agility.
- Uses playground triggers often.

### Sam "Ghost Mode"
- Good awareness.
- Avoids crowds.

### Ava "Captain Chaos"
- High boldness.
- Makes unpredictable route choices.

### Leo "Moon Shoes"
- Good jump/vertical route preference.
- Vulnerable in open space.

### Noor "The Wall"
- High stamina.
- Strong late-round hunter.

## Betting

Keep betting simple.

Before each round:
- Show each kid's name.
- Show simple stats.
- Show payout odds.
- Let the player bet on one winner.
- Let the player choose a bet amount.

At round end:
- If the chosen kid wins, pay out based on odds.
- Otherwise, subtract the bet.

No live odds, side bets, or complex betting markets for the jam version.

## Items

For MVP, include 4 items total.

Items should be fictional and cartoonish. Avoid realistic drug presentation. The parents are the joke, and the items should feel like absurd schoolyard contraband.

### Turbo Juicebox
- Buff.
- Temporarily increases speed.
- Slightly reduces turning control.
- Best for helping a runner escape or making a hunter dangerous.

### Nap-Time Syrup
- Debuff.
- Temporarily reduces speed and reaction time.
- Best for sabotaging a rival runner.

### Moon Shoes
- Buff.
- Temporarily increases jump strength and makes playground triggers more effective.
- Best near play structures.

### Overthinking Granola
- Debuff.
- Temporarily increases hesitation.
- Target briefly changes direction or pauses before choosing a route.

## Item Application

The player must reach a kid to use the item.

MVP interaction:
- Player has one selected item.
- When close to a kid, an interact prompt appears.
- Press/hold interact to apply the item.
- The kid gets a visible status icon, color flash, or particle effect.
- The item is consumed.

Only one item per round is enough for the jam version.

## Playground Arena

One compact school playground.

Required areas:
- Parent bench outside the fence.
- Fence separating parents from playground.
- Open play area for chases.
- Small central play structure.
- Slide or ramp.
- A few obstacles for pathing and line-of-sight breaks.

Optional if time allows:
- Roundabout/spinner.
- Tunnel.
- Second fence entry point.

The arena should be small enough that the player can always understand the match.

## Play Structure Implementation

Playground structures should use **scripted traversal triggers**, not complex 3D AI navigation.

The idea:
- AI handles normal movement on the ground.
- Invisible trigger volumes sit at stairs, slides, ramps, jumps, and other special features.
- When a kid or player enters a trigger, normal movement/AI is temporarily disabled.
- A short scripted motion plays.
- Control returns at the exit point.

Examples:

### Step/Platform Trigger
- Actor enters invisible trigger at the base of stairs/platform.
- AI movement pauses.
- Actor keeps forward momentum or follows a short arc.
- Jump/climb animation plays.
- Actor lands on the platform.
- AI resumes.

### Slide Trigger
- Actor enters top of slide.
- AI movement pauses.
- Actor follows slide path to bottom.
- Slide animation/sound plays.
- AI resumes at bottom.

### Spinner Trigger
- Actor touches roundabout.
- Actor is briefly rotated/launched or redirected.
- AI resumes after a short cooldown.

Required safeguards:
- Each actor gets a short cooldown after using a traversal trigger.
- Triggers should have clear entry and exit points.
- Triggers should never require the AI to reason about exact geometry.

This is the main trick that makes playground movement achievable in a week.

## Kid AI

Keep AI simple but expressive.

### Runner AI

Runners should:
- Move away from the nearest hunter.
- Prefer open space when safe.
- Use nearby traversal triggers based on boldness.
- Recover stamina when not threatened.

### Hunter AI

Hunters should:
- Chase the nearest or easiest runner.
- Tag on contact.
- Use traversal triggers when they are already on the path.

### States

Recommended minimum states:
- `Wander`
- `Flee`
- `Chase`
- `UseTraversal`
- `Tagged`

Avoid advanced behaviors for the jam:
- No pump fakes.
- No team strategy.
- No learning.
- No complex hiding.
- No route prediction beyond basic pathfinding.

## Controls

Keyboard/mouse:
- WASD: Move.
- Mouse: Camera.
- Shift: Sprint.
- Space or E near fence: Vault.
- E near child: Apply item.
- Right mouse or Tab before round: Binocular/betting view.

Gamepad can be added only if time allows.

## Camera

Third-person camera behind the parent.

Needs:
- Clear chase visibility.
- Smooth enough for sprinting.
- Works around fence and play structure.
- Optional zoom/binocular mode from the bench.

## UI

MVP UI:
- Bankroll.
- Current bet.
- Selected kid.
- Selected item.
- Remaining runners.
- Simple name/status markers over kids.
- Betting/binocular panel before the round.

Do not build:
- Live odds UI.
- Side bet UI.
- Large inventory.
- Complex stat comparison screens.

## Art Direction

Bright, stylized schoolyard comedy.

Key visuals:
- Parents on a bench outside the fence.
- Binocular scouting.
- Fence vault.
- Kids with strong colors/name labels.
- Fake snack-based items.

The parents should look comically serious. The kids should look like colorful, readable game pieces, not realistic children.

## Audio Direction

Prioritize clear feedback:
- School bell.
- Whistle.
- Fence vault thump/rattle.
- Binocular zoom sound.
- Cash/register bet sound.
- Tag sound.
- Item activation sounds.
- Slide/playground squeaks.

## Godot Implementation Notes

Project target: **Godot 4.6 with Jolt Physics**.

Recommended scripts/systems:
- `GameManager`: round state, start/end flow.
- `BettingManager`: bankroll, odds, wager, payout.
- `KidAgent`: stats, AI state, role, status effects.
- `ParentPlayer`: movement, sprint, vault, item use.
- `ItemManager`: selected item and application effects.
- `TraversalTrigger`: scripted playground movement zones.
- `TagManager`: hunter/runner tracking and winner detection.

AI approach:
- Use `NavigationAgent3D` for ground movement.
- Use `TraversalTrigger` for stairs, slides, jumps, platforms, and spinner behavior.
- Keep kid personalities as simple stat multipliers and trigger-use weights.

Status effects:
- Store timed modifiers on `KidAgent`.
- Effects should be obvious visually.
- Do not stack many effects in MVP.

## MVP Checklist

Must have:

1. One schoolyard scene with bench, fence, and playground.
2. Parent player movement.
3. Fence vault.
4. 8 kid agents.
5. Manhunt rules.
6. Basic runner/hunter AI.
7. Tagging and last-runner win condition.
8. Pre-round binocular/betting screen.
9. Bankroll and payout.
10. One item choice per round.
11. Four item effects.
12. Close-range item application.
13. At least one traversal trigger, preferably slide or platform.
14. Round restart.

Nice to have:
- More traversal triggers.
- Better animations.
- Sound effects.
- Kid personality names and color coding.
- Roundabout/spinner tie-in.

Cut for jam:
- Live odds.
- Side bets.
- Rival parent AI.
- Teacher/security system.
- Multiplayer.
- Complex inventory.
- Pump fakes.
- Advanced parkour.
- Dynamic commentary.
- Multiple arenas.

## Two-Programmer Split

### Programmer 1: Simulation
- Kid AI.
- Tagging rules.
- Round state.
- Navigation setup.
- Traversal triggers.

### Programmer 2: Player and Game Loop
- Parent controller.
- Fence vault.
- Betting/binocular UI.
- Item system.
- Bankroll and round restart.

Both programmers should collaborate on scene blockout early so AI, traversal, and player movement are tested in the same arena.

## 7-Day Plan

### Day 1: Greybox
- Build schoolyard blockout.
- Add bench, fence, open area, simple play structure.
- Implement parent movement.
- Implement 8 placeholder kids moving around.

### Day 2: Manhunt
- Add hunter/runner roles.
- Add chase/flee behavior.
- Add tagging.
- Add round win condition.

### Day 3: Fence and Betting
- Add binocular/betting screen.
- Add bankroll and payouts.
- Add fence vault.
- Make round flow playable from bench to playground to result.

### Day 4: Items
- Add one-item-per-round selection.
- Implement four item effects.
- Add close-range application.
- Add status feedback.

### Day 5: Traversal
- Add traversal trigger base class.
- Add slide/platform trigger.
- Make kids and player use it reliably.
- Tune cooldowns and failure cases.

### Day 6: Polish and Balance
- Tune kid stats.
- Tune item strengths.
- Add sound effects.
- Improve UI readability.
- Add simple animations/placeholders.

### Day 7: Submit
- Fix bugs.
- Add menu/restart.
- Add tutorial prompts if needed.
- Export build.
- Record a short clip/gif.

## Biggest Risks

### AI Gets Stuck

Mitigation:
- Keep arena simple.
- Use obvious open spaces.
- Add failsafe teleport/reset if a kid is stuck for too long.

### Traversal Triggers Loop

Mitigation:
- Add per-actor cooldowns.
- Use clear entry and exit points.
- Disable re-entry briefly after exit.

### Player Cannot Read the Match

Mitigation:
- Use name labels.
- Use hunter/runner colors.
- Show remaining runners.
- Keep the playground compact.

### Scope Creep

Mitigation:
- Only one item per round.
- Only one main bet.
- No advanced AI until the base game is fun.

## Design North Star

Every round should produce a sentence the player wants to say out loud:

"I bet on Ava, bought a Turbo Juicebox, vaulted the school fence, missed her by the slide, accidentally boosted Max, and then Noor won because everyone chased the wrong kid."

If moments like that happen, the game is working.
