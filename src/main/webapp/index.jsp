<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@ page import="java.util.Map,
				 java.util.List,
				 java.util.ListIterator,
				 javax.servlet.http.HttpServletRequest, 
				 blackboard.platform.filesystem.MultipartRequest,
				 blackboard.platform.filesystem.UploadUtil,
				 java.io.File,
				 java.nio.file.Files,
				 java.nio.file.StandardCopyOption,
				 blackboard.platform.gradebook2.AttemptManager,
				 blackboard.platform.gradebook2.impl.AttemptManagerImpl,
				 blackboard.platform.gradebook2.GradebookPrivateDocumentStoreUtil,
				 blackboard.platform.gradebook2.AttemptDetail,
				 blackboard.platform.gradebook2.GradableItemManager,
				 blackboard.platform.gradebook2.impl.GradebookManagerFacade,
				 blackboard.platform.gradebook2.GradableItem,
				 blackboard.platform.gradebook2.GradeDetail,
				 blackboard.platform.gradebook2.AttemptFileType,
				 blackboard.platform.gradebook2.AttemptFileUtil,
				 blackboard.data.gradebook.impl.AttemptFile.FileType,
				 blackboard.data.gradebook.impl.AttemptFile,
				 blackboard.util.FileUtil,
				 blackboard.platform.coursecontent.AssignmentAttemptManager,
				 blackboard.platform.coursecontent.AssignmentAttemptManagerFactory,
				 blackboard.persist.gradebook.ext.AttemptFileDbPersister,
				 blackboard.persist.course.CourseMembershipDbLoader,
				 blackboard.data.course.CourseMembership,
				 blackboard.persist.Id,
				 blackboard.data.user.User,
				 blackboard.data.course.Course,
				 blackboard.data.content.Content,
				 blackboard.persist.content.ContentDbLoader,
				 blackboard.platform.filesystem.manager.GradebookFileManager,
				 blackboard.util.UrlUtil"
%>

<%@ taglib uri="/bbNG" prefix="bbNG"%>

<bbNG:genericPage
        title="Test Fuji-Xerox"
        ctxId="ctx"
        entitlement='system.admin.VIEW'
        >

        <bbNG:pageHeader 
        	instructions="Enter an Instructor ID, Content ID, Course ID, Score, and upload a PDF to post to an attempt.">
        	
        	<bbNG:breadcrumbBar environment="SYS_ADMIN" />
            
            <bbNG:pageTitleBar>
                    Fuji Xerox Test
            </bbNG:pageTitleBar>
            
        </bbNG:pageHeader> 
        
        <%
        
        	String message = "";

			if (request.getMethod().equalsIgnoreCase("post") ) {
				MultipartRequest mr = UploadUtil.processUpload(request);
		
				// Set Metadata for processing
				Id studentId = Id.generateId(User.DATA_TYPE , mr.getParameter("student_id"));
				Id assignmentId = Id.generateId(Content.DATA_TYPE, mr.getParameter("content_id"));
				Id courseId = Id.generateId(Course.DATA_TYPE, mr.getParameter("course_id"));
				String score = mr.getParameter("score");
				File gradedAssignment = mr.getFile(mr.getParameter("graded_assignment_LocalFile0"));
				String assignmentName = mr.getParameter("graded_assignment_linkTitle");
				String encodedAssignmentName = UrlUtil.encodePathSafeUrl(assignmentName);
				
				message = studentId.toString()+"|"+assignmentId.toString()+"|"+score+"|"+gradedAssignment.getAbsolutePath(); 
				
				// Get GradableItem by AssignmentId. This is the gradebook column
				GradableItemManager gm = new GradebookManagerFacade(false);
				GradableItem gi = gm.getGradebookItemByContentId(assignmentId);
				
				// Get CourseMembership from Course and UserID
				CourseMembership cm = CourseMembershipDbLoader.Default.getInstance().loadByCourseAndUserId(courseId, studentId); 
				
				// Create a new Attempt for the Gradebook Column and the Student. Update the grade
				AttemptManager am = new AttemptManagerImpl();
				AttemptDetail attempt = am.createAttempt(gi.getId(), cm.getId());
				am.updateAttemptGrade(cm.getId(), gi.getId(), attempt.getId(), Double.parseDouble(score), score);
				
				// Find the expected path to the attemptfile and create the necessary directory structure.
				GradebookFileManager gfm = new GradebookFileManager();
				File attemptDir = gfm.getAttemptDirectory(courseId, attempt.getId(), AttemptFileType.STUDENT);
				boolean result = attemptDir.mkdirs();
				
				// Create an empty file object in the attempt directory with the same name as the uploaded file.
				File newFile = new File(attemptDir.getPath()+"/"+encodedAssignmentName);
				
				// Physically create the new empty file and copy the uploaded assignment in place.
				FileUtil.createNewFile(newFile, false);
				FileUtil.copyFile(gradedAssignment, newFile);
				
				message +="<br />" + gi.getBatchUid() + "|" + cm.getBatchUID() + "|" + attempt.getDisplayGrade() + "|" + attemptDir.getAbsolutePath() + "|" +
			    			result;
				
				// Create the AttemptFile Object to update the Database. Pass all of the necessary file information
				AttemptFile attemptFile = AssignmentAttemptManagerFactory.getInstance().addAttemptFile(courseId, attempt.getId(), gradedAssignment, assignmentName, assignmentName, FileType.STUDENT);
				
				// Persist the Attemptfile Object
				AttemptFileDbPersister.Default.getInstance().persist(attemptFile);

		%>
			<%=message%>
		<% 
			}
		%>
		
        
        <bbNG:form action="index.jsp" method="POST" enctype="multipart/form-data" >
        	
        	<bbNG:dataCollection>
        		
        		<bbNG:step title="Fuji Xerox Test" instructions="Testing the Fuji Xerox use case: accepting a pdf file, assignment, and student ID, and writing to the gradebook.">
        	
        			<bbNG:dataElement label="Student ID" renderLegendAndFieldset="true">
        				<bbNG:textElement name="student_id" id="student_id" />
        			</bbNG:dataElement>
        			
        			<bbNG:dataElement label="Content ID" renderLegendAndFieldset="true">
        				<bbNG:textElement name="content_id" id="content_id" />
        			</bbNG:dataElement>
        			
        			<bbNG:dataElement label="Course ID" renderLegendAndFieldset="true">
        				<bbNG:textElement name="course_id" id="course_id" />
        			</bbNG:dataElement>
        			
        			<bbNG:dataElement label="Score" renderLegendAndFieldset="true">
        				<bbNG:textElement name="score" id="score" />
        			</bbNG:dataElement>
        			
        		</bbNG:step>
        		
        		<bbNG:step title="Upload Graded Assignment">
					<bbNG:dataElement>
						<bbNG:filePicker required="true" mode="LOCAL_FILE_ONLY" allowMultipleFiles="false" var="graded_assignment" baseElementName="graded_assignment">
							<bbNG:filePickerListElement type="FILE_NAME"/>
          					<bbNG:filePickerListElement type="LINK_TITLE"/>
        					<bbNG:filePickerListElement type="REMOVE"/>
          				</bbNG:filePicker>
					</bbNG:dataElement>
				</bbNG:step>
        		
        		<bbNG:stepSubmit />
        	
        	</bbNG:dataCollection>
        </bbNG:form>
        
</bbNG:genericPage>