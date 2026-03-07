# Food_Delivery_App_Project
SQL project based on food delivery system 
The **Food Delivery Database Analytics Project** is a comprehensive SQL-based system designed to manage and analyze large volumes of transactional and customer data for online food delivery platforms. The project focuses on improving service quality, understanding customer behavior, and increasing profitability through structured data analysis and automation.

### **1. Core System Components**

The system is built on the `food_app_project` database, which utilizes interconnected tables to mirror a real-world application environment:

* 
**Main Tables**: Includes `Customers` (ID and name), `Restaurants` (ID, name, city, and rating), and `Orders` (transaction details, amounts, discounts, and delivery times).


* 
**Log Tables**: Automatically records unusual events through triggers, specifically tracking high-value orders, negative discounts, and delivery delays to ensure transparency.


* 
**Entity Relationship (ER) Structure**: Features one-to-many relationships where one customer or restaurant can be linked to many orders, with the `Orders` table acting as the central connecting entity.



### **2. Analytical Features and Automation**

The project employs advanced database concepts to streamline operations and extract insights:

* 
**Exploratory Data Analysis (EDA)**: Computes total revenue (order amounts minus discounts), identifies high-demand regions by city, and ranks the top 10 customers by spending.


* 
**Customer Segmentation**: Classifies users into **Gold** (spending ≥ 1000), **Silver** (spending ≥ 500), and **Bronze** (spending < 500) categories to support targeted marketing and loyalty programs.


* 
**Stored Procedures and Views**: A view named `restaurant_revenue` simplifies complex calculations for reporting, while the `GET_TOP_N_RESTAURANTS` procedure enables dynamic, reusable business logic.


* 
**Triggers**: Three automated rules ensure data integrity by logging orders over 1000, preventing negative discounts, and flagging deliveries exceeding 45 minutes.



### **3. Performance and Scalability**

To ensure the system remains efficient as data volumes grow, the project implements an **Indexing Strategy**. Indexes are placed on `order_date`, `customer_name`, and `restaurant_name` to reduce search time and accelerate query execution.

### **4. Business Insights and Future Directions**

The analysis reveals that a small group of customers drives a major share of revenue and that restaurant ratings generally correlate with financial performance.

* 
**Recommendations**: Management should improve logistics in cities with frequent delays and partner more closely with top-performing restaurants.


* 
**Future Enhancements**: The project aims to integrate machine learning for demand prediction, implement real-time monitoring, and deploy to cloud platforms like AWS or Azure.
