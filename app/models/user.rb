class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

	#paperclip method to save the image
	has_attached_file :photo, :styles => { :small => "100x100>", :medium => "250x250>", :large => "500x500>", :thumb => "50x50>" },
	:url => "/system/:class/:id/:style/:basename.:extension",
	:path => ":rails_root/public/system/:class/:id/:style/:basename.:extension"

	validates_attachment_file_name :photo, matches: [/png\Z/, /jpe?g\Z/]
	do_not_validate_attachment_file_type :photo

end
