# iw-Robot Integration Folder

## 📁 Required Structure

This folder contains the iw-Robot automation framework integration for the Alloy Demo POC.

```
iwRobot/
├── iw-robot/          # ⚠️ YOU MUST ADD THIS MANUALLY
│   ├── bin/
│   ├── config/
│   ├── lib/
│   ├── resources/
│   └── ...
├── resources/         # ✅ Included in repository
│   ├── startRAM.sh
│   ├── stopRam.sh
│   └── restart_ram.py
├── Observabilidad.edn # ✅ Included - Automation workflow
└── README.md          # This file
```

## ⚠️ IMPORTANT: Manual Setup Required

The `iw-robot/` application folder is **NOT included** in the git repository due to its size and licensing.

### Setup Instructions

1. **Obtain iw-Robot**
   - Download or request the iw-Robot distribution package
   - Extract the `.tar` file to get the `iw-robot` folder

2. **Place iw-Robot Here**
   ```bash
   # From the project root
   cp -r /path/to/extracted/iw-robot ./iwRobot/
   ```

3. **Verify Structure**
   ```bash
   ls -la ./iwRobot/iw-robot/
   # Should show: bin/ config/ lib/ resources/ etc.
   ```

4. **Start the POC**
   ```bash
   ./run_demo.sh
   ```

5. **Import Workflow**
   - Access iw-Robot via VNC: `vnc://localhost:5901`
   - Import the automation workflow from: `./iwRobot/Observabilidad.edn`

## 📄 Included Files

### `Observabilidad.edn`
Automation workflow that:
- Monitors RabbitMQ for alerts
- Manages container lifecycle
- Sends email notifications
- Handles infrastructure incidents

### `resources/` folder
Scripts used by the automation workflow:
- **startRAM.sh** - Starts the RAM simulator container
- **stopRam.sh** - Stops the RAM simulator container
- **restart_ram.py** - Python script for container restart logic

## 🔗 Integration Points

iw-Robot integrates with:
- **RabbitMQ** - Monitors the `alertas` queue
- **Docker Socket** - Manages containers via `/var/run/docker.sock`
- **Grafana** - Can send metrics and notifications
- **Email (Gmail)** - Sends alert notifications

## 📝 Notes

- This folder is mounted as a volume in the `iw-robot` Docker container
- The Docker socket is also mounted to allow container management
- Privileged mode is required for full functionality

## 🐛 Troubleshooting

**Container fails to start:**
```bash
# Check if iw-robot folder exists
ls ./iwRobot/iw-robot/
# If not found, you need to add it manually
```

**Cannot access via VNC:**
```bash
# Check if port 5901 is exposed
docker ps | grep iw-robot
# Try connecting to: vnc://localhost:5901
```

For more details, see the main [SETUP_GUIDE.md](../SETUP_GUIDE.md)
