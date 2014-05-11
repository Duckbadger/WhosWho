WhosWho
=======

Mobile app that provides easy access to biographies and pictures of it's employees.

##Compatibility##
Runs on iOS7+ on iPhone.


##Level 1##
This is done in the `AppBusinessProfilesFetcher` class. HTML parsing is assisted by [hpple](https://github.com/topfunky/hpple). 

Profiles are added by checking if a profile already exists in core data and adding it if it doesn't exist.

Profiles are removed by comparing a last modified date. If a profile is not in the parsed html data, then the last modified date on old profiles are not updated and those profiles are deleted.

##Level 2##
Images are optimised in a category to the Profile class. 2 versions of an image are saved, a small image and the full size image.

`+ (UIImage *)resizedImageWithData:(NSData *)data` resizes the full size image to a 150*150 image to be displayed in the profile list.

Images are cached to speed up the process of displaying images when they've been downloaded once.

##Level 3##
The application caches profiles using core data.
`CoreDataManager` and ` NSManagedObject+CoreDataManagerExtensions` was created to assist with core data calls. 

`AppBusinessProfilesFetcher` will attempt to fetch profiles from the team web page, and if no data is returned, it will continue and fetch the cached profiles.

##Additional##
The app has been branded to resemble the website, using the same orange, black, and white colours on the website.

The navigation bar is the same orange used on the website.
The list view is black to match the homepage, and the detail view is white with dark grey text to match the "Our Team" page.

Networking calls, including image downloading are run on a separate thread to not block the UI. 

Portrait and landscape orientations are supported.