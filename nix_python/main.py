import sys
import uvicorn
from fastapi import APIRouter, Depends, FastAPI, HTTPException
from sqlalchemy.orm import Session

from . import crud, models, schemas
from .database import SessionLocal, engine

#models.Base.metadata.create_all(bind=engine)

router = APIRouter(
    prefix="/users",
    tags=["users"],
    )


items_router = APIRouter(
    prefix="/items",
    tags=["items"],
    )


ping_router = APIRouter(
    prefix="/ping",
    tags=["ping"],
    )


# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@ping_router.get("", response_model=schemas.Ping)
def get_ping():
    return schemas.Ping(ping="pong")


@router.post("", response_model=schemas.User)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return crud.create_user(db=db, user=user)


@router.get("", response_model=list[schemas.User])
def read_users(offset: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    users = crud.get_users(db, skip=offset, limit=limit)
    return users


@router.get("/{user_id}", response_model=schemas.User)
def read_user(user_id: int, db: Session = Depends(get_db)):
    db_user = crud.get_user(db, user_id=user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user


@router.post("/{user_id}/items", response_model=schemas.Item)
def create_item_for_user(
    user_id: int, item: schemas.ItemCreate, db: Session = Depends(get_db)
):
    return crud.create_user_item(db=db, item=item, user_id=user_id)


@items_router.get("", response_model=list[schemas.Item])
def read_items(offset: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    items = crud.get_items(db, skip=offset, limit=limit)
    return items


app = FastAPI()
app.include_router(router)
app.include_router(ping_router)
app.include_router(items_router)

for route in app.routes:
	if route.path.endswith('/'):
		if route.path == '/':
			continue
		print(f'Aborting: paths may not end with a slash, route with problem is: {route.path}')
		sys.exit(1)


def start():
    uvicorn.run("nix_python.main:app", host="0.0.0.0", port=8000, reload=True)
