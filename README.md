# Redmine Email Ticket Plugin

Redmine plugin, amely az e-mailből létrehozott ticketekhez elmenti a küldő e-mail címét egy egyedi mezőbe, és automatikus visszaigazoló e-mailt küld a bejelentőnek.

## Funkciók

- **Küldő e-mail cím mentése**: Ticket létrehozásakor a küldő e-mail címe automatikusan bekerül a `Küldő e-mail címe` egyedi mezőbe
- **Visszaigazoló e-mail**: A ticket létrehozása után a rendszer automatikusan visszaigazoló e-mailt küld a bejelentőnek
- Hibabiztos: ha az e-mail küldés sikertelen, a ticket akkor is létrejön

## Telepítés

### 1. Plugin letöltése

```bash
cd /opt/redmine/plugins
git clone https://github.com/Beantech0/redmine_email_ticket_plugin.git
```

### 2. Plugin migráció

```bash
cd /opt/redmine
RAILS_ENV=production /usr/local/bin/bundle exec rake redmine:plugins:migrate
```

### 3. Redmine újraindítása

```bash
sudo systemctl restart redmine
# vagy:
touch /opt/redmine/tmp/restart.txt
```

### 4. Egyedi mező létrehozása (KÖTELEZŐ)

1. Lépj be adminként a Redmine felületre
2. **Admin → Egyedi mezők → Új egyedi mező**
3. Beállítások:
   - **Típus:** Feladat (Issue)
   - **Formátum:** Szöveg
   - **Név:** `Küldő e-mail címe` ← pontosan így kell!
   - **Projektek:** `beerkezett-keresek`
4. Mentés

## Crontab módosítása 3 percre

```bash
crontab -u www-data -e
```

Módosítsd a sort:
```
*/3 * * * * /opt/redmine/email_bedolgozas.sh >> /opt/redmine/log/mail_import.log 2>&1
```

## Ellenőrzés

```bash
tail -f /opt/redmine/log/production.log | grep RedmineEmailTicketPlugin
```

## Kompatibilitás

- Redmine 5.x
- Redmine 6.x
- Ruby 3.x
