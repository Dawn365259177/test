<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>叩丁狼客户关系管理系统</title>
    <link rel="stylesheet" type="text/css" href="/static/css/style.css"/>
    <script type="text/javascript" src="/static/jquery-easyui/jquery.min.js"></script>
    <script type="text/javascript" src="/static/jquery-easyui/jquery.easyui.min.js"></script>
    <script>
        $(function () {
            $('#loginBtn').click(function () {
                $('#loginForm').form('submit', {
                    url: "/login",
                    success: function (data) {
                        data = JSON.parse(data);
                        if (!data.success) {
                            alert(data.msg);
                            return;
                        }
                        window.location.href = "/index";
                    }
                });
            });
        });
    </script>
</head>
<body>
<section class="container">
    <div class="login">
        <h1>用户登录</h1>
        <form id="loginForm" method="post">
            <p><input type="text" name="username" value="" placeholder="账号"></p>
            <p><input type="password" name="password" value="" placeholder="密码"></p>
            <p class="submit">
                <input id="loginBtn" type="button" value="登录">
                <input type="button" value="重置">
            </p>
        </form>
    </div>
</section>
<div style="text-align:center;" class="login-help">
    <p>Copyright ©2017 广州狼码教育科技有限公司</p>
</div>
</body>
</html>
