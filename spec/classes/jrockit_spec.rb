require 'spec_helper'

supported_oses = {}.merge!(on_supported_os)

describe 'jrockit' do
   context 'supported operating systems' do
     supported_oses.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
           facts
        end

        context 'without any parameters' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('jrockit') }
        end
      end
    end
  end
end
