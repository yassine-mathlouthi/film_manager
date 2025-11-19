# Film Manager - Demo Configuration

This file contains demo credentials and usage instructions for testing the application.

## Demo Accounts

### Admin Account

- **Email:** admin@filmmanager.com
- **Password:** admin123
- **Features:** Full access to admin panel, user management, system analytics

### Regular User Account

- **Email:** user@filmmanager.com
- **Password:** user123
- **Features:** Personal dashboard, film collection management (coming soon)

### Additional Test Users

- jane.smith@example.com / jane123
- mike.johnson@example.com / mike123
- sarah.wilson@example.com / sarah123
- alex.brown@example.com / alex123

## Testing Features

### Authentication Flow

1. Launch the app
2. Use any of the demo accounts above
3. Test role-based navigation (admin vs user)

### Admin Features

1. Login with admin account
2. Navigate to Admin Dashboard
3. Access User Management
4. Test user search and filtering
5. Test user deletion (demo only)

### User Features

1. Login with regular user account
2. View personal dashboard
3. Check user statistics
4. Test logout functionality

### Registration

1. Go to registration screen
2. Create new account with any email
3. Will be added to demo users list
4. Automatic redirect to user dashboard

## Technical Notes

- All data is stored locally using SharedPreferences
- No real API calls are made
- Demo data resets when app is restarted
- User deletion only affects current session
- New registrations are temporary (session only)

## Next Steps for Production

1. Replace demo data with real API service calls
2. Implement proper user authentication
3. Add real database integration
4. Implement film management features
5. Add proper error handling and validation
6. Set up secure token management
7. Add offline capability
