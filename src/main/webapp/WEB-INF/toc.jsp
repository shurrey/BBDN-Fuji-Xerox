<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@ page import="java.util.List,
                 java.util.ListIterator,
                 blackboard.data.course.*,
                 blackboard.data.content.*,
                 blackboard.data.navigation.*,
                 blackboard.platform.BbServiceManager,
                 blackboard.platform.persistence.PersistenceServiceFactory,
                 blackboard.persist.course.*,
                 blackboard.persist.content.*,
                 blackboard.persist.navigation.*,
                 blackboard.persist.BbPersistenceManager,
                 blackboard.persist.Id,
                 blackboard.persist.UnsetId,
                 blackboard.platform.plugin.PlugInUtil,
                 blackboard.platform.coursemenu.CourseTocManagerFactory"%>
                 
<%@ taglib uri="/bbNG" prefix="bbNG"%>

<bbNG:genericPage ctxId="ctx">

  <bbNG:pageHeader instructions="Add a link to the TOC">
    <bbNG:pageTitleBar title="Modify TOC" />
  </bbNG:pageHeader>
  
<%
   
	Id courseId = ctx.getCourseId();
	String linkuri = PlugInUtil.getUri("bb", "starting-block", "execute/help");
	String linktext = "Starting Block Help";
	List< CourseToc > tocList = CourseTocDbLoader.Default.getInstance().loadByCourseId( courseId );
	CourseToc ct = CourseTocManagerFactory.getInstance().createExternalLink( courseId, linktext, true, linkuri );
	CourseTocManagerFactory.getInstance().createToolLink(courseId, name, enabled, toolIdentifier);
	ct.getUrl();
	ct.
	ct.setPosition( tocList.size() );
	ct.setIsEnabled( true );
	ct.setLaunchInNewWindow( true );
	CourseTocDbPersister.Default.getInstance().persist( ct );
	
	ct.
%>
</bbNG:genericPage>
