<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>权限管理</title>
    <%@ include file="common.jsp"%>
    <script>
        $(function () {
            var permissionDatagrid = $('#permission_datagrid');
            var cmdObject = {
                load:function () {
                    $.messager.confirm('温馨提示', '确定加载权限吗？', function (flag) {
                        if(flag){
                            $.post('/permission/load', function (data) {
                                if(!data.success){
                                    $.messager.alert('温馨提示', data.msg, 'error');
                                    return;
                                }
                                $.messager.alert('温馨提示', data.msg, 'info', function () {
                                    permissionDatagrid.datagrid('reload');
                                });
                            }, 'json');
                        }
                    })
                }
            };

            permissionDatagrid.datagrid({
                url:'/permission/list',
                fit:true,
                fitColumns:true,
                singleSelect:true,
                toolbar:'#permission_toolbar',
                pagination:true,
                columns:[[
                    {field:'name',title:'名称',width:1,align:'center'},
                    {field:'resource',title:'姓名',width:1,align:'center'}
                ]]
            });

            $('a').click(function () {
                var cmd = $(this).data('cmd');
                if(cmd){
                    cmdObject[cmd]();
                }
            });
        });
    </script>
</head>
<body>
    <div id="permission_toolbar">
        <div>

            <a data-cmd="load" href="#" class="easyui-linkbutton" data-options="iconCls:'icon-reload',plain:true">加载</a>
        </div>
    </div>
    <table id="permission_datagrid"></table>
</body>
</html>
