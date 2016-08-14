require 'rails_helper'

RSpec.describe User, :type => :model do

  it { should validate_presence_of :email }

  it 'should allow no role' do
    expect( build(:user) ).to be_valid
  end

  it 'should only allow valid roles' do
    expect( build(:user, user_type: 'bad_role') ).to_not be_valid
  end

  it 'removes :unassigned_driver role when made :driver' do
    u = create :unassigned_driver_user
    rz = create :ride_zone

    expect( u.has_role?(:unassigned_driver) ).to be_truthy
    expect( u.has_role?(:driver, rz) ).to be_falsy

    u.add_role(:driver, rz)

    expect( u.has_role?(:unassigned_driver) ).to be_falsy
    expect( u.has_role?(:driver, rz) ).to be_truthy
  end

  it 'adds back :unassigned_driver when :driver is removed' do
    u = create :user
    rz = create :ride_zone
    u.add_role(:driver, rz)

    expect( u.has_role?(:unassigned_driver) ).to be_falsy
    expect( u.has_role?(:driver, rz) ).to be_truthy

    u.remove_role(:driver, rz)

    expect( u.has_role?(:unassigned_driver) ).to be_truthy
    expect( u.has_role?(:driver, rz) ).to be_falsy
  end

  it 'is invalid with a non-permissible zip' do
   expect( build(:user, zip: '94118') ).to_not be_valid
  end

  it 'returns driver ride zone' do
    rz = create :ride_zone
    u = create :driver_user, ride_zone: rz
    expect(u.reload.driver_ride_zone_id).to eq(rz.id)
  end

  it 'updates location timestamp for lat change' do
    u = create :user
    expect(u.reload.location_updated_at).to be_nil
    u.update_attribute :latitude, 34
    expect(u.reload.location_updated_at).to_not be_nil
  end

  it 'updates location timestamp for long change' do
    u = create :user
    u.update_attribute :longitude, -122
    expect(u.reload.location_updated_at).to_not be_nil
  end

  describe 'enqueues email on creation' do
    let(:dummy_mailer) { OpenStruct.new(deliver_later: nil) }

    it 'sends voter email for web registration' do
      expect(UserMailer).to receive(:welcome_email_voter) { dummy_mailer }
      create :voter_user
    end

    it 'sends driver email for web registration' do
      expect(UserMailer).to receive(:welcome_email_driver) { dummy_mailer }
      create :driver_user
    end

    it 'does not send email for sms voter' do
      expect(UserMailer).to_not receive(:welcome_email_voter)
      create :sms_voter_user
    end
  end

  describe 'event generation' do
    let(:rz) { create :ride_zone }

    it 'does not send event for new voter' do
      expect_any_instance_of(RideZone).to_not receive(:event)
      create :voter_user, ride_zone: rz
    end

    it 'does not send event for updated voter' do
      u = create :voter_user, ride_zone: rz
      expect_any_instance_of(RideZone).to_not receive(:event)
      u.update_attribute(:name, 'foobar')
    end

    it 'sends new driver event' do
      expect_any_instance_of(RideZone).to receive(:event).with(:new_driver, anything, :driver)
      # cannot use factory because it doesn't create users the same way code
      # does with transient attributes
      User.create! name: 'foo', user_type: 'driver', ride_zone: rz, email: 'foo@example.com', phone_number: '+14155555555', phone_number_normalized: '+14155555555', password: '123456789'
    end

    it 'sends driver update event on change' do
      d = create :driver_user, ride_zone: rz
      expect_any_instance_of(RideZone).to receive(:event).with(:driver_changed, anything, :driver)
      d.update_attribute(:name, 'foo bar')
    end
  end
end
