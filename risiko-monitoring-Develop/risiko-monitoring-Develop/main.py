from typing import Optional, List, Dict, Any
from datetime import date, datetime
from fastapi import FastAPI, Depends, HTTPException, status, Query
from fastapi.security import HTTPBasic, HTTPBasicCredentials
import secrets
import psycopg2
import psycopg2.extras

#fastapi App

app = FastAPI(title="Risikomonitoring API", version="1.0.0")
security = HTTPBasic()

#Zugangsdaten für Basic Authentication

API_USER = "thm-user"
API_PASS = "DidI-d4T4_2025"

#DATABASE CONFIG (PostgreSQL)

DB_HOST = "localhost"
DB_PORT = 5432
DB_NAME = "krankenhaus_db"
DB_USER = "postgres"
DB_PASS = "moses"

#Liefert eine möglichst sichere/lesbare Fehlermeldung für DB-Fehler zurück

def _safe_db_error(e: Exception) -> str:
    pgerror = getattr(e, "pgerror", None)
    if isinstance(pgerror, bytes):
        return pgerror.decode("utf-8", errors="replace")
    if isinstance(pgerror, str) and pgerror:
        return pgerror

    try:
        return str(e)
    except Exception:
        return repr(e)

#Erstellung eine neue DB-Verbindung (kurzlebig pro Request)

def get_conn():
    try:
        return psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            connect_timeout=5,
            options="-c client_encoding=UTF8 -c lc_messages=C",
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"DB connection failed: {_safe_db_error(e)}"
        )

#Überprüfung HTTP Basic Auth Benutzername/Passwort

def require_basic_auth(credentials: HTTPBasicCredentials = Depends(security)) -> str:
    ok_user = secrets.compare_digest(credentials.username, API_USER)
    ok_pass = secrets.compare_digest(credentials.password, API_PASS)
    if not (ok_user and ok_pass):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Unauthorized",
            headers={"WWW-Authenticate": "Basic"},
        )
    return credentials.username

#DB-QUERY FUNKTIONEN
# Führt eine SELECT-Query aus und gibt alle Zeilen als Liste von Dicts zurück.

def fetch_all(query: str, params: tuple = ()) -> List[Dict[str, Any]]:
    conn = get_conn()
    try:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(query, params)
            return cur.fetchall()
    finally:
        conn.close()

#Führt eine SELECT-Query aus und gibt genau eine Zeile zurück (oder None).

def fetch_one(query: str, params: tuple = ()) -> Optional[Dict[str, Any]]:
    conn = get_conn()
    try:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(query, params)
            return cur.fetchone()
    finally:
        conn.close()


#Einfacher Root-Endpunkt: zeigt, dass API läuft

@app.get("/", tags=["system"])
def root():
    return {"message": "Risikomonitoring API is running", "docs": "/docs"}


@app.get("/health", tags=["system"])
def health(user: str = Depends(require_basic_auth)):
    return {"status": "ok"}


# PATIENTS: Suche + Detail

@app.get("/patients", tags=["patients"])
def list_patients(
    q: Optional[str] = Query(default=None, description="Search by Vorname/Nachname (contains)"),
    patient_id: Optional[int] = Query(default=None, description="Search by exact patient id"),
    limit: int = Query(default=100, ge=1, le=500),
    offset: int = Query(default=0, ge=0),
    user: str = Depends(require_basic_auth),
):
#Exakte Suche nach patient_id (falls angegeben)

    if patient_id is not None:
        rows = fetch_all(
            """
            SELECT id, first_name, last_name, birth_date, gender
            FROM patient
            WHERE id = %s
            """,
            (patient_id,),
        )
        return {"items": rows, "limit": limit, "offset": offset, "count": len(rows)}
    
#Textsuche nach Vorname/Nachname (contains, case-insensitive)

    if q and q.strip():
        qv = f"%{q.strip().lower()}%"
        rows = fetch_all(
            """
            SELECT id, first_name, last_name, birth_date, gender
            FROM patient
            WHERE LOWER(COALESCE(first_name, ''))LIKE %s
               OR LOWER(COALESCE(last_name, '')) LIKE %s
            ORDER BY last_name, first_name
            LIMIT %s OFFSET %s
            """,
            (qv, qv, limit, offset),
        )

#Ohne Suchtext: gebe alle Patienten paginiert zurück

    else:
        rows = fetch_all(
            """
            SELECT id, first_name, last_name, birth_date, gender
            FROM patient
            ORDER BY last_name, first_name
            LIMIT %s OFFSET %s
            """,
            (limit, offset),
        )

    return {"items": rows, "limit": limit, "offset": offset, "count": len(rows)}


@app.get("/patients/{patient_id}", tags=["patients"])
def get_patient_detail(patient_id: int, user: str = Depends(require_basic_auth)):
    row = fetch_one(
        """
        SELECT id, first_name, last_name, birth_date, gender, created_at
        FROM patient
        WHERE id = %s
        """,
        (patient_id,),
    )
    if not row:
        raise HTTPException(status_code=404, detail="Patient not found")
    return row

#Detaildaten zu einem einzelnen Patienten.

@app.get("/patients/{patient_id}/vitals", tags=["vitals"])
def patient_vitals(
    patient_id: int,
    limit: int = Query(default=50, ge=1, le=500),
    user: str = Depends(require_basic_auth),
):
    rows = fetch_all(
        """
        SELECT id, patient_id, pulse, systolic_bp, diastolic_bp, temperature, measured_at
        FROM vital_sign
        WHERE patient_id = %s
        ORDER BY measured_at DESC NULLS LAST
        LIMIT %s
        """,
        (patient_id, limit),
    )
    return {"patient_id": patient_id, "items": rows}

#Vitalwerte: Gibt die letzten Vitalwerte eines Patienten zurück (Zeitreihe).

@app.get("/patients/{patient_id}/vitals/latest", tags=["vitals"])
def patient_vitals_latest(patient_id: int, user: str = Depends(require_basic_auth)):
    row = fetch_one(
        """
        SELECT id, patient_id, pulse, systolic_bp, diastolic_bp, temperature, measured_at
        FROM vital_sign
        WHERE patient_id = %s
        ORDER BY measured_at DESC NULLS LAST
        LIMIT 1
        """,
        (patient_id,),
    )
    if not row:
        return {"patient_id": patient_id, "latest": None}
    return {"patient_id": patient_id, "latest": row}

#Diagnosen eines Patienten

@app.get("/patients/{patient_id}/diagnostics", tags=["diagnostics"])
def patient_diagnostics(
    patient_id: int,
    limit: int = Query(default=50, ge=1, le=500),
    user: str = Depends(require_basic_auth),
):
    rows = fetch_all(
        """
        SELECT id, patient_id, diagnostic_name, diagnostic_date
        FROM diagnostic
        WHERE patient_id = %s
        ORDER BY diagnostic_date DESC NULLS LAST
        LIMIT %s
        """,
        (patient_id, limit),
    )
    return {"patient_id": patient_id, "items": rows}

#Gibt alle unterschiedlichen Diagnosebezeichnungen zurück

@app.get("/diagnostics", tags=["diagnostics"])
def list_all_diagnostic_names(user: str = Depends(require_basic_auth)):
    rows = fetch_all(
        """
        SELECT DISTINCT diagnostic_name
        FROM diagnostic
        ORDER BY diagnostic_name
        """
    )
    return {"items": rows}

#Medikamente
#Gibt alle Medikamente (Stammdaten) zurück.


@app.get("/medications", tags=["medications"])
def list_medications(user: str = Depends(require_basic_auth)):
    rows = fetch_all(
        """
        SELECT id, name
        FROM medication
        ORDER BY name
        """
    )
    return {"items": rows}

#Medikamente eines Patienten.

@app.get("/patients/{patient_id}/medications", tags=["medications"])
def patient_medications(
    patient_id: int,
    limit: int = Query(default=50, ge=1, le=500),
    user: str = Depends(require_basic_auth),
):
    rows = fetch_all(
        """
        SELECT
            pm.id,
            pm.patient_id,
            pm.medication_id,
            COALESCE(m.name, pm.medication_name) AS medication_name,
            pm.dosage,
            pm.start_date,
            pm.end_date
        FROM patient_medication pm
        LEFT JOIN medication m ON m.id = pm.medication_id
        WHERE pm.patient_id = %s
        ORDER BY pm.start_date DESC NULLS LAST
        LIMIT %s
        """,
        (patient_id, limit),
    )
    return {"patient_id": patient_id, "items": rows}

#Aggregierter Endpunkt

@app.get("/patients/{patient_id}/summary", tags=["patients"])
def patient_summary(patient_id: int, user: str = Depends(require_basic_auth)):
    patient = fetch_one(
        "SELECT id, first_name, last_name, birth_date, gender FROM patient WHERE id=%s",
        (patient_id,),
    )
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")

    latest_vitals = fetch_one(
        """
        SELECT pulse, systolic_bp, diastolic_bp, temperature, measured_at
        FROM vital_sign
        WHERE patient_id = %s
        ORDER BY measured_at DESC NULLS LAST
        LIMIT 1
        """,
        (patient_id,),
    )

    latest_diag = fetch_one(
        """
        SELECT diagnostic_name, diagnostic_date
        FROM diagnostic
        WHERE patient_id = %s
        ORDER BY diagnostic_date DESC NULLS LAST
        LIMIT 1
        """,
        (patient_id,),
    )

    meds = fetch_all(
        """
        SELECT
            COALESCE(m.name, pm.medication_name) AS medication_name,
            pm.dosage,
            pm.start_date,
            pm.end_date
        FROM patient_medication pm
        LEFT JOIN medication m ON m.id = pm.medication_id
        WHERE pm.patient_id = %s
        ORDER BY pm.start_date DESC NULLS LAST
        LIMIT 10
        """,
        (patient_id,),
    )

    return {
        "patient": patient,
        "latest_vitals": latest_vitals,
        "latest_diagnostic": latest_diag,
        "medications": meds,
    }

#Zeitachse (Vitals + Diagnosen + Medikamente)

@app.get("/patients/{patient_id}/history", tags=["history"])
def patient_history(
    patient_id: int,
    limit_each: int = Query(default=50, ge=1, le=500),
    user: str = Depends(require_basic_auth),
):
    vitals = fetch_all(
        """
        SELECT 'vital' AS type, measured_at AS ts,
               pulse, systolic_bp, diastolic_bp, temperature
        FROM vital_sign
        WHERE patient_id=%s
        ORDER BY measured_at DESC NULLS LAST
        LIMIT %s
        """,
        (patient_id, limit_each),
    )

    diags = fetch_all(
        """
        SELECT 'diagnostic' AS type, diagnostic_date::timestamp AS ts,
               diagnostic_name
        FROM diagnostic
        WHERE patient_id=%s
        ORDER BY diagnostic_date DESC NULLS LAST
        LIMIT %s
        """,
        (patient_id, limit_each),
    )

    meds = fetch_all(
        """
        SELECT 'medication' AS type, start_date::timestamp AS ts,
               COALESCE(m.name, pm.medication_name) AS medication_name,
               pm.dosage, pm.start_date, pm.end_date
        FROM patient_medication pm
        LEFT JOIN medication m ON m.id = pm.medication_id
        WHERE pm.patient_id=%s
        ORDER BY start_date DESC NULLS LAST
        LIMIT %s
        """,
        (patient_id, limit_each),
    )

    #merge + sort by ts desc (ts can be null => put at end)

    def ts_key(x):
        return x["ts"] if x["ts"] is not None else datetime(1900, 1, 1)

    timeline = vitals + diags + meds
    timeline.sort(key=ts_key, reverse=True)

    return {"patient_id": patient_id, "items": timeline}


#(regelbasierte) Risiko-Berechnung

@app.get("/patients/{patient_id}/risk", tags=["risk"])
def patient_risk(patient_id: int, user: str = Depends(require_basic_auth)):
 
 #Existiert Patient?

    patient = fetch_one("SELECT id FROM patient WHERE id=%s", (patient_id,))
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")

#Letzte Vitalwerte

    v = fetch_one(
        """
        SELECT pulse, systolic_bp, diastolic_bp, temperature, measured_at
        FROM vital_sign
        WHERE patient_id=%s
        ORDER BY measured_at DESC NULLS LAST
        LIMIT 1
        """,
        (patient_id,),
    )

#Letzte Diagnose

    d = fetch_one(
        """
        SELECT diagnostic_name, diagnostic_date
        FROM diagnostic
        WHERE patient_id=%s
        ORDER BY diagnostic_date DESC NULLS LAST
        LIMIT 1
        """,
        (patient_id,),
    )

    score = 0
    reasons = []

#Regeln basierend auf Vitalwerten

    if v:
        temp = float(v["temperature"]) if v["temperature"] is not None else None
        pulse = v["pulse"]
        sys_bp = v["systolic_bp"]
        dia_bp = v["diastolic_bp"]

        if temp is not None and temp >= 38.5:
            score += 2
            reasons.append("Fever >= 38.5")

        if pulse is not None and pulse >= 120:
            score += 2
            reasons.append("Pulse >= 120")

        if sys_bp is not None and sys_bp >= 180:
            score += 2
            reasons.append("Systolic BP >= 180")

        if dia_bp is not None and dia_bp >= 110:
            score += 1
            reasons.append("Diastolic BP >= 110")

#Regeln basierend auf Diagnose (Keyword-Heuristik)

    if d and d.get("diagnostic_name"):
        name = d["diagnostic_name"].lower()
        if "arrhythm" in name or "herz" in name or "cardiac" in name:
            score += 2
            reasons.append("Cardio-related diagnosis")
        if "infekt" in name or "pneum" in name or "bronch" in name:
            score += 1
            reasons.append("Infection-related diagnosis")

#Score -> Risiko-Level

    if score >= 5:
        level = "HIGH"
    elif score >= 3:
        level = "MEDIUM"
    else:
        level = "LOW"

    return {
        "patient_id": patient_id,
        "score": score,
        "level": level,
        "reasons": reasons,
        "used_latest_vitals": v,
        "used_latest_diagnostic": d,
    }
