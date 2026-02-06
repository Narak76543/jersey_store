from typing import Optional
from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
import uuid
from core.db import get_db
from api.product.models import Product
from main import app
from fastapi import File, UploadFile, Form
import os
from sqlalchemy import desc

@app.get("/")
def root():
    return {"message": "GGMU! The Manchester United Store API is live."}
UPLOAD_DIR = os.path.join("static", "products")
os.makedirs(UPLOAD_DIR, exist_ok=True)
BASE_URL = "http://localhost:8000"

@app.post("/products/", tags=["product"])
async def create_product(
    name           : str                  = Form(...),
    name_lc        : str                  = Form(),
    price          : float                = Form(...),
    stock_quantity : int                  = Form(...),
    descriptions   : Optional[str]        = Form(None),
    image          : Optional[UploadFile] = File(None),
    category       : str                  = Form(...),
    db             : Session              = Depends(get_db),
):
    final_image_url: Optional[str] = None
    
    if image:
        _, ext = os.path.splitext(image.filename)
        filename = f"{uuid.uuid4().hex}{ext}"
        dest_path = os.path.join(UPLOAD_DIR, filename)
        
        file_data = await image.read()
        with open(dest_path, "wb") as f:
            f.write(file_data)
        
        final_image_url = f"/static/products/{filename}"

    new_product = Product(
        id             = str(uuid.uuid4()), 
        name           = name,
        name_lc        = name_lc,     
        price          = price,
        stock_quantity = stock_quantity,
        descriptions   = descriptions,
        image_url      = final_image_url,
        category       = category,
        is_active      = True              
    )
    
    db.add(new_product)
    db.commit()
    db.refresh(new_product)
    return new_product

@app.get("/products/", tags=["product"])
async def get_all_products(db: Session = Depends(get_db)):
    products = db.query(Product).order_by(desc(Product.id)).all()
    
    for p in products:
        if p.image_url and p.image_url.startswith("/static"):
            p.image_url = f"{BASE_URL}{p.image_url}"
            
    return products

@app.get("/products/{product_id}")
def get_product_by_id(product_id: str, db: Session = Depends(get_db)):

    """Get details for a specific item (e.g., clicking a shirt in Flutter)."""

    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product

@app.put("/products/{product_id}", tags=["product"])
async def update_product(
    product_id: str,
    name           : Optional[str]        = Form(None),
    name_lc        : Optional[str]        = Form(None),
    price          : Optional[float]      = Form(None),
    stock_quantity : Optional[int]        = Form(None),
    descriptions   : Optional[str]        = Form(None),
    category       : Optional[str]        = Form(None),
    is_active      : Optional[bool]       = Form(None),
    image          : Optional[UploadFile] = File(None),
    db             : Session              = Depends(get_db),
):
    product_query = db.query(Product).filter(Product.id == product_id)
    db_product = product_query.first()

    if not db_product:
        raise HTTPException(status_code=404, detail="Product not found")

    if image:
        if db_product.image_url:
            old_path = db_product.image_url.lstrip("/") 
            if os.path.exists(old_path):
                os.remove(old_path)

        _, ext = os.path.splitext(image.filename)
        filename = f"{uuid.uuid4().hex}{ext}"
        dest_path = os.path.join(UPLOAD_DIR, filename)
        
        file_data = await image.read()
        with open(dest_path, "wb") as f:
            f.write(file_data)
        
        db_product.image_url = f"/static/products/{filename}"

    if name is not None:
        db_product.name = name
    if name_lc is not None:
        db_product.name_lc = name_lc
    if price is not None:
        db_product.price = price
    if stock_quantity is not None:
        db_product.stock_quantity = stock_quantity
    if descriptions is not None:
        db_product.descriptions = descriptions
    if category is not None:
        db_product.category = category
    if is_active is not None:
        db_product.is_active = is_active

    db.commit()
    db.refresh(db_product)
    
    if db_product.image_url and not db_product.image_url.startswith("http"):
        db_product.image_url = f"{BASE_URL}{db_product.image_url}"
        
    return db_product

@app.delete("/products/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_product(product_id: str, db: Session = Depends(get_db)):
    
    """Remove a product (Admin only)."""
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    
    db.delete(product)
    db.commit()
    return None