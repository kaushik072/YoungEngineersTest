# young_engineers

### Prerequisites

- Flutter 3.29.1
- Laravel Backend

### Features

- Daily and weekly attendance visualization
- Interactive bar charts with group-wise breakdown
- Filterable by:
  - Date range
  - POS (Point of Sale)
  - Groups
- Horizontal/Vertical chart toggle
- Pagination support for data loading

### Tech Stack

- **Frontend**: Flutter 3.29.1
  - GetX for state management
  - fl_chart for data visualization
  
- **Backend**: Laravel
  - RESTful API endpoints

### Project Structure
lib/
├── app/
│ ├── data/
│ │ ├── api/
│ │ ├── models/
│ │ └── repository/
│ └── modules/
│ └── home/
│ ├── controllers/
│ └── views/
└── main.dart