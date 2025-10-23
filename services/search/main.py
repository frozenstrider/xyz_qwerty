from fastapi import FastAPI
app = FastAPI(title="search", version="0.2.0")

@app.get("/health")
def health():
    return {"service":"search","status":"ok"}

@app.get("/search")
def search(q: str):
    return {"q": q, "results":[{"id":1,"name":"Death Note","score":0.97}]}
