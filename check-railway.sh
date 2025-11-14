#!/bin/bash

echo "🚂 Railway Configuration Checker"
echo "================================="
echo ""

echo "📋 Checking Railway environment variables..."
railway variables

echo ""
echo "================================="
echo ""
echo "✅ Required variables checklist:"
echo ""
echo "Must have in web service:"
echo "  [ ] DATABASE_URL (should reference PostgreSQL service)"
echo "  [ ] SECRET_KEY"
echo "  [ ] DEBUG=False"
echo "  [ ] ALLOWED_HOSTS"
echo "  [ ] EMAIL_* variables (if emails needed)"
echo ""
echo "Must NOT have in web service:"
echo "  [ ] DB_HOST=db (causes 'db' hostname error)"
echo "  [ ] DB_NAME"
echo "  [ ] DB_USER"
echo ""
echo "================================="
echo ""
echo "📊 Checking deployment status..."
railway status

echo ""
echo "================================="
echo ""
echo "📜 Recent logs (last 50 lines):"
railway logs --limit 50

