require 'spec_helper'

module Actionable
  describe Action do
    subject { klass.run number }
    context 'class' do
      let(:klass) { TestActionable::GreatAction }
      it { expect(klass.model).to eq Invoice }
      it { expect(klass.steps.map(&:name)).to eq %w[fail_for_2 add_one add_two] }
      it { expect(klass.method(:call)).to eq klass.method(:run) }
      it { expect(klass.action_name).to eq 'test_actionable/great_action' }
    end
    context 'result' do
      let(:klass) { TestActionable::GreatAction }
      context 'success' do
        let(:number) { 10 }
        it { is_expected.to be_a Actionable::Success }
        it { expect(subject.code).to eq :success }
        it { expect(subject.message).to eq 'Completed successfully.' }
        it { expect(subject.fixtures).to eq('number' => 13) }
        it do
          msg = nil
          klass.run(number) { |x| msg = x.message }
          expect(msg).to eq 'Completed successfully.'
        end
      end
      context 'failure' do
        let(:number) { 2 }
        it { is_expected.to be_a Actionable::Failure }
        it { expect(subject.code).to eq :bad_number }
        it { expect(subject.message).to eq 'Wrong number' }
        it { expect(subject.fixtures).to eq('number' => 2) }
        it do
          msg = nil
          klass.run(number) { |x| msg = x.message }
          expect(msg).to be_nil
        end
      end
    end
    context 'composed' do
      context 'single' do
        let(:klass) { TestActionable::ComposedAction }
        context 'class' do
          it { expect(klass.steps.map(&:name)).to eq %w[test_actionable/small_action add_five] }
          it { expect(klass.action_name).to eq 'test_actionable/composed_action' }
        end
        context 'result' do
          context 'success' do
            let(:number) { 10 }
            it { expect(subject.success?).to eq true }
            it { expect(subject.fixtures).to eq('number' => 18) }
          end
          context 'failure' do
            let(:number) { 6 }
            it { expect(subject.success?).to eq false }
            it { expect(subject.fixtures).to eq('number' => 6) }
          end
        end
      end
      context 'multiple' do
        let(:klass) { TestActionable::OverComposedAction }
        context 'class' do
          it { expect(klass.steps.map(&:name)).to eq %w[add_five test_actionable/composed_action add_ten] }
          it { expect(klass.action_name).to eq 'test_actionable/over_composed_action' }
        end
        context 'result' do
          context 'success' do
            let(:number) { 10 }
            it { expect(subject.success?).to eq true }
            it { expect(subject.fixtures).to eq('number' => 33) }
          end
          context 'failure' do
            let(:number) { 1 }
            it { expect(subject.success?).to eq false }
            it { expect(subject.fixtures).to eq('number' => 6) }
          end
        end
      end
    end
    context 'conditional' do
      let(:klass) { TestActionable::ConditionalAction }
      context 'if' do
        let(:number) { 1 }
        it { expect(subject.number).to eq 5 }
      end
      context 'unless' do
        let(:number) { 3 }
        it { expect(subject.number).to eq 3 }
      end
    end
    context 'case' do
      let(:klass) { TestActionable::CaseAction }
      context 'first step' do
        let(:number) { 1 }
        it { expect(subject.number).to eq 2 }
      end
      context 'second step' do
        let(:number) { 2 }
        it { expect(subject.number).to eq 4 }
      end
      context 'default step' do
        let(:number) { 3 }
        it { expect(subject.number).to eq 6 }
      end
    end
    context 'final' do
      let(:klass) { TestActionable::FinalAction }
      context 'on success' do
        let(:number) { 3 }
        it { expect(subject.number).to eq 6 }
      end
      context 'on failure' do
        let(:number) { 1 }
        it { expect(subject.number).to eq 5 }
      end
    end
  end
end
