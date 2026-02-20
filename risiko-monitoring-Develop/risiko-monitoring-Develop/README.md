# Risiko-Monitoring
Diese Anwendung dient zur digitalen Risikoüberwachung von Patientinnen und Patienten. Was machen sie . Sie ermöglicht, Anmeldung von medizinischen Personal, Suche  nach Patienten, Anzeige von Vitaldaten, Risikobewertung, Therapieempfehlungen, Speicherung von Notizen und Abmeldung vom System. In der ersten Version der Anwendung konnten die Zugriffsrechte (zb.Anmeldung als Pflegekraft oder Arzt) noch nicht umgesetzt werden.

Das System besteht aus zwei Hauptkommenten:
- Frontend: SwiftUI iOS App
- Backend: Python FastAPI Server
- Datenbank: PostgreSQL

# Systemarchitektur
- APP(SwiftUI)
- REST API(FastAPI- main.py)
- PostgreSQL Datenbank(Krankenhaus_DB)

# Login-System
Der User meldet sich mit:
- Benutzername
- Passwort

Es wird dann im Backend überprüft, ob die Daten korrekt sind.
Wenn die Daten Korrekt sind, folgt den Zugriff auf Hauptmenü.
Wenn die Daten falsch sind, tritt eine Fehlermeldung auf.

# Hauptfunktionen

## Patienten Suchen
- API Request an /patients(Endpoints)
- Backend fragt PostgreSQL ab
- Daten werden im JSON-FORMAT zurückgegeben

## Risikobewertung
- Vitaldaten werden analysiert
- Risiko-Level: GREEN / YELLOW/ RED
- Anzeige im Diagramm

## Therapie-Modul
- Anzeige empfohlener Maßnahmen 
- Basierend auf Risiko-Level

## Notizen Speichern
- SwiftData lokal im Gerät
- Änderungensdatum wird automatisch aktualisiert

# Wie ist dann Backend Zu starten?
py -m venv venv
source venv/bin/Activate
pip install -r requirements.txt
uvicron main.......


