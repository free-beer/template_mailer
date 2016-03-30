# TemplateMailer

The Template Mailer library provides functionality to encapsulate the creation
and dispatch of emails. The emails sent by the library are created from templates
stored locally and allows for the creation of emails that are both HTML and/or
textual based. The library makes use of the [Tilt](https://github.com/rtomayko/tilt)
template library and the [Pony](https://github.com/benprew/pony) libraries and
aspects of these interactions are exposed via configuration settings.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'template_mailer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install template_mailer

## Usage

To make use of the library you first need to require in the Tilt functionality
for the templating systems that you want to support and then require in the
template mailer library. So, for example, if you wanted to make use of ERB as
your templating engine then you would do the following...

```ruby
require "tilt/erb"
require "template_mailer"
```

Next you want to create a ```Mailer``` class instance. To do this you will need
to specify a number of configuration settings as parameters to the constructor.
The parameters needed include the path to the directory containing your template
files as well as the mechanism that you want to use when dispatching emails. The
default mechanism, inherited from Pony, is ```sendmail``` but throughout the
rest of this document the assumption will be that you want to send your email via
an SMTP server. So, assuming your templates are stored in the ```/templates```
folder the code to create a ```Mailer``` might look as follows...

```ruby
mailer = TemplateMailer::Mailer.new(directory: "/templates",
                                    server: {address:              'mymail.smtp.com',
														   port:                 '587',
														   enable_starttls_auto: true,
														   user_name:            'mymailuser',
														   password:             'password',
														   authentication:       :login,
														   domain:               "mydomain.com"},
                                    via: :smtp)
```

Once you have a ```Mailer``` instance you can use it to create an email. To create
an email you call the ```generate_mail()``` method on the mailer and give it the
name of the template that you want to generate the email from. The template name
equates to the name of the file or files containing the templates to be generated
minus any extensions. So, for example, if you had a template file in the template
directory called ```test_message.html.erb``` then the template name to specify to
the ```Mailer``` would be ```test_message```.

Note that if you want your email message to contain details for HTML and text only
based clients then create to files in the template directory with ```.text``` and
```.html``` extension. The ```Mailer``` will find both of these templates and
generate content from them both for the email message to be sent.

Note that when calling ```generate_mail()``` you can pass a Hash of context
parmaeters as the second parameter to the method call. The values within this
Hash will be available to populate the message templates with. So, for example,
if you wanted to pass in a parameter called full name you would make a call that
looked like this...

```ruby
mailer.generate_mail("my_template", full_name: "John Smith")
```

To send the email generated simply call ```send()``` on the value returned from
the call to the ```generate_mail()``` method. The call to ```send()``` should be
accompanied by the final set of details needed to send the email such as the list
of recipients for the message, the title to be given to the email and possibly the
email address that the message will appear to come from. For example, a send
might look as follows...

```ruby
mailer.send(from: "me@mydomain.com",
            recipients: ["first.person@mydomain.com", "second.person@mydomain.com"],
            subject: "Test Message")
```

### Advanced Usage

Having all potential email templates within a single directory could ultimately
become difficult to manage. To support a hierarchical directory structure an
instance of the ```Mailer``` class will support stepping down through a list of
subdirectories to pick out a particular template. For example, lets say that you
wanted to keep all emails relating to account creation and maintenance in a
subdirectory beneath the mail template directory called ```accounts```. To send
a template called ```create``` from this directory you could create the
```Mailer``` as outlined above and then do the following...

```ruby
message = mailer.accounts.generate_mail("create")
```

The call to ```mailer.accounts``` automatically creates a new ```Mailer``` instance
based on the subdirectory. As this works this way you can chain calls like this
together so, if you had a template called 'verify' that was stored in a subfolder
of the accounts folder called create you could create a messasge based on it as
follows...

```ruby
message = mailer.accounts.create.generate_mail("verify")
```

Note that the call to ```generate_mail()``` here can be replaced with the name of
the template as the ```Mailer``` instance will recognise that this relates to an
existing template and automatically call ```generate_mail()``` for you. This
means that previous call could be changed to...

```ruby
message = mailer.account.create.verify
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/template_mailer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
