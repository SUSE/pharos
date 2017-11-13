require "velum/salt_api"

module Velum
  # This class allows to interact with global salt actions
  class Salt
    include SaltApi

    # This method is the entrypoint of any Salt call. It will simply apply the
    # given function 'action' with the given arguments 'arg' to the given targets.
    #
    # Returns two values:
    #   - The response object.
    #   - A hash containing the parsed JSON response.
    def self.call(action:, targets: "*", target_type: "glob", arg: nil)
      hsh = { tgt: targets, fun: action, expr_form: target_type, client: "local" }
      hsh[:arg] = arg if arg

      res = perform_request(endpoint: "/", method: "post", data: hsh)
      [res, JSON.parse(res.body)]
    end

    # Returns the update status of the different minions.
    def self.update_status(targets: "*")
      _, needed = Salt.call(action: "grains.get", arg: "tx_update_reboot_needed", targets: targets)
      _, failed = Salt.call(action: "grains.get", arg: "tx_update_failed", targets: targets)
      [needed["return"], failed["return"]]
    end

    # Returns the minions as discovered by salt.
    def self.minions
      res = perform_request(endpoint: "/minions", method: "get")
      JSON.parse(res.body)["return"].first
    end

    # Returns the minions that have not been accepted into the cluster
    def self.pending_minions
      res = perform_request(endpoint: "/", method: "post",
                            data: { client: "wheel",
                                    fun:    "key.list",
                                    match:  "all" })
      JSON.parse(res.body)["return"].first["data"]["return"]["minions_pre"]
    end

    # Accepts a minion into the cluster
    def self.accept_minion(minion_id: "")
      res = perform_request(endpoint: "/", method: "post",
                            data: { client: "wheel",
                                    fun:    "key.accept",
                                    match:  minion_id })
      JSON.parse(res.body)["return"].first["data"]["return"]["minions"]
    end

    # Returns the list of jobs
    def self.jobs
      res = perform_request(endpoint: "/jobs", method: "get")
      JSON.parse(res.body)["return"]
    end

    # Returns information about a job
    def self.job(jid:)
      res = perform_request(endpoint: "/jobs/#{jid}", method: "get")
      JSON.parse(res.body)
    end

    def self.keys
      res = perform_request(endpoint: "/keys", method: "get")
      JSON.parse(res.body)["return"]
    end

    # Call the salt orchestration.
    def self.orchestrate
      res = perform_request(endpoint: "/run", method: "post",
                            data: { client: "runner_async",
                                    fun:    "state.orchestrate",
                                    arg:    ["orch.kubernetes"] })
      [res, JSON.parse(res.body)]
    end

    # Call the update orchestration
    def self.update_orchestration
      res = perform_request(endpoint: "/run", method: "post",
                            data: { client: "runner_async",
                                    fun:    "state.orchestrate",
                                    arg:    ["orch.update"] })
      [res, JSON.parse(res.body)]
    end

    # Returns the contents of the given file.
    def self.read_file(targets: "*", target_type: "glob", file: nil)
      _, data = Velum::Salt.call action:      "cmd.run",
                                 targets:     targets,
                                 target_type: target_type,
                                 arg:         "cat #{file}"

      data["return"].map do |el|
        val = el.values.first

        # TODO: improve error handling...
        val && val.include?("No such file or directory") ? nil : val
      end
    end

    # Consolidates salt status into Velum
    #
    # In most cases the only active job will be detecting the update status of all the minions in
    # the cluster, since the rest of the operations are notified to Velum via salt reactors (to
    # the internal API). This consolidation jobs are here just in case Velum did not receive the
    # callback for whatever reason (it was down, not responding...)
    def self.consolidate
      loop do
        detect_missing_minions
        detect_missing_highstates
        detect_missing_orchestration_results
        discover_update_status
        sleep 5.minutes # FIXME: make this a cron instead of a long running process
      end
    end

    def self.detect_missing_minions
      minions = Velum::Salt.minions.reject { |minion_id, _| minion_id == "ca" }
      (minions.keys - Minion.all.pluck(:minion_id)).each do |minion_id|
        Minion.find_or_create_by(minion_id: minion_id) do |minion|
          if minion_id == "admin"
            minion.role = Minion.roles[:admin]
          end
          minion.fqdn = minions[minion_id]["fqdn"]
          minion.highstate = Minion.highstates[:not_applied]
        end
      end
    end

    def self.detect_missing_highstates
    end

    def self.detect_missing_orchestration_results
    end

    def self.discover_update_status
    end
  end
end
