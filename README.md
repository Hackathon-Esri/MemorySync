# Chrononauts

## Table of Contents

1. [Overview](#overview)
2. [Product Spec](#product-spec)
3. [Wireframes](#wireframes)
4. [Schema](#schema)

## Overview

### Description

Chrononauts allows users to experience and immerse themselves in historical views of their current location. By creating and viewing panoramas from past dates, users can navigate through old street views and see how locations have changed over time. The app combines ARKit with panoramic image data to create an immersive experience that brings the past to life.

### App Evaluation

- **Category:** Augmented Reality, Historical Exploration
- **Mobile:** Yes, it's available for iOS devices.
- **Story:** The app helps users explore historical street views and understand changes in their surroundings.
- **Market:** It's for anyone interested in history, travel, and augmented reality experiences.
- **Habit:** Use it occasionally to explore different time periods or specific locations.
- **Scope:** It provides a unique way to experience historical views through AR on iPhones.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

- [x] User can view historical panoramas based on their current location.
- [x] User can navigate through different time periods to see how locations have changed.
- [x] User can create new panoramic images and save them for future viewing.
- [ ] User can access detailed information about the historical context of the views.
- [ ] User receives notifications about new or updated panoramic images for their area.

**Optional Nice-to-have Stories**

- [x] User can customize the date range for historical views.
- [ ] User can share panoramic images with others via social media or messaging apps.
- [ ] User can add personal notes or comments to the panoramic images.
- [ ] User can export panoramic images for offline use or sharing.

### 2. Screen Archetypes

- [x] **Main Screen**
  * User can view and interact with historical panoramas.
- [x] **Panorama Creation Screen**
  * User can create and save new panoramic images.
- [x] **Historical View Selection Screen**
  * User can choose different time periods for viewing historical panoramas.
- [ ] **Information Screen**
  * User can view detailed information about the historical context of the images.

### 3. Navigation

**Tab Navigation** (Tab to Screen)

- [x] **Main Tab**: Main Screen
- [x] **Create Tab**: Panorama Creation Screen
- [x] **History Tab**: Historical View Selection Screen
- [ ] **Info Tab**: Information Screen

**Flow Navigation** (Screen to Screen)

- [ ] [**Main Screen**]
  * Leads to [**Panorama Creation Screen**] for creating new panoramas.
  * Leads to [**Historical View Selection Screen**] for choosing different time periods.
  * Leads to [**Information Screen**] for detailed historical context.

## Wireframes

### Digital Wireframes & Mockups

![Main Screen](URL-to-image)
![Panorama Creation](URL-to-image)
![Historical View Selection](URL-to-image)

### Interactive Prototype

<div>
    <a href="URL-to-prototype">
      <img style="max-width:300px;" src="URL-to-thumbnail">
    </a>
  </div>

## Schema 

### Models

[Model Name: Panorama]
| Property     | Type   | Description                                  |
|--------------|--------|----------------------------------------------|
| date         | String | Date of the panoramic image                  |
| image        | Image  | The panoramic image data                     |
| location     | String | Location where the panorama was taken        |
| description  | String | Description or additional information        |

### Networking

- [GET] /panoramas - Retrieve list of available panoramas
- [POST] /panoramas - Create a new panoramic image
- [GET] /panoramas/{id} - Retrieve a specific panoramic image
- [PUT] /panoramas/{id} - Update information about a panoramic image
