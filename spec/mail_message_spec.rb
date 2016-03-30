describe TemplateMailer::MailMessage do
	let(:recipients) {
		["one@test.com", "two@test.com"]
	}
	let(:from) {
		"sender@somewhere.com"
	}
	let(:title) {
		"Test Email"
	}
	let(:html_body) {
		"<h1>HTML message.</h1>"
	}
	let(:text_body) {
		"Text message."
	}
	let(:server) {
		{address:        "smtp.test.com",
     port:           "25",
     user_name:      "user",
     password:       "password",
     authentication: :plain,
     domain:         "localhost.localdomain"}
	}
	subject {
		TemplateMailer::MailMessage.new(html:   html_body,
                                    server: server,
                                    text:   text_body,
                                    via:    :smtp)
	}

  describe "#send()" do
  	let(:server_settings) {
  		{body:        text_body,
  		 from:        from,
  		 html_body:   html_body,
  		 subject:     title,
  		 to:          recipients,
  		 via:         :smtp,
  		 via_options: server}
  	}

  	it "invokes the Pony.mail() method when called with valid parameters" do
  		expect(Pony).to receive(:mail).with(server_settings).once
  		subject.send(from: from, recipients: recipients, subject: title)
  	end

  	it "raises an exception when invoked without specifying recipients" do
  		expect {
  			subject.send()
  		}.to raise_exception(TemplateMailer::TemplateMailerError, "No recipients specified for email.")
  	end

  	it "raises an exception when invoked with an empty recipient list" do
  		expect {
  			subject.send(recipients: [])
  		}.to raise_exception(TemplateMailer::TemplateMailerError, "No recipients specified for email.")
  	end

  	it "raises an exception when invoked with a blank recipient string" do
  		expect {
  			subject.send(recipients: "")
  		}.to raise_exception(TemplateMailer::TemplateMailerError, "No recipients specified for email.")
  	end
  end
end
