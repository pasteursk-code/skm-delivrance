SKM DÉLIVRANCE V3 — INSTALLATION

1) CONTENU DU DOSSIER
- index.html : application utilisateur
- admin.html : back-office privé du Révérend Serge Kassi
- config.js : connexion à Supabase
- supabase.sql : création de la base et règles d'accès
- assets/rev-serge-kassi.jpg : photo officielle validée

2) GITHUB
Placez tous ces fichiers dans le dépôt skm-delivrance, à la racine, en conservant le dossier assets.
Le fichier principal doit s'appeler exactement index.html.

3) SUPABASE
Créez un projet Supabase.
Dans SQL Editor, collez puis exécutez supabase.sql.
Dans Project Settings > API, copiez :
- Project URL
- anon public key
Puis remplacez les deux valeurs dans config.js.

4) COMPTE ADMINISTRATEUR UNIQUE
Ouvrez admin.html sur votre site et demandez le lien de connexion avec VOTRE e-mail.
Après la première connexion, allez dans Supabase > Authentication > Users et copiez votre UUID.
Dans SQL Editor, exécutez :
insert into public.admin_profiles(user_id, display_name)
values ('VOTRE-UUID', 'Révérend Serge Kassi');

La base est conçue pour que les visiteurs puissent déposer un dossier, mais ne puissent jamais lire les dossiers.
Seul l'utilisateur présent dans admin_profiles peut les consulter et les modifier.

5) CONFIDENTIALITÉ
Ne placez jamais de mot de passe, service_role key, secret API key ou autre secret dans GitHub.
La clé anon Supabase peut être exposée côté navigateur à condition de conserver les règles RLS du fichier supabase.sql.

6) TEST
- Remplissez une fiche depuis index.html.
- Validez le consentement.
- Envoyez le dossier.
- Connectez-vous à admin.html avec votre compte administrateur.
- Vérifiez que le dossier apparaît dans le back-office.

7) RENDEZ-VOUS
Le patient/usager peut demander un rendez-vous depuis l'écran final.
La demande apparaît dans le back-office avec sa fiche.
