from pydantic import BaseModel

class UserCreate(BaseModel):
    username: str
    password: str

class UserResponse(BaseModel):
    id: int
    username: str

class TrackResponse(BaseModel):
    id: int
    name: str
    description: str
    difficulty: str