require 'rspec'
require 'user'

describe User do
  # テスト対象
  subject{ User.new('Taro', 'Tanaka') }

  # エクスペクテーション
  its(:full_name){ should eq "Taro Tanaka" }
  
  # 以下３つ同じ意味
  its(:admin?){ should be_false }

  it "is not admin" do
    expect(subject.admin?).to be_false
  end
  
  it { expect(subject).not_to be_admin }
  
end  
