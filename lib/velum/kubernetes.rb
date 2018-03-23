require "velum/salt"

module Velum
  # Kubernetes deals with the Kubernetes integration of this application.
  class Kubernetes
    KubeConfig = Struct.new :host, :ca_crt

    # Returns the Kubernetes apiserver configuration. It returns a KubeConfig struct.
    def self.kubeconfig
      host = Pillar.value pillar: :apiserver
      ca_crt = Velum::Salt.read_file(targets: "ca", file: "/etc/pki/ca.crt").first

      KubeConfig.new host, ca_crt
    end
  end
end
