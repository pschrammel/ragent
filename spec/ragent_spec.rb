# frozen_string_literal: true
require 'spec_helper'

describe Ragent do
  let(:ragent) { Ragent.ragent }

  it 'has a version number' do
    expect(Ragent::VERSION).not_to be nil
  end
  
  it "sets up nonblocking" do
    Ragent.start(workdir: APP_DIR, log_level: 'debug', blocking: false)
    expect(ragent).not_to be_nil
  end
  
  describe "with setup ragent" do
    before do
      Ragent.start(workdir: APP_DIR, log_level: 'debug', blocking: false)
    end
    
    it "has a workdir" do
      expect(ragent.workdir.to_s).to eq(APP_DIR)
    end
    
    it "has a templates_path" do
      expect(ragent.templates_path.to_s).to eq(File.expand_path('../../../templates',APP_DIR))
    end    
  end
end
