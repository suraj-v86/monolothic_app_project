pipeline {
    agent { label 'suraj' }
    
    stages {
        stage("Code cloning") {
            steps {
                git branch: 'main', url: 'https://github.com/suraj-v86/monolothic_app_project.git'
            }
        }

        stage("Install dependencies and Nginx") {
            steps {
                sh '''
                    sudo apt-get update -y
                    sudo apt-get install -y python3 python3-pip python3-venv git nginx

                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                    pip install gunicorn
                '''
            }
        }

        stage("Configure systemd service") {
            steps {
                sh '''
                    SERVICE_FILE=/etc/systemd/system/flaskapp.service
                    sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Gunicorn instance to serve Flask app
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/workspace/monolothic-app
Environment="PATH=/home/ubuntu/workspace/monolothic-app/venv/bin"
ExecStart=/home/ubuntu/workspace/monolothic-app/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:8000 app:app

[Install]
WantedBy=multi-user.target
EOL

                    sudo systemctl daemon-reload
                    sudo systemctl enable flaskapp
                    sudo systemctl restart flaskapp
                '''
            }
        }

        stage("Configure Nginx server") {
            steps {
                sh '''
                    # Disable default Nginx site
                    sudo rm -f /etc/nginx/sites-enabled/default

                    # Create Flask Nginx config
                    sudo bash -c "cat > /etc/nginx/sites-available/flaskapp" <<'EOL'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOL

                    sudo ln -sf /etc/nginx/sites-available/flaskapp /etc/nginx/sites-enabled
                    sudo nginx -t
                    sudo systemctl restart nginx
                '''
            }
        }
    }

    post {
        always {
            echo "Deployment completed."
        }
    }
}
