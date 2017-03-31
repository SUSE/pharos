require "spec_helper"
require "velum/secrets"

describe "create_secret_key_base" do
  key_base_dir = File.join("/tmp", "velum_secrets_spec")
  key_base_path = File.join(key_base_dir, "key_base")

  before do
    FileUtils::mkdir_p key_base_dir
  end

  after do
    FileUtils::rm_r key_base_dir
  end

  it "makes new key_base" do
    Velum.create_secret_key_base(Pathname.new(key_base_path))
    content1 = IO.read key_base_path
    expect(content1.length).not_to eq 0
    Velum.create_secret_key_base(Pathname.new(key_base_path))
    expect(IO.read(key_base_path)).to eq content1
  end
end