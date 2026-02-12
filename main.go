package main

import (
	"context"
	"crypto/rand"
	"embed"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io/fs"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"sync"
	"time"
)

//go:embed public/index.html
var content embed.FS

// Configuration
var (
	port      = getEnv("PORT", "91")
	configDir = getEnv("XKEEN_CONFIG", "/opt/etc/xray/configs")
	serviceCmd = getEnv("XKEEN_SERVICE", "/opt/sbin/xkeen")
	authUser  = getEnv("XKEEN_USER", "root")
	authPass  = getEnv("XKEEN_PASS", "keenetic")
	version   = "2.0.0"
)

// Session store
var (
	sessions     = make(map[string]time.Time)
	sessionMutex sync.RWMutex
	sessionTTL   = 24 * time.Hour
)

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

func generateSessionID() string {
	bytes := make([]byte, 32)
	rand.Read(bytes)
	return hex.EncodeToString(bytes)
}

func createSession() string {
	sessionMutex.Lock()
	defer sessionMutex.Unlock()

	id := generateSessionID()
	sessions[id] = time.Now().Add(sessionTTL)
	return id
}

func verifySession(id string) bool {
	sessionMutex.RLock()
	defer sessionMutex.RUnlock()

	expires, ok := sessions[id]
	if !ok {
		return false
	}
	return time.Now().Before(expires)
}

func deleteSession(id string) {
	sessionMutex.Lock()
	defer sessionMutex.Unlock()
	delete(sessions, id)
}

func getSessionFromCookie(r *http.Request) string {
	cookie, err := r.Cookie("session")
	if err != nil {
		return ""
	}
	return cookie.Value
}

// Strip ANSI escape codes
func stripAnsi(s string) string {
	re := regexp.MustCompile(`\x1B\[[0-9;]*[a-zA-Z]|\[[\d;]*m`)
	return re.ReplaceAllString(s, "")
}

// Get list of config files
func getFiles() ([]string, error) {
	var files []string

	entries, err := os.ReadDir(configDir)
	if err != nil {
		return files, err
	}

	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}
		name := entry.Name()
		ext := filepath.Ext(name)
		// Include .conf, .json, .list, .log files and files without extension
		if ext == ".conf" || ext == ".json" || ext == ".list" || ext == ".log" || ext == "" {
			files = append(files, name)
		}
	}

	return files, nil
}

// Get file content
func getFileContent(filename string) (string, error) {
	// Prevent directory traversal
	if strings.Contains(filename, "..") || strings.Contains(filename, "/") {
		return "", fmt.Errorf("invalid filename")
	}

	path := filepath.Join(configDir, filename)
	data, err := os.ReadFile(path)
	if err != nil {
		return "", err
	}
	return string(data), nil
}

// Save file content
func saveFile(filename, content string) error {
	if strings.Contains(filename, "..") || strings.Contains(filename, "/") {
		return fmt.Errorf("invalid filename")
	}

	path := filepath.Join(configDir, filename)
	return os.WriteFile(path, []byte(content), 0644)
}

// Remove file
func removeFile(filename string) error {
	if strings.Contains(filename, "..") || strings.Contains(filename, "/") {
		return fmt.Errorf("invalid filename")
	}

	path := filepath.Join(configDir, filename)
	return os.Remove(path)
}

// Get service status
func getServiceStatus() bool {
	cmd := exec.Command("sh", "-c", "ps | grep -v grep | grep xray")
	output, _ := cmd.Output()
	return len(strings.TrimSpace(string(output))) > 0
}

// Execute service action
func serviceAction(action string) ([]string, int) {
	allowedActions := map[string]bool{
		"start":   true,
		"stop":    true,
		"restart": true,
		"status":  true,
	}

	if !allowedActions[action] {
		return []string{"Invalid action"}, 1
	}

	cmdStr := fmt.Sprintf("%s -%s", serviceCmd, action)
	log.Printf("Executing: %s", cmdStr)

	// For start/restart, run in background since xkeen may not release stdout
	if action == "start" || action == "restart" {
		// Run command with nohup and redirect to prevent blocking
		bgCmd := fmt.Sprintf("nohup %s >/dev/null 2>&1 &", cmdStr)
		log.Printf("Running in background: %s", bgCmd)
		exec.Command("sh", "-c", bgCmd).Start()

		// Wait for service to start
		log.Printf("Waiting 5 seconds for service to start...")
		time.Sleep(5 * time.Second)

		// Run xkeen -status to check
		statusCmd := fmt.Sprintf("%s -status", serviceCmd)
		log.Printf("Checking status: %s", statusCmd)

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		cmd := exec.CommandContext(ctx, "sh", "-c", statusCmd)
		statusOutput, statusErr := cmd.CombinedOutput()
		log.Printf("Status output: %s, err: %v", string(statusOutput), statusErr)

		result := stripAnsi(string(statusOutput))
		lines := strings.Split(strings.TrimSpace(result), "\n")

		var filtered []string
		for _, line := range lines {
			if strings.TrimSpace(line) != "" {
				filtered = append(filtered, line)
			}
		}

		if len(filtered) == 0 {
			filtered = []string{"Service status checked"}
		}

		// Check if running based on status output or ps
		if statusErr == nil || getServiceStatus() {
			return filtered, 0
		}
		return filtered, 1
	}

	// For stop/status, run normally with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 25*time.Second)
	defer cancel()

	log.Printf("Starting command...")
	cmd := exec.CommandContext(ctx, "sh", "-c", cmdStr)
	output, err := cmd.CombinedOutput()
	log.Printf("Command finished, output length: %d, err: %v", len(output), err)

	// Check if timeout occurred
	if ctx.Err() == context.DeadlineExceeded {
		log.Printf("Command timed out")
		return []string{"Command timed out"}, 0
	}

	result := stripAnsi(string(output))
	lines := strings.Split(strings.TrimSpace(result), "\n")

	// Filter empty lines
	var filtered []string
	for _, line := range lines {
		if strings.TrimSpace(line) != "" {
			filtered = append(filtered, line)
		}
	}

	// Default messages if no output
	if len(filtered) == 0 {
		messages := map[string]string{
			"start":   "Service started successfully",
			"stop":    "Service stopped successfully",
			"restart": "Service restarted successfully",
			"status":  "Status check completed",
		}
		if msg, ok := messages[action]; ok {
			filtered = []string{msg}
		} else {
			filtered = []string{"Done"}
		}
	}

	exitCode := 0
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			exitCode = exitErr.ExitCode()
		} else {
			exitCode = 1
		}
	}

	return filtered, exitCode
}

// API response helper
func jsonResponse(w http.ResponseWriter, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(data)
}

// API handler
func apiHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	r.ParseForm()
	cmd := r.FormValue("cmd")

	sessionID := getSessionFromCookie(r)
	isAuthenticated := verifySession(sessionID)

	// Handle login
	if cmd == "login" {
		user := r.FormValue("user")
		pass := r.FormValue("password")

		if user == authUser && pass == authPass {
			newSession := createSession()
			http.SetCookie(w, &http.Cookie{
				Name:     "session",
				Value:    newSession,
				Path:     "/",
				HttpOnly: true,
				SameSite: http.SameSiteLaxMode,
				MaxAge:   86400,
			})
			jsonResponse(w, map[string]interface{}{"status": 0})
		} else {
			jsonResponse(w, map[string]interface{}{"status": 1, "error": "Invalid credentials"})
		}
		return
	}

	// Handle logout
	if cmd == "logout" {
		if sessionID != "" {
			deleteSession(sessionID)
		}
		http.SetCookie(w, &http.Cookie{
			Name:   "session",
			Value:  "",
			Path:   "/",
			MaxAge: -1,
		})
		jsonResponse(w, map[string]interface{}{"status": 0})
		return
	}

	// All other commands require authentication
	if !isAuthenticated {
		w.WriteHeader(http.StatusUnauthorized)
		jsonResponse(w, map[string]interface{}{"error": "Unauthorized"})
		return
	}

	switch cmd {
	case "filenames":
		files, err := getFiles()
		if err != nil {
			jsonResponse(w, map[string]interface{}{"error": err.Error()})
			return
		}
		jsonResponse(w, map[string]interface{}{
			"files":   files,
			"service": getServiceStatus(),
		})

	case "filecontent":
		filename := r.FormValue("filename")
		content, err := getFileContent(filename)
		if err != nil {
			jsonResponse(w, map[string]interface{}{"error": err.Error()})
			return
		}
		jsonResponse(w, map[string]interface{}{"content": content})

	case "filesave":
		filename := r.FormValue("filename")
		content := r.FormValue("content")
		err := saveFile(filename, content)
		if err != nil {
			jsonResponse(w, map[string]interface{}{"error": err.Error()})
			return
		}
		jsonResponse(w, map[string]interface{}{"status": 0})

	case "fileremove":
		filename := r.FormValue("filename")
		err := removeFile(filename)
		if err != nil {
			jsonResponse(w, map[string]interface{}{"error": err.Error()})
			return
		}
		jsonResponse(w, map[string]interface{}{"status": 0})

	case "start", "stop", "restart", "status":
		log.Printf("API: service action '%s' requested", cmd)
		output, exitCode := serviceAction(cmd)
		log.Printf("API: service action '%s' completed, exitCode=%d, output=%v", cmd, exitCode, output)
		result := map[string]interface{}{"output": output}
		if exitCode != 0 {
			result["status"] = exitCode
		}
		log.Printf("API: sending response for '%s'", cmd)
		jsonResponse(w, result)

	default:
		jsonResponse(w, map[string]interface{}{"error": "Unknown command"})
	}
}

// Index handler
func indexHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	sessionID := getSessionFromCookie(r)
	isAuthenticated := verifySession(sessionID)

	// Read embedded HTML
	htmlBytes, err := fs.ReadFile(content, "public/index.html")
	if err != nil {
		http.Error(w, "Internal error", http.StatusInternalServerError)
		return
	}

	html := string(htmlBytes)

	// Replace placeholders
	authStr := "false"
	if isAuthenticated {
		authStr = "true"
	}
	html = strings.Replace(html, "__AUTHENTICATED__", authStr, 1)
	html = strings.Replace(html, "__VERSION__", version, 1)

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.Header().Set("Cache-Control", "no-store, no-cache, must-revalidate")
	w.Write([]byte(html))
}

func main() {
	// Load config from file if exists
	configFile := "/opt/etc/xkeen-web/xkeen-web.conf"
	if data, err := os.ReadFile(configFile); err == nil {
		lines := strings.Split(string(data), "\n")
		for _, line := range lines {
			line = strings.TrimSpace(line)
			if line == "" || strings.HasPrefix(line, "#") {
				continue
			}
			parts := strings.SplitN(line, "=", 2)
			if len(parts) == 2 {
				key := strings.TrimSpace(parts[0])
				value := strings.Trim(strings.TrimSpace(parts[1]), "\"'")
				switch key {
				case "PORT":
					port = value
				case "XKEEN_CONFIG":
					configDir = value
				case "XKEEN_SERVICE":
					serviceCmd = value
				case "XKEEN_USER":
					authUser = value
				case "XKEEN_PASS":
					authPass = value
				}
			}
		}
	}

	// Ensure config directory exists
	os.MkdirAll(configDir, 0755)

	http.HandleFunc("/", indexHandler)
	http.HandleFunc("/api", apiHandler)

	addr := ":" + port
	log.Printf("xkeen-web v%s starting on http://0.0.0.0%s", version, addr)
	log.Printf("Config directory: %s", configDir)
	log.Printf("Service command: %s", serviceCmd)

	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatal(err)
	}
}
