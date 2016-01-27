# BBDN-Fuji-Xerox
=================
Takes a PDF, Score, User ID, Content ID, and Course ID, and creates an attempt in the gradebook, posts a score and the pdf.

*This project was tested on April 2014, October 2014, and Q4 2015. It uses many private APIs, so use at your own risk. Also tested on SP14, but it doesn't work on that release.

How To Use This Project
====
This sample has a simple JSP presented as a System Tool on the System Admin Panel. You will need a course, a student, and an assignment with a Gradebook column. You will also need their corresponding IDs, in _X_X format to enter into the text box on the page. 

Simply Navigate to the system admin panel, and look in the Tools module for Fuji Xerox Sample. On the form, enter the Course, Content, and User IDs, the score, and use the file picker to select a file. Click submit.

The form will reload and you will see some text at the top of the page. Now you should be able to navigate to the grade center in the course and view the assignment. You can download the file you just uploaded. You can also log in as the student and look at the 'My Grades' tool to see the document and download the file, as well.


Deploying Your B2
===
To deploy your B2 for testing, run `gradlew deployB2`.
