# Meta-Prompt: Landing Page metrikia.io/integrations/ai

> Utilise ce prompt dans le contexte du codebase metrikia.io pour generer la page.

---

## Prompt

Cree une landing page a l'URL `/integrations/ai` pour metrikia.io. Cette page presente l'approche AI-First de Metrikia et son ecosysteme MCP + plugin Claude Code.

### Contexte produit

Metrikia est une plateforme SaaS qui correle les investissements publicitaires (Meta Ads, Google Ads, TikTok Ads) avec les donnees CRM pour calculer le vrai ROI. Elle propose :
- Attribution multi-touch (9 modeles dont Shapley et Markov)
- Suivi du pipeline de leads (du clic pub au deal signe)
- Analyse creative (fatigue, winners/losers, scaling)
- Diana AI — assistante IA strategique integree
- Observabilite temps reel des campagnes

Documentation publique du MCP Server : https://api.metrikia.io/public/api/v1/docs?ui=redoc#section/+MCP-Server

### Positionnement AI-First

Metrikia ne se contente pas d'afficher des dashboards. L'approche AI-First signifie que l'IA est le mode d'interaction principal :
- Pas besoin de naviguer dans des menus : pose ta question, obtiens la reponse
- Le MCP server expose 17 outils directement dans ton assistant IA (Claude Code, Cursor, etc.)
- Les skills pre-construits guident l'IA pour des analyses complexes (audit de campagne, optimisation budget, attribution)
- Les agents specialises (Media Buyer, Growth Analyst) apportent l'expertise metier

Le message cle : "Tes donnees pub, accessibles par l'IA. Sans quitter ton workflow."

### Audience cible

1. **Media Buyers** — gerent des campagnes sur Meta/Google/TikTok, veulent optimiser ROAS et budget
2. **Creative Strategists** — analysent la performance des creatives, detectent la fatigue
3. **Growth Analysts / Performance Managers** — suivent le funnel complet, de la pub au revenu
4. **Agences publicitaires** — gerent plusieurs comptes clients, besoin de reporting automatise
5. **Developpeurs / Tech Leads** — integrent Metrikia dans leurs workflows IA

### Structure de la page

#### Hero Section
- Titre : accroche AI-First (ex: "Tes donnees pub. L'IA comme interface.")
- Sous-titre : explication en 1 phrase du MCP server + plugin
- CTA principal : "Installer le plugin Claude Code" (lien vers le repo GitHub)
- CTA secondaire : "Voir la documentation MCP" (lien : https://api.metrikia.io/public/api/v1/docs?ui=redoc#section/+MCP-Server)
- Visual : illustration ou schema montrant Claude Code <-> MCP Server <-> Metrikia Data

#### Section "Pourquoi AI-First ?"
3 colonnes ou cards :
1. **Conversationnel** — Pose une question en langage naturel, obtiens des insights actionnables. Pas de navigation dans des menus.
2. **Contextuel** — L'IA comprend ton historique de campagnes, tes leads, ton attribution. Elle repond avec TES donnees.
3. **Actionnable** — Pas juste des metriques : des recommandations concretes avec le "pourquoi" et le "combien".

#### Section "MCP Server — 17 outils"
Presenter les 4 categories d'outils avec icones :

**Campagnes & Performance** (4 outils)
- `list_campaigns` — Lister toutes les campagnes avec filtres (plateforme, statut, periode)
- `get_campaign_performance` — Metriques detaillees d'une campagne (spend, impressions, clicks, conversions, ROAS)
- `get_creative_report` — Performance par creative avec detection de fatigue
- `compare_performance` — Comparaison periode precedente ou benchmark

**Leads & CRM** (3 outils)
- `list_leads` — Pipeline de leads avec source d'attribution
- `get_lead` — Detail complet d'un lead avec son parcours
- `list_deals` — Deals CRM avec montant et statut

**Attribution & Insights** (3 outils)
- `get_attribution_journey` — Parcours multi-touch complet (9 modeles d'attribution)
- `get_budget_advice` — Recommandations d'allocation budget basees sur les donnees
- `get_anomalies` — Detection automatique d'anomalies dans les performances

**Metriques & IA** (3 outils)
- `get_metrics` — Metriques agregees (MER, ROAS, CPA, CPL, LTV)
- `get_sync_status` — Etat de synchronisation des sources de donnees
- `ask_diana` — Diana AI pour des questions strategiques en langage naturel

**Operations** (4 outils)
- `create_lead`, `transition_lead`, `create_deal`, `trigger_sync`

Pour le detail technique complet de chaque outil, renvoyer vers : https://api.metrikia.io/public/api/v1/docs?ui=redoc#section/+MCP-Server

#### Section "Plugin Claude Code"
Presenter les 6 skills comme des workflows pre-construits :

| Skill | Ce qu'il fait |
|-------|---------------|
| Weekly Report | Rapport hebdo complet : MER, ROAS, anomalies, tendances, recommandations Diana |
| Campaign Audit | Audit profond d'une campagne : creatives, attribution, budget, red flags |
| Lead Pipeline | Sante du pipeline : taux de conversion, qualite des leads par source |
| Budget Optimizer | Reallocation optimale du budget basee sur l'attribution multi-touch |
| Creative Analysis | Winners, losers, fatigue, opportunites de scaling |
| Attribution Deep Dive | Analyse multi-touch avec cartographie des parcours et valeur reelle par canal |

Mentionner les 2 agents specialises :
- **Media Buyer** — Expert en optimisation de campagnes, allocation budget, strategies de scaling
- **Growth Analyst** — Expert en attribution, pipeline, correlation revenus

#### Section "Comment ca marche"
3 etapes visuelles :
1. **Connecte** — Installe le plugin, configure ta cle API. 30 secondes.
2. **Demande** — Pose ta question a Claude : "Montre-moi la performance de mes campagnes Meta cette semaine"
3. **Agis** — Obtiens des insights actionnables avec les donnees reelles de ton compte Metrikia

#### Section "Securite & Compliance"
Points cles en bullet points :
- Cle API scopee (read-only par defaut, write optionnel)
- Multi-tenant : isolation stricte des donnees par compte
- Pas de PII expose (emails, telephones masques — uniquement UUIDs et noms)
- Rate limiting (60 req/min lecture, 30 req/min ecriture)
- HTTPS only, Bearer token authentication
- Conforme RGPD

#### Section "Getting Started" (CTA final)
Code block d'installation :
```bash
# 1. Clone le plugin
git clone https://github.com/BULDEE/metrikia-claude-plugin.git

# 2. Configure ta cle API
export METRIKIA_API_KEY="mk_live_your_key_here"

# 3. Lance Claude Code avec le plugin
claude --plugin-dir ./metrikia-claude-plugin
```

Lien vers la generation de cle API : `https://app.metrikia.io/app/settings?group=advanced&section=api-webhooks`

CTA : "Creer ma cle API" + "Voir la documentation MCP complete"

#### Footer Section
- Lien vers la doc MCP : `https://api.metrikia.io/public/api/v1/docs?ui=redoc#section/+MCP-Server`
- Lien vers la doc API complete : `https://api.metrikia.io/public/api/v1/docs?ui=redoc`
- Lien vers le repo plugin : `https://github.com/BULDEE/metrikia-claude-plugin`
- Lien vers le support : `support@metrikia.io`

### Directives de design

- S'integrer dans le design system existant de metrikia.io
- Ton professionnel mais accessible — pas de jargon inutile
- Privilegier les visuels : schemas d'architecture, icones par categorie d'outils, code snippets
- Mobile-first responsive
- Dark mode si le site le supporte
- Animations subtiles au scroll (apparition progressive des sections)

### SEO

- Title : "Metrikia AI Integration — MCP Server & Claude Code Plugin"
- Meta description : "Connect your AI assistant to Metrikia. Access campaign performance, CRM leads, multi-touch attribution, and budget optimization through 17 MCP tools. Plugin Claude Code included."
- H1 : le titre hero
- Structured data : SoftwareApplication schema pour le plugin

### Contraintes

- La page doit etre autonome (pas de dependance a un etat authentifie)
- Tous les liens externes doivent ouvrir dans un nouvel onglet
- Les code blocks doivent avoir un bouton "copy"
- Le getting started doit fonctionner tel quel (pas de placeholder ambigu)
