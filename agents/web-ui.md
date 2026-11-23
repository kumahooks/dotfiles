---
description: Load Web UI specific skill
agent: build
---

# Web UI

## Hard Standard

Treat the browser as the platform.

- Start with semantic HTML.
- Use CSS for presentation, layout, responsive behavior, visibility, animation, and interaction states before JavaScript.
- Use JavaScript only for behavior HTML and CSS cannot express.
- Use native elements before ARIA or custom widgets.
- Follow WCAG 2.2 for accessibility.
- Follow WHATWG HTML, W3C specifications, and MDN for platform behavior.
- Follow progressive enhancement. Core content and forms should work without client-side JavaScript when the product allows it.
- Local project style wins when contributing to existing web UI.

The best web UI is portable markup, resilient CSS, and small behavior.

## HTML

- Use landmarks: `header`, `nav`, `main`, `section`, `article`, `aside`, and `footer`.
- Use headings in document order.
- Use real links for navigation and real buttons for actions.
- Use labels for every form control.
- Use native input types before custom controls.
- Keep tables for tabular data.
- Keep lists as lists.
- Put page state in the URL when it should survive refresh, sharing, back, and forward navigation.
- Prefer server-rendered HTML when data already lives on the server.
- Do not use `div` soup when an HTML element has the correct semantics.

## CSS

- Prefer CSS layout over JavaScript measurement and positioning.
- Use normal document flow before absolute positioning.
- Use Grid for two-dimensional layout and Flexbox for one-dimensional layout.
- Use container queries when component layout depends on available space.
- Use media queries for viewport, input, motion, color scheme, and contrast preferences.
- Use relative units for text and spacing where user settings should scale.
- Use logical properties for internationalization and writing modes.
- Use cascade layers or local conventions when specificity needs governance.
- Use transitions and animations only when motion improves comprehension.
- Respect `prefers-reduced-motion`.
- Avoid JavaScript for hover, focus, active, disabled, disclosure, and responsive layout states CSS can handle.

## JavaScript

- Keep JavaScript as behavior, not structure.
- Prefer small event handlers over app-wide state machines.
- Prefer declarative HTML attributes when using htmx, htmz, or Alpine.
- Avoid client-side routing unless the product needs application shell behavior.
- Avoid hydration when server-rendered HTML plus small behavior is enough.
- Do not recreate browser primitives: links, forms, validation, focus, scrolling, history, and navigation.
- Keep network behavior explicit.
- Use `AbortController` for cancelable requests.
- Do not ship a framework for one menu, modal, or form.

## Accessibility

- Follow WCAG 2.2.
- Follow WAI ARIA Authoring Practices only when native HTML cannot express the widget.
- Follow ARIA in HTML. No ARIA is better than incorrect ARIA.
- Keep visible focus states.
- Keep keyboard operation complete.
- Keep name, role, and value correct.
- Keep color contrast compliant.
- Do not rely on color alone.
- Do not trap focus except in modal interactions that manage restoration.
- Validate forms with accessible labels, instructions, errors, and summaries.
- Test with real keyboard navigation and at least one screen reader when changing interaction patterns.

## Usability

- Prefer obvious interaction over clever UI.
- Keep navigation, forms, dialogs, menus, and feedback consistent.
- Use platform conventions for inputs and controls.
- Make destructive actions explicit and reversible when possible.
- Show progress for operations that are not immediate.
- Keep errors specific and actionable.
- Preserve user input across validation failures.
- Keep layout stable while content loads.
- Avoid invisible gestures as the only path to an action.

## Portability

- Prefer Baseline features or verify support with compatibility data.
- Design for responsive widths, pointer types, keyboard, touch, reduced motion, color scheme, and zoom.
- Do not assume hover.
- Do not assume a precise viewport height.
- Do not depend on one browser engine.
- Avoid build steps unless they buy clear value.
- Keep pages usable with slow networks and partial asset failure.
- Use progressive enhancement for optional interactivity.
- Keep content readable when CSS or JavaScript fails.

## Frameworks

Use minimal frameworks when they reduce shipped JavaScript and keep HTML as the integration surface.

- htmx: server-driven interactions, partial HTML swaps, progressive enhancement, and small dynamic interfaces.
  - https://htmx.org/
  - https://htmx.org/docs/
- htmz: tiny iframe-based HTML navigation target pattern for minimal dynamic regions.
  - https://github.com/leanrada/htmz
- Alpine.js: small declarative behavior for local component state.
  - https://alpinejs.dev/
  - https://alpinejs.dev/start-here
- _hyperscript: event-oriented behavior language designed to pair with htmx. Use only when it improves local readability.
  - https://hyperscript.org/

Do not use React, Vue, Svelte, Angular, or a single page application framework by default. Use them when the product is an actual client application with sustained client-side state, offline behavior, complex composition, or a project standard that already depends on them.

## Pattern Libraries And References

Use these to avoid inventing interaction rules.

- WAI ARIA Authoring Practices: https://www.w3.org/WAI/ARIA/apg/
- WAI Forms Tutorial: https://www.w3.org/WAI/tutorials/forms/
- GOV.UK Design System: https://design-system.service.gov.uk/
- U.S. Web Design System: https://designsystem.digital.gov/
- Web.dev patterns: https://web.dev/patterns/

## Standards And Documentation

- WHATWG HTML Living Standard: https://html.spec.whatwg.org/
- MDN HTML elements reference: https://developer.mozilla.org/en-US/docs/Web/HTML/Element
- MDN CSS reference: https://developer.mozilla.org/en-US/docs/Web/CSS
- MDN CSS layout: https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/CSS_layout
- MDN responsive design: https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/CSS_layout/Responsive_Design
- WCAG 2.2: https://www.w3.org/TR/WCAG22/
- ARIA in HTML: https://www.w3.org/TR/html-aria/
- Web.dev Core Web Vitals: https://web.dev/articles/vitals
- Web.dev Baseline: https://web.dev/baseline
- Can I Use: https://caniuse.com/
- OWASP Cross Site Scripting Prevention Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html

## Review Checklist

- Does the HTML use the correct native element before adding ARIA or custom behavior?
- Does the page remain understandable without CSS and usable without optional JavaScript?
- Is CSS handling layout, responsiveness, state, and animation before JavaScript?
- Are links, buttons, forms, labels, headings, landmarks, and tables semantically correct?
- Is keyboard operation complete and visible?
- Are focus management, errors, and announcements correct for dynamic UI?
- Are motion, contrast, zoom, pointer type, and reduced motion preferences handled?
- Is browser support checked through Baseline, MDN compatibility data, or Can I Use?
- Is the shipped JavaScript proportional to the interaction?
- Is a minimal HTML-oriented framework enough before choosing a single page application framework?
