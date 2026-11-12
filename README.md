# Virginia Early Termination Tool

A bilingual (English and Spanish) web tool from REFORM Alliance that helps people on probation in Virginia understand whether their probation officer is legally required to file for early termination, or whether they must ask the court themselves. It applies only to probation, not parole. The repo is named `va-implementation-tool`; the tool's title is "Virginia Early Termination Tool".

**Live app:** <https://www.reformvaearlyterminationtool.com/>

Part of REFORM Alliance's early termination tools: [Georgia](https://github.com/REFORM-Alliance/georgia-early-termination-tool) · [Florida](https://github.com/REFORM-Alliance/florida-early-termination-tool) · [Illinois](https://github.com/REFORM-Alliance/illinois-early-termination-tool) · **Virginia** · [Pennsylvania Act 44](https://github.com/REFORM-Alliance/act-44-flow-chart-app).

## What it tells people

- **Ask the court:** no automatic process. The person may file a motion at any time under Va. Code 19.2-304.
- **Officer must file:** the probation officer is legally required to file. If restitution is still owed the court must hold a hearing; otherwise the judge may grant with or without one.
- **Resource page:** a "click here" link on the second question screen explains how to reach a probation officer.

## How the flow works

The tool is a scripted question-and-answer flow. A person answers one screen at a time, their answers choose the next screen, and a result screen says what they can do. Screens are numbered in the order a person meets them; each screen's code ID is its `question_id` in `app.R` (listed below the diagram).

```mermaid
flowchart TD
  S1["S1 Welcome"]
  S2["S2 3 questions on sentence and supervision"]
  S3["S3 3 questions on compliance"]
  S4["S4 Convicted of a listed offense?"]
  S5["S5 Restitution still owed?"]
  S6(["S6 Result: ask the court"])
  S7(["S7 Result: officer must file, hearing required"])
  S8(["S8 Result: officer must file"])
  S9["S9 How to reach your officer"]
  S1 --> S2
  S2 -->|"Any Yes"| S3
  S2 -->|"All No"| S6
  S3 -->|"Any Yes"| S4
  S3 -->|"All No"| S6
  S4 -->|"Yes"| S6
  S4 -->|"No"| S5
  S5 -->|"Yes"| S7
  S5 -->|"No"| S8
  S3 -.->|"click here link"| S9
  classDef result fill:#eef6ee,stroke:#3d7a3d
  class S6,S7,S8 result
```

Rounded boxes are result screens. The dotted line is a link, not an answer. Result screens end at the thank-you page (S10) through the Finish button, not drawn. "Any Yes" and "All No" describe how the code combines the three answers on S2 and S3.

<details>
<summary>Screen numbers and code IDs</summary>

| Screen | `question_id` |
| --- | --- |
| S1 | `intro_page` |
| S2 | `initial_questions` |
| S3 | `eligibility_questions` |
| S4 | `nature_of_sentence` |
| S5 | `restitution_question` |
| S6 | `first_early_term_result` |
| S7 | `second_early_term_result` |
| S8 | `third_early_term_result` |
| S9 | `resource_question` |
| S10 | `finished_page` |

</details>

## Repository layout

| File or folder | What it is |
| --- | --- |
| `app.R` | The whole app: packages, the `decision_tree` list (every screen and its routing), page layout and server logic. |
| `json/translation.json` | English-to-Spanish text pairs. The English text is the lookup key. |
| `www/reform-logo-charcoal.png` | The logo at the top of the page. Shiny serves everything in `www/` as-is. |
| `renv.lock`, `renv/`, `.Rprofile` | Pinned package versions. `.Rprofile` switches renv on when the project opens. |
| `manifest.json` | The R version and package list that Posit Connect Cloud builds the app from. Regenerate it with `rsconnect::writeManifest()` after any package change. |
| `va-implementation-tool.Rproj` | The RStudio project file. The app finds `json/translation.json` relative to it. |
| `json/translations.csv` | A CSV copy of the Spanish translations (columns `english`, `spanish`). The app reads `json/translation.json`. |

The pinned versions are R 4.5.0 with the packages in `renv.lock`. The app loads `shiny`, `tidyverse`, `shinythemes`, `shinyWidgets`, `shinyjs`, `shinyalert`, `shiny.i18n`, `lubridate`, `scales`, `here`, `rsconnect` and `googleLanguageR`. The last two are loaded but never called, so no Google or hosting credentials are needed to run it.

## Run it locally

1. Install R 4.5.0 and the RStudio desktop app.
2. Clone or download this repo and double-click `va-implementation-tool.Rproj`. RStudio opens the project and renv switches on by itself.
3. In the R console, run `renv::restore()` once. It installs the pinned package versions.
4. Open `app.R` and click **Run App**, or run `shiny::runApp()` in the console.
5. Switch the language picker to Spanish and click through every route you changed.

## Edit wording, questions and Spanish

- Each screen is one block in the `decision_tree` list at the top of `app.R`: `question_id` (its name), `question` or `result` (the text), `choices` (the answer buttons) and `next_question` (where each answer leads).
- After changing any English text, make the matching change to the `"en"` value in `json/translation.json` and rewrite its `"es"` value. Matching is exact, including punctuation and curly quotes, and text is translated in pieces around links and bold words. A miss shows that piece in English and logs a warning.
- Screen names must be unique and every name in `next_question` must exist, or Next does nothing. Keep the first screen as the welcome screen.
- Link to a statute with `tags$a(href='URL', target='_blank', class='external-link', "text")`. The `external-link` class triggers the "Leaving Application" confirmation.
- English and Spanish are written into the picker and the answer-lookup code in several places, so a third language needs code changes as well as a new column.

## Publish

This tool is hosted on [Posit Connect Cloud](https://connect.posit.cloud). The live app is at <https://www.reformvaearlyterminationtool.com/>. Connect Cloud copies the code from the GitHub repository and builds the app itself, so publishing an update means getting the change onto the GitHub branch that Connect Cloud follows (normally `main`; **Settings > Source** in Connect Cloud shows which). Nothing is uploaded from your computer. Connect Cloud addresses have the form `https://<account>-<custom name>.share.connect.posit.cloud`. The early termination tools' addresses of that form begin with `bfs6`, the name of the Connect Cloud account that owns them.

**Custom domain.** This tool is reached at its own domain rather than a `share.connect.posit.cloud` address. Connect Cloud can map a domain you own to published content (Enhanced, Advanced and Enterprise plans): the domain is added under **Admin > Domains**, two CNAME records are added at the domain registrar, and the domain is then chosen on the content's **URL** setting. This repo does not record how the domain was set up, so note who holds the domain registration and its DNS records.

### Publish an update

1. Make and test the change on your computer (see **Run it locally**).
2. If you added or upgraded an R package, run `renv::snapshot()` and then `rsconnect::writeManifest()` in the R console, and commit both `renv.lock` and `manifest.json`. Connect Cloud reads `manifest.json` for the package list, so a stale one gives the live app the wrong packages or fails the build.
3. Commit and push to `main` (RStudio's Git tab, GitHub Desktop or the command line all work), or merge a pull request into it. "Automatically publish on push" is on by default, so Connect Cloud rebuilds and redeploys the app. The address does not change.
4. Open the live address, switch the language picker to Spanish and click through the routes you changed.
5. If the live app did not change, sign in to Connect Cloud, open the app's card on your Home page and look at the publish log for an error. **Republish** on the card redeploys from the latest code on GitHub.

### Publish for the first time, or re-create the app

1. In the project folder, run `rsconnect::writeManifest()` in the R console. Commit and push `app.R`, `manifest.json`, `json/` and `www/`.
2. Sign in to [Connect Cloud](https://connect.posit.cloud) with the account that owns this app.
3. Click **Publish** at the top of your Home page. The first time, Connect Cloud asks you to install its GitHub App; give it access to this repository. A repo owned by the REFORM-Alliance organization may need an organization owner to approve the app.
4. Choose **Shiny**, then select this repository.
5. Confirm the **Branch** is `main` and the **Primary file** is `app.R`. Leave **Automatically publish on push** on.
6. Click **Publish** and watch the build log. When it finishes, the app is live at an address like `https://<content id>.share.connect.posit.cloud`.
7. Open the app's **Settings > URL** and choose the custom domain (it must already be added and verified under **Admin > Domains**; see **Custom domain** above).
8. Open the address in a private browser window to check that someone who is not signed in to Connect Cloud can use it.

### If something goes wrong

- **The repository is missing from the Publish list.** Connect Cloud's GitHub App does not have access to it. Give the app access in GitHub, then reload the list. Automatic publishing also only works for repositories the app can reach.
- **Free accounts can publish only public repositories.** If this repository is ever made private, the Connect Cloud account needs a paid plan.
- **The build fails after a package change.** Run `rsconnect::writeManifest()` again, commit `manifest.json` and push.
- **No secrets to set.** `app.R` reads no environment variables, so nothing is needed under Advanced settings.

## Known issues

Found by reading the code; the app was not run. Confirm each before changing anything.

- On S2 and S3 one "Yes" is enough to continue, and only an all-No answer reaches S6. The questions are conditions to meet, so a person who meets only one can be told their officer is legally required to file. Confirm whether every condition must be met; if so the answer-combining rule should require all Yes.
- S4 cites object sexual penetration as 18.2-67.1(A)(1) and links to the forcible sodomy section; the Code of Virginia lists that offense at 18.2-67.2.
- Typo in user-facing text: "pont" (S8). It is also a key in `json/translation.json`; fix both.
- The VADOC phone number and the officer email format on S9 are typed into the app and will not update themselves.
- `manifest.json` is out of step with `renv.lock`: five packages have different versions (Rcpp 1.1.1-1.1 against 1.1.2, httr2 1.2.3 against 1.3.0, rlang 1.2.0 against 1.3.0, rsconnect 1.10.0 against 1.10.1, xfun 0.59 against 0.60). Connect Cloud reads `manifest.json`, so the live app should be using the manifest's versions, not the lock file's. After the next `renv::snapshot()`, run `rsconnect::writeManifest()` and commit both files.

## Keep the sibling repos in step

The five early termination tools copy the same engine rather than sharing a package. A fix to how the app behaves, as opposed to what it says, should be repeated in the other repos.

| Tool | Repository | Live app |
| --- | --- | --- |
| Georgia | [georgia-early-termination-tool](https://github.com/REFORM-Alliance/georgia-early-termination-tool) | <https://bfs6-georgia-early-termination-tool.share.connect.posit.cloud/> |
| Florida | [florida-early-termination-tool](https://github.com/REFORM-Alliance/florida-early-termination-tool) | <https://bfs6-florida-early-termination-tool.share.connect.posit.cloud/> |
| Illinois | [illinois-early-termination-tool](https://github.com/REFORM-Alliance/illinois-early-termination-tool) | not recorded yet |
| Virginia | [va-implementation-tool](https://github.com/REFORM-Alliance/va-implementation-tool) | <https://www.reformvaearlyterminationtool.com/> |
| Pennsylvania Act 44 | [act-44-flow-chart-app](https://github.com/REFORM-Alliance/act-44-flow-chart-app) | <https://bfs6-act-44-early-termination-tool.share.connect.posit.cloud/> |