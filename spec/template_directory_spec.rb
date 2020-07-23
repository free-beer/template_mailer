require "tilt/erb"

describe TemplateMailer::TemplateDirectory do
	let(:path) {
		File.join(Dir.getwd, "spec", "data")
	}
	subject {
		TemplateMailer::TemplateDirectory.new(path)
	}

    describe "construction" do
        it "doesn't get trip up by directories that have names matching template types" do
            expect {
                TemplateMailer::TemplateDirectory.new(File.join(path, "dir_name_check"))
            }.not_to raise_error
        end
    end

	describe "#path()" do
		it "returns the path to the template directory" do
			expect(subject.path).to eq(path)
		end
	end

	describe "#template_files()" do
		let(:file_paths) {
			Dir.glob(File.join(path, "*.erb"))
		}

		it "returns a list of matching template paths for the directory" do
			paths = subject.template_files
			expect(paths.size).to eq(file_paths.size)
			file_paths.each do |file_path|
				expect(paths).to include(file_path)
			end
		end
	end

	describe "#exists?()" do
		it "returns true for a template that exists" do
			expect(subject.exists?("test_template_2")).to eq(true)
		end

		it "returns false for a template that does not exist" do
			expect(subject.exists?("does_not_exist")).to eq(false)
		end
	end

	describe "#template_paths()" do
		let(:paths) {
			[File.join(path, "test_template_3.html.erb")]
		}

		it "returns a list of template paths given an existing template name" do
			expect(subject.template_paths("test_template_3")).to eq(paths)
		end

		it "returns an empty array if given the name of a template that does not exist" do
			expect(subject.template_paths("does_not_exist")).to eq([])
		end
	end
end
