require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../rails_helper'

describe Player do
  let!(:player1) { Player.create(name: 'Zorg the Destroyer') }
  it 'requires the name to be present' do
    expect { player1.name = nil; player1.save! }.to raise_error ActiveRecord::RecordInvalid
  end
end
