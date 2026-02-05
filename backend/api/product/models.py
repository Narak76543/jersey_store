from core.db import Base
from sqlalchemy import Column ,String , Integer , Float , Boolean

class Product (Base) :
    __tablename__ = "products"
    id             = Column(String , primary_key=True , index=True)
    name           = Column(String , nullable=False , index=True)
    name_lc        = Column(String , nullable=True)
    descriptions   = Column(String ,nullable= True)
    price          = Column(Float , nullable=False)
    category       = Column(String , nullable=True , index=True)
    image_url      = Column(String , nullable=True)
    stock_quantity = Column(Integer, default=0)
    is_active      = Column(Boolean, default= True)