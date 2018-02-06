# Content Tagger

Content Tagger is the publishing application for the Topic Taxonomy on
GOV.UK. It also provides some functionality for tagging content in
bulk.

## Technical documentation

This is a Ruby on Rails application. It stores some data in a
PostgreSQL database, but for managing taxons and tagging content, it
interacts with the Publishing API.

### Permissions

Users need to have either the `GDS Editor` or the `Tagathon
participant` permission to access this application.

 - **GDS Editor** users will have full unrestricted access to the
   GOV.UK taxonomy and navigation tools
 - **Tagathon participant** users have restricted access to the
   Tagathon Project bulk tagger and analytics tools

### Running the application locally

For the purposes of local development, it's easiest to run this in a
Rails console locally to give yourself admin access to the
application.

```
User.first.update permissions: ["signin", "GDS Editor"]
```

## Features

### Managing the Topic Taxonomy

Content Tagger can create, edit and unpublish taxons. It also can view
the content tagged to a taxon, and how this has changed over time.

### Tagging content

Content Tagger has a "Projects" function for tagging content in bulk
to the Topic Taxonomy. It also supports tagging individual pages.

## Screenshots

![Tagging content](docs/screenshots/taggings.png)
![Taxons](docs/screenshots/taxons.png)
![Education taxon](docs/screenshots/education-taxon.png)
![Bubbles visualisation](docs/screenshots/education-taxon-bubbles.png)
![List visualisation](docs/screenshots/education-taxon-list.png)
![Editing a taxon](docs/screenshots/education-taxon-edit.png)
![Tagging projects](docs/screenshots/projects.png)

### Dependencies

- [alphagov/publishing-api](https://github.com/alphagov/publishing-api)

### Running the application

```
$ bowl content-tagger
```

If you're using the VM, the app should appear on
[http://content-tagger.dev.gov.uk/](http://content-tagger.dev.gov.uk/).

### Running the test suite

```
$ bundle exec rspec
```

## Licence

[MIT License](LICENCE)
