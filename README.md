# Samsung Global Supply Chain & Profitability Analysis

![SQL](https://img.shields.io/badge/Tool-SQL%20%7C%20PostgreSQL-blue)
![Power BI](https://img.shields.io/badge/Tool-Power%20BI-yellow)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

## Project Overview        
   
A comprehensive supply chain and profitability analysis of Samsung's global operations,
built using SQL (PostgreSQL) and Power BI. The project covers 10 interconnected data
tables and delivers a 6-page interactive dashboard with stakeholder-specific insights
for the CEO, COO, Investors, Supply Chain Manager, and India Market team.
    
---                  
                
## Dashboard Preview                     

> <img width="1280" height="720" alt="image" src="https://github.com/user-attachments/assets/d7574ecd-967d-4be5-8bee-050a401a4259" />
---
               
## Problem Statement
    
Samsung operates across complex, multi-region supply chains involving sales, production,
inventory, shipments, procurement, and customer data. Without consolidated visibility,
inefficiencies in production volume, logistics routing, and delivery performance go
undetected — directly impacting profitability.

---

## Key Business Findings

### 1. Inventory Surplus Crisis
SQL analysis revealed a critical gap between production and actual sales:

| Product | Units Produced | Units Sold | Surplus |
|---|---|---|---|
| Galaxy S24 Ultra | 347,369,757 | 8,120,856 | 339,248,901 |
| Galaxy Buds2 Pro | 302,526,040 | 8,028,894 | 294,497,146 |

**Recommendation:** Immediately scale back production on these two SKUs to eliminate
warehousing costs and redirect budget to high-demand products.

### 2. India Logistics Gap
- Main warehouse: Mumbai | Primary demand center: Delhi
- Distance: 1,400+ km of unnecessary transit
- Impact: Lowest "Offer Price Efficiency" among all regions

**Recommendation:** Relocate or add a distribution hub closer to Delhi to reduce
transit costs and improve competitive pricing.

### 3. Brand Strength — Discount Analysis
51.13% of customers purchase at full price with 0% discount applied, indicating
strong brand equity. Broad discounting is unnecessary and margin-dilutive.

### 4. Shipment Performance Gap
- Current delivery rate: 92.36%
- Industry "Excellent" benchmark: 95–98%
- Top delay causes: Carrier Capacity (15.71%), Documentation Issues (13.61%),
  Port Congestion (12.74%)

---

## Key KPIs

| Metric | Value |
|---|---|
| Total Revenue | $176.95M |
| Net Profit | $48.56M |
| Profit Margin | 27.44% |
| Production Defect Rate | 0.73% |
| On-Time Delivery Rate | 92.36% |
| Perfect Order Rate | 75% |

---

## Tools & Techniques

- **SQL (PostgreSQL):** Complex JOINs across 10 tables, window functions,
  profit variance analysis, stakeholder-specific query sets
- **Power BI:** 6-page interactive dashboard — Overview, Supplier, Inventory,
  Shipment, Customer, India Market
- **Data Storytelling:** Business recommendations structured for CEO, COO,
  Investor, and Supply Chain Manager audiences

---

## Conclusion

By aligning production volume with real demand and addressing the India
logistics routing gap, Samsung can reduce avoidable costs and safely scale
production by 20%. This project demonstrates that supply chain efficiency
is directly measurable — and directly improvable — through structured data analysis.

---

## Connect

**Pushpkar Roy**
- Email: pushpkarroy880@gmail.com
- LinkedIn: [linkedin.com/in/pushpkar-roy](https://www.linkedin.com/in/pushpkar-roy)
- GitHub: [github.com/PushpkarRoy](https://github.com/PushpkarRoy)
