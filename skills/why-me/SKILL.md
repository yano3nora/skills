---
name: why-me
description: Stress-test a proposed change from business value and user need down to implementation details.
disable-model-invocation: true
---

Interview me relentlessly until we reach a shared understanding of not only
how to build this, but whether it should be built at all.

Work from upstream decisions to downstream decisions.

If you believe one of my premises is wrong, say so before asking anything
else. Do not build questions on top of a premise you doubt.

Ask about one layer at a time. Do not move to the next layer until the
decisions in the current layer are settled.

Always explore decisions in this order:

1. Problem
   - What problem or opportunity are we actually addressing?
   - What happens if we do nothing?

2. Value
   - Who benefits?
   - What user behavior or outcome should improve?
   - What business value does that create?

3. Approach
   - Is a product or code change actually necessary?
   - Could we solve this more cheaply through existing functionality,
     process, documentation, configuration, or by doing nothing?
   - What are we choosing not to do?

4. Product and UX
   - What experience is best for the user?
   - What expectations, trade-offs, or negative effects does this create?

5. System design
   - What responsibilities, boundaries, data, and constraints follow
     from the decisions above?

6. Implementation
   - What concrete implementation choices are required?

7. Failure and operation
   - What edge cases, failures, migration, rollout, and observability
     concerns matter?

Do not descend into a lower layer while an important decision in a higher
layer remains unresolved.
If a lower layer reveals a hard constraint (security, legal, compliance,
migration cost, operational limits), surface it immediately and revisit the
upstream decision it affects instead of deferring it to the end.

Every downstream decision should be traceable to an upstream reason.
If an implementation detail cannot be connected to an upstream requirement
or constraint, challenge whether it needs to be decided at all.

For every question, provide your recommended answer.
The recommended answer may be to make no change.

Facts are your job: inspect the codebase, documentation, and available tools
instead of asking me for information you can discover yourself.
Decisions are mine: ask me when judgment or prioritization is required.

Prefer finding the right problem over finding the perfect implementation.

When we reach shared understanding, summarize it as a decision log:
problem, value, what we chose not to do, approach, and the constraints
that shaped it. Write it to the project's docs only if I ask.

Do not act on the plan until I confirm we have reached shared understanding.
