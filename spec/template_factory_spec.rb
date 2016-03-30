describe TemplateMailer::TemplateFactory do
	let(:directory) {
		File.join(Dir.getwd, "spec", "data")
	}
	subject {
		TemplateMailer::TemplateFactory.new(directory)
	}

	describe "#directory()" do
		it "returns the path to the template directory" do
			expect(subject.directory).to eq(directory)
		end
	end

	describe "#manufacture()" do
		let(:context) {
			{one: 1, two: "Two"}
		}
		let(:templates) {
			{html: "<h1>T4: 1, 'Two'</h1>",
			 text: "T4: 1, 'Two'",
			 txt:  "T4: 1, 'Two'"}
		}

		it "returns an empty Hash if given the name of a template that does not exist" do
			expect(subject.manufacture("does_not_exist")).to eq({})
		end

		it "generates template entries for all available template files" do
			expect(subject.manufacture("test_template_4", context)).to eq(templates)
		end
	end

	describe "#manufacture!()" do
		it "raises an exception if a matching template is not found" do
			expect {
				subject.manufacture!("does_not_exist")
			}.to raise_exception(TemplateMailer::TemplateMailerError, "Unable to locate a template with the name 'does_not_exist'.")
		end
	end
end
