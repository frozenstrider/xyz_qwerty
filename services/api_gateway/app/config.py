from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    minio_endpoint: str = "http://minio:9000"
    minio_access_key: str = "admin"
    minio_secret_key: str = "adminadmin"
    jwt_secret: str = "dev"
    ai_vision_url: str = "http://ai_vision:8000"
    ai_ocr_url: str = "http://ai_ocr_trans:8000"
    mt_url: str = "http://mt_gateway:8000"
    vl_url: str = "http://vl_panels:8000"
    inpaint_url: str = "http://inpaint:8000"

settings = Settings()
