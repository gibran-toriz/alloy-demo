#!/bin/bash

# destroy_demo.sh - Complete cleanup of Alloy Demo POC
# This script removes all containers, networks, volumes, and temporary files created by the POC

set -e

echo "🧹 Starting complete cleanup of Alloy Demo POC..."
echo ""

# Go to the directory where the script is located
cd "$(dirname "$0")/.."

# Step 1: Stop and remove all dynamic nodes
echo "📦 Removing dynamic nodes (POS, Server, Switch, Router)..."
docker ps -a --filter "ancestor=alloy-demo-node:pos" \
           --filter "ancestor=alloy-demo-node:server" \
           --filter "ancestor=alloy-demo-node:switch" \
           --filter "ancestor=alloy-demo-node:router" -q | xargs -r docker rm -f 2>/dev/null || true
echo "   ✓ Dynamic nodes removed"
echo ""

# Step 2: Stop and remove docker-compose services
echo "🛑 Stopping and removing docker-compose services..."
docker-compose -p alloy-demo down -v
echo "   ✓ Services stopped and volumes removed"
echo ""

# Step 3: Remove Docker network if it exists
echo "🌐 Removing Docker network..."
docker network rm alloy-demo_alloy_net 2>/dev/null || echo "   ⚠ Network already removed or doesn't exist"
echo ""

# Step 4: Remove temporary log files
echo "🗑️  Removing temporary log files..."
rm -rf /tmp/pos-logs/* 2>/dev/null || true
rm -rf /tmp/server-logs/* 2>/dev/null || true
rm -f nohup.out 2>/dev/null || true
echo "   ✓ Temporary files removed"
echo ""

# Step 5: Stop any running background processes (generate_pos_logs.py)
echo "⏹️  Stopping background processes..."
pkill -f generate_pos_logs.py 2>/dev/null || true
echo "   ✓ Background processes stopped"
echo ""

# Step 6: Optional - Remove Docker images (commented by default)
# Uncomment the following lines if you want to remove the Docker images as well
# echo "🖼️  Removing Docker images..."
# docker rmi alloy-demo-node:pos 2>/dev/null || true
# docker rmi alloy-demo-node:server 2>/dev/null || true
# docker rmi alloy-demo-node:switch 2>/dev/null || true
# docker rmi alloy-demo-node:router 2>/dev/null || true
# echo "   ✓ Docker images removed"
# echo ""

# Step 7: Show summary
echo "✅ Cleanup complete!"
echo ""
echo "📊 Summary:"
echo "   • All dynamic nodes removed"
echo "   • All docker-compose services stopped"
echo "   • All volumes removed"
echo "   • Network removed"
echo "   • Temporary files cleaned"
echo "   • Background processes stopped"
echo ""
echo "💡 To start fresh, run: ./run_demo.sh"
echo ""
