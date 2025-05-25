package main

import (
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
)

func getClientIP(r *http.Request) string {
	xff := r.Header.Get("X-Forwarded-For")
	if xff != "" {
		ips := strings.Split(xff, ",")
		return strings.TrimSpace(ips[0])
	}

	ip := r.RemoteAddr
	if idx := strings.Index(ip, ":"); idx != -1 {
		ip = ip[:idx]
	}
	return ip
}

func debugHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	queryParams := r.URL.Query()

	headers := make(map[string]string)
	for name, values := range r.Header {
		headers[name] = values[0] // Берем только первое значение заголовка
	}
	clientIP := getClientIP(r)

	protocol := r.Header.Get("X-Forwarded-Proto")
	if protocol == "" {
		protocol = "http"
	}

        host := r.Host

	log.Printf("Received request: Host=%s, Method=%s, URL=%s, URI=%s, Path=%s, QueryParams=%v, Headers=%v, ClientIP=%s", host, r.Method, r.URL, r.RequestURI, r.URL.Path, queryParams, headers, clientIP)
	response := map[string]interface{}{
		"request_details": map[string]interface{}{
			"method":   r.Method,
			"args":     queryParams,
			"path":     r.URL.Path,
			"uri":      r.RequestURI,
			"protocol": protocol, 
		},
		"headers":   headers,
		"client_ip": clientIP,
                "host":      host,
	}

	if r.Method == http.MethodPost {
		body, err := ioutil.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Unable to read request body", http.StatusBadRequest)
			return
		}
		defer r.Body.Close()

		response["raw_post_data"] = string(body)
	}

	json.NewEncoder(w).Encode(response)
}

func main() {
	ip := flag.String("ip", "0.0.0.0", "IP address to listen on")
	port := flag.String("port", "5000", "Port to listen on")
	flag.Parse()

	http.HandleFunc("/", debugHandler)

	log.Printf("Starting server on %s:%s", *ip, *port)
	if err := http.ListenAndServe(*ip+":"+*port, nil); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

