
require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Snapshoter do
  
end

describe Snapshoter::Volume do
  before do
    @valid_attributes = {
      'mount_point' => '/data',
    }
  end
  
  it "should initialize successfully with valid attributes" do
    Snapshoter::Volume.new('vol-test', @valid_attributes)
  end
  
  it "should raise a Snapshoter::VolumeInvalid when initialized without an id" do
    lambda {
      Snapshoter::Volume.new(nil, @valid_attributes)
    }.should raise_error Snapshoter::VolumeInvalid, /volume must have an id/
  end
  
  it "should raise a Snapshoter::VolumeInvalid when the frequency is anything but hourly, daily or weekly" do
    Snapshoter::Volume.new('vol-test', @valid_attributes.merge(:frequency => 'hourly'))
    Snapshoter::Volume.new('vol-test', @valid_attributes.merge(:frequency => 'daily'))
    Snapshoter::Volume.new('vol-test', @valid_attributes.merge(:frequency => 'weekly'))
    
    lambda {
      Snapshoter::Volume.new('vol-test', @valid_attributes.merge(:frequency => 'yearly'))
    }.should raise_error Snapshoter::VolumeInvalid, /frequency must be one of/
  end
  
  it "should raise a Snapshoter::VolumeInvalid when freeze_mysql is anything but true or false" do
    Snapshoter::Volume.new('vol-test', @valid_attributes.merge(:freeze_mysql => true))
    Snapshoter::Volume.new('vol-test', @valid_attributes.merge(:freeze_mysql => false))
    
    lambda {
      Snapshoter::Volume.new('vol-test', @valid_attributes.merge(:freeze_mysql => 33))
    }.should raise_error Snapshoter::VolumeInvalid, /freeze_mysql must be/
  end
  
  it "should raise a Snapshoter::VolumeInvalid when keep is less than or equal to 0" do
    Snapshoter::Volume.new('vol-test', @valid_attributes.merge(:keep => 33))
    
    lambda {
      Snapshoter::Volume.new('vol-test', @valid_attributes.merge(:keep => 0))
    }.should raise_error Snapshoter::VolumeInvalid, /keep must/
    
    lambda {
      Snapshoter::Volume.new('vol-test', @valid_attributes.merge(:keep => -2))
    }.should raise_error Snapshoter::VolumeInvalid, /keep must/
  end
  
  it "should raise a a Snapshoter::VolumeInvalid when initialized with an unknown option" do
    lambda {
      Snapshoter::Volume.new('vol-test', @valid_attributes.merge(:keep2 => 0))
    }.should raise_error Snapshoter::VolumeInvalid, /unknown/
    
    lambda {
      Snapshoter::Volume.new('vol-test', @valid_attributes.merge('apple' => 0))
    }.should raise_error Snapshoter::VolumeInvalid, /unknown/
  end
end

# EOF
