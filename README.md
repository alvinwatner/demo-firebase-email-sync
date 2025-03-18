# Email Firebase Demo

A Flutter application that demonstrates real-time syncing with Firestore for email synchronization.

## Overview

This demo app shows how to:

1. Make an API call to start email synchronization
2. Listen to a Firestore document in real-time to track sync status
3. Listen to a Firestore collection in real-time to see new emails as they are added

## Features

- Real-time progress tracking of email synchronization
- Live updates as new emails are added to the collection
- Simple UI to visualize the sync process

## How to Use

1. Run the backend server at http://127.0.0.1:8000
2. Launch the Flutter app
3. Enter your authentication token (Bearer token)
4. Enter the email address to sync (default: alvin2phantomhive@gmail.com)
5. Click "Start Email Sync"
6. Watch as the sync status updates in real-time
7. See new emails appear in the list as they are added to Firestore

## Firebase Configuration

This demo uses Firebase Firestore to listen to:

1. `email_sync_status/{sync_id}` - Document that tracks sync progress
2. `new_emails_sync_{sync_id}` - Collection of email documents being synced

## Implementation Details

The app demonstrates:

- Making HTTP requests with authentication
- Firebase Firestore real-time listeners
- Handling asynchronous data streams
- Updating UI based on real-time data changes

## Requirements

- Flutter SDK
- Firebase account with Firestore enabled
- Backend server running at http://127.0.0.1:8000
