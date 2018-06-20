@api
Feature: webdav-related
	Background:
		Given using API version "1"

	Scenario Outline: Unauthenticated call
		Given using <dav_version> DAV path
		When an unauthenticated client connects to the dav endpoint using the API
		Then the HTTP status code should be "401"
		And there should be no duplicate headers
		And the following headers should be set
			| WWW-Authenticate | Basic realm="ownCloud", charset="UTF-8" |
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Moving a file
		Given using <dav_version> DAV path
		And user "user0" has been created
		When user "user0" moves file "/welcome.txt" to "/FOLDER/welcome.txt" using the API
		Then the HTTP status code should be "201"
		And the downloaded content when downloading file "/FOLDER/welcome.txt" for user "user0" with range "bytes=0-6" should be "Welcome"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Moving and overwriting a file
		Given using <dav_version> DAV path
		And user "user0" has been created
		When user "user0" moves file "/welcome.txt" to "/textfile0.txt" using the API
		Then the HTTP status code should be "204"
		And the downloaded content when downloading file "/textfile0.txt" for user "user0" with range "bytes=0-6" should be "Welcome"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Moving a file to a folder with no permissions
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user1" has been created
		And user "user1" has created a folder "/testshare"
		And user "user1" has created a share with settings
			| path        | testshare |
			| shareType   | 0         |
			| permissions | 1         |
			| shareWith   | user0     |
		When user "user0" moves file "/textfile0.txt" to "/testshare/textfile0.txt" using the API
		Then the HTTP status code should be "403"
		When user "user0" downloads the file "/testshare/textfile0.txt" using the API
 		Then the HTTP status code should be "404"
 		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Moving a file to overwrite a file in a folder with no permissions
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user1" has been created
		And user "user1" has created a folder "/testshare"
		And user "user1" has created a share with settings
			| path        | testshare |
			| shareType   | 0         |
			| permissions | 1         |
			| shareWith   | user0     |
		And user "user1" has copied file "/welcome.txt" to "/testshare/overwritethis.txt"
		When user "user0" moves file "/textfile0.txt" to "/testshare/overwritethis.txt" using the API
		Then the HTTP status code should be "403"
		And the downloaded content when downloading file "/testshare/overwritethis.txt" for user "user0" with range "bytes=0-6" should be "Welcome"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: move file into a not-existing folder
		Given using <dav_version> DAV path
		And user "user0" has been created
		When user "user0" moves file "/welcome.txt" to "/not-existing/welcome.txt" using the API
		Then the HTTP status code should be "409"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: rename a file into an invalid filename
		Given using <dav_version> DAV path
		And user "user0" has been created
		When user "user0" moves file "/welcome.txt" to "/a\\a" using the API
		Then the HTTP status code should be "400"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: rename a file into a banned filename
		Given using <dav_version> DAV path
		And user "user0" has been created
		When user "user0" moves file "/welcome.txt" to "/.htaccess" using the API
		Then the HTTP status code should be "403"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Copying a file
		Given using <dav_version> DAV path
		And user "user0" has been created
		When user "user0" copies file "/welcome.txt" to "/FOLDER/welcome.txt" using the API
		Then the HTTP status code should be "201"
		And the downloaded content when downloading file "/FOLDER/welcome.txt" for user "user0" with range "bytes=0-6" should be "Welcome"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Copying and overwriting a file
		Given using <dav_version> DAV path
		And user "user0" has been created
		When user "user0" copies file "/welcome.txt" to "/textfile1.txt" using the API
		Then the HTTP status code should be "204"
		And the downloaded content when downloading file "/textfile1.txt" for user "user0" with range "bytes=0-6" should be "Welcome"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Copying a file to a folder with no permissions
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user1" has been created
		And user "user1" has created a folder "/testshare"
		And user "user1" has created a share with settings
			| path        | testshare |
			| shareType   | 0         |
			| permissions | 1         |
			| shareWith   | user0     |
		When user "user0" copies file "/textfile0.txt" to "/testshare/textfile0.txt" using the API
		Then the HTTP status code should be "403"
		And user "user0" downloads the file "/testshare/textfile0.txt" using the API
		And the HTTP status code should be "404"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Copying a file to overwrite a file into a folder with no permissions
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user1" has been created
		And user "user1" has created a folder "/testshare"
		And user "user1" has created a share with settings
			| path        | testshare |
			| shareType   | 0         |
			| permissions | 1         |
			| shareWith   | user0     |
		And user "user1" has copied file "/welcome.txt" to "/testshare/overwritethis.txt"
		When user "user0" copies file "/textfile0.txt" to "/testshare/overwritethis.txt" using the API
		Then the HTTP status code should be "403"
		And the downloaded content when downloading file "/testshare/overwritethis.txt" for user "user0" with range "bytes=0-6" should be "Welcome"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: download a file with range
		Given using <dav_version> DAV path
		And user "user0" has been created
		When user "user0" downloads file "/welcome.txt" with range "bytes=51-77" using the API
		Then the downloaded content should be "example file for developers"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Retrieving folder quota when no quota is set
		Given using <dav_version> DAV path
		And user "user0" has been created
		When the administrator gives unlimited quota to user "user0" using the API
		And user "user0" gets the following properties of folder "/" using the API
		  |{DAV:}quota-available-bytes|
		Then the single response should contain a property "{DAV:}quota-available-bytes" with value "-3"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Retrieving folder quota when quota is set
		Given using <dav_version> DAV path
		And user "user0" has been created
		When the administrator sets the quota of user "user0" to "10 MB" using the API
		And user "user0" gets the following properties of folder "/" using the API
		  |{DAV:}quota-available-bytes|
		Then the single response should contain a property "{DAV:}quota-available-bytes" with value "10485358"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Retrieving folder quota of shared folder with quota when no quota is set for recipient
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user1" has been created
		And user "user0" has been given unlimited quota
		And the quota of user "user1" has been set to "10 MB"
		And user "user1" has created a folder "/testquota"
		And user "user1" has created a share with settings
			| path        | testquota |
			| shareType   | 0         |
			| permissions | 31        |
			| shareWith   | user0     |
		When user "user0" gets the following properties of folder "/testquota" using the API
		  |{DAV:}quota-available-bytes|
		Then the single response should contain a property "{DAV:}quota-available-bytes" with value "10485358"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Retrieving folder quota when quota is set and a file was uploaded
		Given using <dav_version> DAV path
		And user "user0" has been created
		And the quota of user "user0" has been set to "1 KB"
		And user "user0" has added file "/prueba.txt" of 93 bytes
		When user "user0" gets the following properties of folder "/" using the API
		  |{DAV:}quota-available-bytes|
		Then the single response should contain a property "{DAV:}quota-available-bytes" with value "529"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Retrieving folder quota when quota is set and a file was recieved
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user1" has been created
		And the quota of user "user1" has been set to "1 KB"
		And user "user0" has added file "/user0.txt" of 93 bytes
		And user "user0" has shared file "user0.txt" with user "user1"
		When user "user1" gets the following properties of folder "/" using the API
		  |{DAV:}quota-available-bytes|
		Then the single response should contain a property "{DAV:}quota-available-bytes" with value "622"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: download a public shared file with range
		Given using <dav_version> DAV path
		And user "user0" has been created
		When user "user0" creates a share using the API with settings
			| path      | welcome.txt |
			| shareType | 3           |
		And the public downloads the last public shared file with range "bytes=51-77" using the API
		Then the downloaded content should be "example file for developers"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: download a public shared file inside a folder with range
		Given using <dav_version> DAV path
		And user "user0" has been created
		When user "user0" creates a share using the API with settings
			| path      | PARENT |
			| shareType | 3      |
		And the public downloads file "/parent.txt" from inside the last public shared folder with range "bytes=1-7" using the API
		Then the downloaded content should be "wnCloud"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Downloading a file should serve security headers
		Given using <dav_version> DAV path
		And user "user0" has been created
		When user "user0" downloads the file "/welcome.txt" using the API
		Then the following headers should be set
			| Content-Disposition               | attachment; filename*=UTF-8''welcome.txt; filename="welcome.txt" |
			| Content-Security-Policy           | default-src 'none';                                              |
			| X-Content-Type-Options            | nosniff                                                          |
			| X-Download-Options                | noopen                                                           |
			| X-Frame-Options                   | SAMEORIGIN                                                       |
			| X-Permitted-Cross-Domain-Policies | none                                                             |
			| X-Robots-Tag                      | none                                                             |
			| X-XSS-Protection                  | 1; mode=block                                                    |
		And the downloaded content should start with "Welcome to your ownCloud account!"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: A file that is not shared does not have a share-types property
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user0" has created a folder "/test"
		When user "user0" gets the following properties of folder "/test" using the API
			|{http://owncloud.org/ns}share-types|
		Then the response should contain an empty property "{http://owncloud.org/ns}share-types"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: A file that is shared to a user has a share-types property
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/test"
		And user "user0" has created a share with settings
			| path        | test  |
			| shareType   | 0     |
			| permissions | 31    |
			| shareWith   | user1 |
		When user "user0" gets the following properties of folder "/test" using the API
			|{http://owncloud.org/ns}share-types|
		Then the response should contain a share-types property with
			| 0 |
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: A file that is shared to a group has a share-types property
		Given using <dav_version> DAV path
		And user "user0" has been created
		And group "group1" has been created
		And user "user0" has created a folder "/test"
		And user "user0" has created a share with settings
			| path        | test   |
			| shareType   | 1      |
			| permissions | 31     |
			| shareWith   | group1 |
		When user "user0" gets the following properties of folder "/test" using the API
			|{http://owncloud.org/ns}share-types|
		Then the response should contain a share-types property with
			| 1 |
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: A file that is shared by link has a share-types property
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user0" has created a folder "/test"
		And user "user0" has created a share with settings
			| path        | test |
			| shareType   | 3    |
			| permissions | 31   |
		When user "user0" gets the following properties of folder "/test" using the API
			|{http://owncloud.org/ns}share-types|
		Then the response should contain a share-types property with
			| 3 |
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: A file that is shared by user,group and link has a share-types property
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user1" has been created
		And group "group2" has been created
		And user "user0" has created a folder "/test"
		And user "user0" has created a share with settings
			| path        | test  |
			| shareType   | 0     |
			| permissions | 31    |
			| shareWith   | user1 |
		And user "user0" has created a share with settings
			| path        | test   |
			| shareType   | 1      |
			| permissions | 31     |
			| shareWith   | group2 |
		And user "user0" has created a share with settings
			| path        | test  |
			| shareType   | 3     |
			| permissions | 31    |
		When user "user0" gets the following properties of folder "/test" using the API
			|{http://owncloud.org/ns}share-types|
		Then the response should contain a share-types property with
			| 0 |
			| 1 |
			| 3 |
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: A disabled user cannot use webdav
		Given using <dav_version> DAV path
		And user "userToBeDisabled" has been created
		And user "userToBeDisabled" has been disabled
		When user "userToBeDisabled" downloads the file "/welcome.txt" using the API
		Then the HTTP status code should be "401"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Creating a folder
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user0" has created a folder "/test_folder"
		When user "user0" gets the following properties of folder "/test_folder" using the API
		  |{DAV:}resourcetype|
		Then the single response should contain a property "{DAV:}resourcetype" with value "{DAV:}collection"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Creating a folder with special chars
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user0" has created a folder "/test_folder:5"
		When user "user0" gets the following properties of folder "/test_folder:5" using the API
		  |{DAV:}resourcetype|
		Then the single response should contain a property "{DAV:}resourcetype" with value "{DAV:}collection"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Removing everything of a folder
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user0" has moved file "/welcome.txt" to "/FOLDER/welcome.txt"
		And user "user0" has created a folder "/FOLDER/SUBFOLDER"
		And user "user0" has copied file "/textfile0.txt" to "/FOLDER/SUBFOLDER/testfile0.txt"
		When user "user0" deletes everything from folder "/FOLDER/" using the API
		Then user "user0" should see the following elements
			| /FOLDER/           |
			| /PARENT/           |
			| /PARENT/parent.txt |
			| /textfile0.txt     |
			| /textfile1.txt     |
			| /textfile2.txt     |
			| /textfile3.txt     |
			| /textfile4.txt     |
		And user "user0" should not see the following elements
			| /FOLDER/SUBFOLDER/              |
			| /FOLDER/welcome.txt             |
			| /FOLDER/SUBFOLDER/testfile0.txt |
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Checking file id after a move
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user0" has stored id of file "/textfile0.txt"
		When user "user0" moves file "/textfile0.txt" to "/FOLDER/textfile0.txt" using the API
		Then user "user0" file "/FOLDER/textfile0.txt" should have the previously stored id
		And user "user0" should not see the following elements
			| /textfile0.txt |
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Renaming a folder to a backslash encoded should return an error
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user0" has created a folder "/testshare"
		When user "user0" moves folder "/testshare" to "/%5C" using the API
		Then the HTTP status code should be "400"
		And user "user0" should see the following elements
			| /testshare/ |
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Renaming a folder beginning with a backslash encoded should return an error
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user0" has created a folder "/testshare"
		When user "user0" moves folder "/testshare" to "/%5Ctestshare" using the API
		Then the HTTP status code should be "400"
		And user "user0" should see the following elements
			| /testshare/ |
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Renaming a folder including a backslash encoded should return an error
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user0" has created a folder "/testshare"
		When user "user0" moves folder "/testshare" to "/hola%5Chola" using the API
		Then the HTTP status code should be "400"
		And user "user0" should see the following elements
			| /testshare/ |
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Renaming a folder into a banned name
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user0" has created a folder "/testshare"
		When user "user0" moves folder "/testshare" to "/.htaccess" using the API
		Then the HTTP status code should be "403"
		And user "user0" should see the following elements
			| /testshare/ |
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Move a folder into a not existing one
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user0" has created a folder "/testshare"
		When user "user0" moves folder "/testshare" to "/not-existing/testshare" using the API
		Then the HTTP status code should be "409"
		And user "user0" should see the following elements
			| /testshare/ |
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Downloading a file should serve security headers
		Given using <dav_version> DAV path
		And user "user0" has been created
		When user "user0" downloads the file "/welcome.txt" using the API
		Then the following headers should be set
			| Content-Disposition               | attachment; filename*=UTF-8''welcome.txt; filename="welcome.txt" |
			| Content-Security-Policy           | default-src 'none';                                              |
			| X-Content-Type-Options            | nosniff                                                          |
			| X-Download-Options                | noopen                                                           |
			| X-Frame-Options                   | SAMEORIGIN                                                       |
			| X-Permitted-Cross-Domain-Policies | none                                                             |
			| X-Robots-Tag                      | none                                                             |
			| X-XSS-Protection                  | 1; mode=block                                                    |
		And the downloaded content should start with "Welcome to your ownCloud account!"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Doing a GET with a web login should work without CSRF token on the new backend
		Given user "user0" has been created
		And using <dav_version> DAV path
		And user "user0" has logged in to a web-style session using the API
		When the client sends a "GET" to "/remote.php/dav/files/user0/welcome.txt" without requesttoken using the API
		Then the downloaded content should start with "Welcome to your ownCloud account!"
		And the HTTP status code should be "200"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Doing a GET with a web login should work with CSRF token on the new backend
		Given user "user0" has been created
		And using <dav_version> DAV path
		And user "user0" has logged in to a web-style session using the API
		When the client sends a "GET" to "/remote.php/dav/files/user0/welcome.txt" with requesttoken using the API
		Then the downloaded content should start with "Welcome to your ownCloud account!"
		And the HTTP status code should be "200"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Doing a PROPFIND with a web login should work with CSRF token on the new backend
		Given user "user0" has been created
		And using <dav_version> DAV path
		And user "user0" has logged in to a web-style session using the API
		When the client sends a "PROPFIND" to "/remote.php/dav/files/user0/welcome.txt" with requesttoken using the API
		Then the HTTP status code should be "207"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Setting custom DAV property and reading it
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user0" has uploaded file "data/textfile.txt" to "/testcustomprop.txt"
		And user "user0" has set property "{http://whatever.org/ns}very-custom-prop" of file "/testcustomprop.txt" to "veryCustomPropValue"
		When user "user0" gets a custom property "{http://whatever.org/ns}very-custom-prop" of file "/testcustomprop.txt"
		Then the response should contain a custom "{http://whatever.org/ns}very-custom-prop" property with "veryCustomPropValue"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Setting custom DAV property and reading it after the file is renamed
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user0" has uploaded file "data/textfile.txt" to "/testcustompropwithmove.txt"
		And user "user0" has set property "{http://whatever.org/ns}very-custom-prop" of file "/testcustompropwithmove.txt" to "valueForMovetest"
		And user "user0" has moved file "/testcustompropwithmove.txt" to "/catchmeifyoucan.txt"
		When user "user0" gets a custom property "{http://whatever.org/ns}very-custom-prop" of file "/catchmeifyoucan.txt"
		Then the response should contain a custom "{http://whatever.org/ns}very-custom-prop" property with "valueForMovetest"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Setting custom DAV property on a shared file as an owner and reading as a recipient
		Given using <dav_version> DAV path
		And user "user0" has been created
		And user "user1" has been created
		And user "user0" has uploaded file "data/textfile.txt" to "/testcustompropshared.txt"
		And user "user0" has created a share with settings
			| path        | testcustompropshared.txt |
			| shareType   | 0                        |
			| permissions | 31                       |
			| shareWith   | user1                    |
		And user "user0" has set property "{http://whatever.org/ns}very-custom-prop" of file "/testcustompropshared.txt" to "valueForSharetest"
		When user "user1" gets a custom property "{http://whatever.org/ns}very-custom-prop" of file "/testcustompropshared.txt"
		Then the response should contain a custom "{http://whatever.org/ns}very-custom-prop" property with "valueForSharetest"
		Examples:
			| dav_version   |
			| old           |
			| new           |

	Scenario Outline: Setting custom DAV property using one endpoint and reading it with other endpoint
		Given using <action_dav_version> DAV path	
		And user "user0" has been created	
		And user "user0" has uploaded file "data/textfile.txt" to "/testnewold.txt"	
		And user "user0" has set property "{http://whatever.org/ns}very-custom-prop" of file "/testnewold.txt" to "lucky"	
		And using <other_dav_version> DAV path	
		When user "user0" gets a custom property "{http://whatever.org/ns}very-custom-prop" of file "/testnewold.txt"	
		Then the response should contain a custom "{http://whatever.org/ns}very-custom-prop" property with "lucky"
		Examples:
		| action_dav_version | other_dav_version |
		| old                | new               |
		| new                | old               |