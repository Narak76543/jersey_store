
from pydantic import BaseModel, ConfigDict
from typing import Optional

class ProductBase(BaseModel):
    name: str
    name_lc :str
    descriptions: Optional[str] = None
    price: float
    category: Optional[str] = None
    image_url: Optional[str] = None
    category : str 
    stock_quantity: int = 0
    is_active: bool = True

class ProductCreate(ProductBase):
    pass

class ProductResponse(ProductBase):
    id: str 

    model_config = ConfigDict(from_attributes=True)