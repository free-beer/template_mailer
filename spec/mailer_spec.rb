describe TemplateMailer::Mailer do
	let(:template_directory) {
		File.join(Dir.getwd, "spec", "data")
	}
	let(:subdirectory) {
		"more_templates"
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
		TemplateMailer::Mailer.new(directory: template_directory,
			                         server:    server,
			                         via:       :smtp)
	}

	describe "#directory()" do
		it "returns a String containing the template directory path" do
			expect(subject.directory).to eq(template_directory)
		end
	end

	describe "#subdirectory()" do
		let(:subdirectory_path) {
			File.join(template_directory, subdirectory)
		}

		it "creates a new Mailer instance pointing at the appropriate subdirectory" do
			mailer = subject.subdirectory(subdirectory)
			expect(mailer).not_to be_nil
			expect(mailer.class).to eq(TemplateMailer::Mailer)
			expect(mailer.directory).to eq(subdirectory_path)
		end
	end

	describe "#generate_mail()" do
		it "generates a MailMessage with appropriate content" do
			message = subject.generate_mail("test_template_4", one: 1, two: "TWO")
			expect(message).not_to be_nil
			expect(message.class).to eq(TemplateMailer::MailMessage)
			expect(message.html).to eq("<h1>T4: 1, 'TWO'</h1>")
			expect(message.text).to eq("T4: 1, 'TWO'")
		end
	end

	describe "#method_missing()" do
		it "calls the #subdirectory() method if the method invoked matches a subdirectory name" do
			expect(subject).to receive(:subdirectory).with(subdirectory.to_sym).once
			subject.more_templates
		end

		it "calls the #generate_mail() method of the method invoked matches a template" do
			expect(subject).to receive(:generate_mail).with(:test_template_2, {}).once
			subject.test_template_2
		end
	end
end
