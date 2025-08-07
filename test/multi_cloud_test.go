package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestMultiCloudK8sDeployment(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform",
		Vars: map[string]interface{}{
			"environment": "test",
		},
		NoColor: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Test AWS EKS Cluster
	eksConfig := terraform.Output(t, terraformOptions, "eks_kubeconfig")
	eksOptions := k8s.NewKubectlOptions("", eksConfig, "default")
	
	eksNodes := k8s.GetNodes(t, eksOptions)
	assert.Greater(t, len(eksNodes), 0, "Expected at least one node in EKS cluster")

	// Test GCP GKE Cluster
	gkeConfig := terraform.Output(t, terraformOptions, "gke_kubeconfig")
	gkeOptions := k8s.NewKubectlOptions("", gkeConfig, "default")
	
	gkeNodes := k8s.GetNodes(t, gkeOptions)
	assert.Greater(t, len(gkeNodes), 0, "Expected at least one node in GKE cluster")

	// Test Azure AKS Cluster
	aksConfig := terraform.Output(t, terraformOptions, "aks_kubeconfig")
	aksOptions := k8s.NewKubectlOptions("", aksConfig, "default")
	
	aksNodes := k8s.GetNodes(t, aksOptions)
	assert.Greater(t, len(aksNodes), 0, "Expected at least one node in AKS cluster")
}

func TestSecurityControls(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform",
		Vars: map[string]interface{}{
			"environment": "test",
		},
		NoColor: true,
	})

	terraform.InitAndApply(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)

	// Test Network Policies
	eksConfig := terraform.Output(t, terraformOptions, "eks_kubeconfig")
	eksOptions := k8s.NewKubectlOptions("", eksConfig, "default")

	networkPolicies := k8s.ListNetworkPolicies(t, eksOptions, "default")
	assert.Greater(t, len(networkPolicies), 0, "Expected network policies to be configured")

	// Test Pod Security Policies
	podSecurityPolicies := k8s.ListPodSecurityPolicies(t, eksOptions)
	assert.Greater(t, len(podSecurityPolicies), 0, "Expected pod security policies to be configured")
}

func TestMonitoring(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform",
		Vars: map[string]interface{}{
			"environment": "test",
		},
		NoColor: true,
	})

	terraform.InitAndApply(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)

	eksConfig := terraform.Output(t, terraformOptions, "eks_kubeconfig")
	eksOptions := k8s.NewKubectlOptions("", eksConfig, "monitoring")

	// Wait for Prometheus deployment
	k8s.WaitUntilDeploymentAvailable(t, eksOptions, "prometheus", 10, 10*time.Second)

	// Wait for Grafana deployment
	k8s.WaitUntilDeploymentAvailable(t, eksOptions, "grafana", 10, 10*time.Second)

	// Test monitoring endpoints
	prometheusEndpoint := k8s.GetService(t, eksOptions, "prometheus")
	assert.NotNil(t, prometheusEndpoint, "Expected Prometheus service to be available")

	grafanaEndpoint := k8s.GetService(t, eksOptions, "grafana")
	assert.NotNil(t, grafanaEndpoint, "Expected Grafana service to be available")
}
