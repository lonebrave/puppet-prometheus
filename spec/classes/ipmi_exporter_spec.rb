require 'spec_helper'

describe 'prometheus::ipmi_exporter' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'without parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('prometheus') }
        it { is_expected.to contain_prometheus__daemon('ipmi_exporter').with(options: '   --freeipmi.path=/usr/local/bin') }
        it { is_expected.to contain_service('ipmi_exporter') }
        it { is_expected.to contain_user('ipmi-exporter') }
        it { is_expected.to contain_group('ipmi-exporter') }

        if facts[:os]['name'] == 'Archlinux'
          it { is_expected.not_to contain_file('/opt/ipmi_exporter-v1.3.1.linux-amd64/ipmi_exporter') }
          it { is_expected.not_to contain_file('/usr/local/bin/ipmi_exporter') }
          it { is_expected.to contain_systemd__unit_file('ipmi_exporter.service') }
        else
          it { is_expected.to contain_file('/opt/ipmi_exporter-v1.3.1.linux-amd64/ipmi_exporter') }
          it { is_expected.to contain_file('/usr/local/bin/ipmi_exporter') }
        end

        if facts[:os]['family'] == 'RedHat'
          it { is_expected.not_to contain_file('/etc/sysconfig/bird_exporter') }
        else
          it { is_expected.not_to contain_file('/etc/default/bird_exporter') }
        end
      end

      context 'with collector parameters' do
        let(:params) do
          {
            collectors_enable: %w[foo bar],
            collectors_disable: %w[baz qux],
            install_method: 'url',
            version: 'v1.3.1'
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_archive('/tmp/ipmi_exporter-v1.3.1.tar.gz') }
        it { is_expected.to contain_prometheus__daemon('ipmi_exporter').with(options: ' --collector.foo --collector.bar --no-collector.baz --no-collector.qux --freeipmi.path=/usr/local/bin') }
        if facts[:os]['name'] == 'Archlinux'
          it { is_expected.to contain_file('/usr/bin/ipmi_exporter') }
          it { is_expected.not_to contain_file('/usr/local/bin/ipmi_exporter') }
        else
          it { is_expected.to contain_file('/usr/local/bin/ipmi_exporter') }
          it { is_expected.not_to contain_file('/usr/bin/ipmi_exporter') }
        end
      end

      context 'with version specified' do
        let(:params) do
          {
            version: 'v1.0.0',
            arch: 'amd64',
            os_type: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url'
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_archive('/tmp/ipmi_exporter-v1.0.0.tar.gz') }
        it { is_expected.to contain_file('/opt/ipmi_exporter-v1.0.0.linux-amd64/ipmi_exporter') }
        describe 'install correct binary' do
          it { is_expected.to contain_file('/usr/local/bin/ipmi_exporter').with('target' => '/opt/ipmi_exporter-v1.0.0.linux-amd64/ipmi_exporter') }
        end
      end

      context 'with collector parameters and extra options' do
        let(:params) do
          {
            collectors_enable: %w[foo bar],
            collectors_disable: %w[baz qux],
            extra_options: '--path.procfs /host/proc --path.sysfs /host/sys'
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_prometheus__daemon('ipmi_exporter').with(options: '--path.procfs /host/proc --path.sysfs /host/sys --collector.foo --collector.bar --no-collector.baz --no-collector.qux --freeipmi.path=/usr/local/bin') }
      end

      context 'with no download_extension' do
        let(:params) do
          {
            download_extension: '',
          }
        end

        it { is_expected.to contain_prometheus__daemon('ipmi_exporter').with_download_extension('') }
      end
    end
  end
end
