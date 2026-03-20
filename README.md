# Salary Predictor — MLOps Portfolio Project

![CI Pipeline](https://github.com/MichaelYnoa/ml-salary-predictor/actions/workflows/ci.yml/badge.svg)

A production-style MLOps project demonstrating end-to-end model deployment
with CI/CD automation. Built as part of a DevOps/MLOps transition portfolio.

## Architecture
```
code push → GitHub Actions → Docker build → DockerHub registry
                ↓
         train model → build image → push image
```

## Stack

- **Model**: Ridge Regression (scikit-learn)
- **API**: FastAPI with Pydantic contract validation
- **Container**: Docker with multi-layer caching optimization
- **CI/CD**: GitHub Actions — automated build and registry push
- **Registry**: DockerHub

## Run Locally
```bash
# Clone and setup
git clone https://github.com/MichaelYnoa/ml-salary-predictor.git
cd ml-salary-predictor
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# Train model
python train.py

# Start API
uvicorn app.main:app --reload
```

API docs available at `http://localhost:8000/docs`

## API Usage
```bash
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"years_experience": 12, "is_remote": 1, "company_size": 3, "education_level": 2}'
```

Response:
```json
{"predicted_salary": 162567.29, "currency": "USD"}
```

## Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/predict` | Returns predicted salary |
| GET | `/health` | Liveness check for orchestration |
| GET | `/docs` | Auto-generated API documentation |

## CI/CD Pipeline

Every push triggers:
1. Python environment setup
2. Model training — generates `salary_model.pkl` and `scaler.pkl`
3. Docker image build
4. Push to DockerHub registry

## Infrastructure

Deployed on AWS using Terraform:
```bash
cd infra
terraform init
terraform apply
# API available at the output URL in ~2 minutes
terraform destroy  # always destroy when done
```

**Resources:** EC2 t3.micro + Security Group (us-east-1)
```

## Next Steps

- [x] Terraform infrastructure on AWS
- [X] Prometheus + Grafana observability
- [ ] Kubernetes deployment manifests
