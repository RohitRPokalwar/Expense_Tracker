from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.lib import colors

def create_mock_receipt(filename):
    c = canvas.Canvas(filename, pagesize=letter)
    width, height = letter

    # Header
    c.setFont("Helvetica-Bold", 24)
    c.drawString(50, height - 50, "Amazon.in Invoice")
    
    c.setFont("Helvetica", 12)
    c.drawString(50, height - 80, "Order ID: 404-1234567-8901234")
    c.drawString(50, height - 100, "Date: 12 Feb 2026")
    
    # Bill To
    c.drawString(50, height - 140, "Bill To:")
    c.drawString(50, height - 155, "Rohit Pokalwar")
    c.drawString(50, height - 170, "Pune, Maharashtra")

    # Table Header
    y = height - 220
    c.setFont("Helvetica-Bold", 12)
    c.drawString(50, y, "Description")
    c.drawString(300, y, "Qty")
    c.drawString(400, y, "Price")
    c.drawString(500, y, "Amount")
    
    # Line
    c.line(50, y - 5, 550, y - 5)
    
    # Items
    items = [
        ("Wireless Mouse Logitech M235", 1, "649.00", "649.00"),
        ("USB-C Cable Nylon Braided", 2, "299.00", "598.00"),
        ("Notebook Spiral Binding", 3, "150.00", "450.00")
    ]
    
    y -= 25
    c.setFont("Helvetica", 12)
    for item, qty, price, total in items:
        c.drawString(50, y, item)
        c.drawString(300, y, str(qty))
        c.drawString(400, y, price)
        c.drawString(500, y, total)
        y -= 20

    # Line
    c.line(50, y - 5, 550, y - 5)
    y -= 25
    
    # Totals
    c.drawString(400, y, "Subtotal:")
    c.drawString(500, y, "1697.00")
    y -= 20
    
    c.drawString(400, y, "Tax (18%):")
    c.drawString(500, y, "305.46")
    y -= 20
    
    c.setFont("Helvetica-Bold", 14)
    c.drawString(400, y, "Grand Total:")
    c.drawString(500, y, "Rs. 2002.46")
    
    # Footer
    c.setFont("Helvetica-Oblique", 10)
    c.drawString(50, 50, "Thank you for shopping with us.")
    
    c.save()
    print(f"Mock receipt saved as {filename}")

if __name__ == "__main__":
    create_mock_receipt("mock_receipt.pdf")
