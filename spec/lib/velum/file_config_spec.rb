# frozen_string_literal: true
require "tempfile"
require 'fileutils'
require "velum/file_config"

describe Velum::FileConfig do
  conf_dir = File.join(Dir.tmpdir, "velum_config_test")

  before do
    FileUtils::rm_r(conf_dir, :force => true)
  end

  after do
    FileUtils::rm_r(conf_dir, :force => true)
  end

  it "reads and writes hash structures" do
    conf = Velum::FileConfig.new(conf_dir)
    expect(conf.exist?("hash")).to eq false

    conf.write_hash("hash", "a"=>1)
    expect(conf.exist?("hash")).to eq true
    expect(conf.read_hash("hash")).to eq("a"=>1)
  end
end

describe Velum::AppSecrets do
  conf_dir = File.join(Dir.tmpdir, "velum_app_secrets_test")

  before do
    FileUtils::rm_r(conf_dir, :force => true)
  end

  after do
    FileUtils::rm_r(conf_dir, :force => true)
  end

  it "generates a unique secret" do
    app_secrets = Velum::AppSecrets.new(conf_dir)
    secret1 = app_secrets.new_secret_key_base
    secret2 = app_secrets.new_secret_key_base
    expect(secret1).not_to eq secret2
  end

  it "persist generated application key hex string" do
    app_secrets = Velum::AppSecrets.new(conf_dir)
    new_secret = app_secrets.generate_secret_key_base
    expect(new_secret).not_to eq ""
    retrieved_secret = app_secrets.generate_secret_key_base
    expect(retrieved_secret).to eq new_secret
  end
end
