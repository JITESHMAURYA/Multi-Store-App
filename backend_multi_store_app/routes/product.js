const express = require("express");
// const { auth } = require('../middleware/auth');
const Product = require("../models/product");
const productRouter = express.Router();
const { auth, vendorAuth } = require("../middleware/auth");

productRouter.post("/api/add-product", auth, vendorAuth, async (req, res) => {
  try {
    const {
      productName,
      productPrice,
      quantity,
      description,
      category,
      vendorId,
      fullName,
      subCategory,
      images,
    } = req.body;
    const product = new Product({
      productName,
      productPrice,
      quantity,
      description,
      category,
      vendorId,
      fullName,
      subCategory,
      images,
    });

    await product.save();
    return res.status(201).send(product);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

//get products
productRouter.get("/api/popular-products", async (req, res) => {
  try {
    // Find products where popular is true and sort by default creation order
    const product = await Product.find({ popular: true });
    if (!product || product.length == 0) {
      return res.status(404).json({ msg: "Products not found" });
    } else {
      return res.status(200).json(product); // Send the products as JSON response
    }
  } catch (e) {
    res.status(500).json({ error: e.message }); // Send error response
  }
});

// Add a new route to get recommended products
productRouter.get("/api/recommended-products", async (req, res) => {
  try {
    // Find products where popular is true and sort by default creation order
    const product = await Product.find({ recommend: true });
    if (!product || product.length == 0) {
      return res.status(404).json({ msg: "Products not found" });
    } else {
      return res.status(200).json(product); // Send the products as JSON response
    }
  } catch (e) {
    res.status(500).json({ error: e.message }); // Send error response
  }
});
//retrieving products by category
productRouter.get("/api/products-by-category/:category", async (req, res) => {
  try {
    const { category } = req.params;
    const products = await Product.find({ category, popular: true });
    if (!products || products.length == 0) {
      return res.status(404).json({ msg: "Product not found" });
    } else {
      return res.status(200).json(products);
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

//new route for retrieving related products by subcategory
productRouter.get("/api/related-products-by-subcategory/:productId", async (req, res) => {
  try {
    const { productId } = req.params;
    // first, find the product to get it's subcategory 
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({ msg: "Product not found" });
    } else {
      //find related products base on the subcategory of the retrieved product 
      const relatedProducts = await Product.find({
        subCategory: product.subCategory,
        _id: { $ne: productId } // exclude the current product
      });
      if (!relatedProducts || relatedProducts.length == 0) {
        return res.status(404).json({ msg: "No related products found" });
      }
      return res.status(200).json(relatedProducts);
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

//route for retrieving the top 10 highest rated products
productRouter.get("/api/top-rated-products", async (req, res) => {
  try {
    //fetch all products and sort them by average rating in decending order (highest rated first)
    //sort product by average rating, with -1 indicating decending order
    const topRatedProducts = await Product.find({}).sort({ averageRating: -1 }).limit(10); //limit the result to top 10 highest rated products
    //check if there are any top-rated products found
    if (!topRatedProducts || topRatedProducts.length === 0) {
      return res.status(404).json({ msg: "No top-rated products found" });
    }
    //return the top-rated product as a response
    return res.status(200).json(topRatedProducts);
  } catch (e) {
    //handle any server errors that occur during the request
    return res.status(500).json({ error: e.message });
  }
});
module.exports = productRouter;





//get product by category
// productRouter.get('/category/products', async (req, res) => {
//     try {
//         // Check if category query parameter is provided
//         const category = req.query.category;
//         let products;
//         if (category) {
//             // Find products where category matches the query parameter
//             products = await Product.find({ category: category });
//         } else {
//             // If no category provided, return all products
//             products = await Product.find();
//         }
//         res.status(200).json(products); // Send the products as JSON response
//     } catch (error) {
//         res.status(500).json({ error: error.message }); // Send error response
//     }
// });