<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<html>
<head>
    <title>员工管理</title>
    <%@ include file="common.jsp"%>
    <script>
        $(function () {
            var employeeDatagrid = $('#employee_datagrid');
            var employeeForm = $('#employee_form');
            var employeeDialog = $('#employee_dialog');

            var cmdObject = {
                toSave:function () {
                    employeeForm.form('clear');
                    employeeDialog.dialog('setTitle', '新增');
                    employeeDialog.dialog('open');
                },
                toUpdate:function () {
                    var row = employeeDatagrid.datagrid('getSelected');
                    if(!row){
                        $.messager.alert('温馨提示', '未选中一行！', 'error');
                        return;
                    }

                    employeeForm.form('clear');
                    employeeDialog.dialog('setTitle', '编辑');
                    row['dept.id'] = row.dept.id;
                    employeeForm.form('load', row);

                    // 回显角色
                    $.get("/employee/queryRoleByEmployee?employeeId=" + row.id, function (data) {
                        var roleIds = $.map(data, function (row, index) {
                            return row.id;
                        })
                        $('#employee_role_combobox').combobox('setValues', roleIds);
                    }, "json");

                    employeeDialog.dialog('open');
                },
                save:function () {
                    var url = $('[name="id"]').val() ? '/employee/update' : '/employee/save';
                    employeeForm.form('submit', {
                        url:url,
                        onSubmit: function(param){
                            var roleIds = $('#employee_role_combobox').combobox('getValues');
                            $.each(roleIds, function (index, roleId) {
                                param["roles[" + index + "].id"] = roleId;
                            });
                        },
                        success:function (data) {
                            data = JSON.parse(data);
                            if(!data.success){
                                $.messager.alert('温馨提示', data.msg, 'error');
                                return;
                            }
                            $.messager.alert('温馨提示', data.msg, 'info', function () {
                                employeeDialog.dialog('close');
                                employeeDatagrid.datagrid('reload');
                            });
                        }
                    })
                },
                leave:function () {
                    var row = employeeDatagrid.datagrid('getSelected');
                    if(!row){
                        $.messager.alert('温馨提示', '未选中一行！', 'error');
                        return;
                    }
                    $.messager.confirm('温馨提示', '确定离职该员工吗？', function (flag) {
                        if(flag){
                            $.post('/employee/leave?id=' + row.id, function (data) {
                                if(!data.success){
                                    $.messager.alert('温馨提示', data.msg, 'error');
                                    return;
                                }
                                $.messager.alert('温馨提示', data.msg, 'info', function () {
                                    employeeDatagrid.datagrid('reload');
                                });
                            }, 'json');
                        }
                    })
                },
                search:function () {
                    employeeDatagrid.datagrid('load', {
                        'keyword' : $('input[name="keyword"]').val()
                    });
                },
                cancel:function () {
                    employeeDialog.dialog('close');
                }
            };

            employeeDatagrid.datagrid({
                url:'/employee/list',
                fit:true,
                fitColumns:true,
                singleSelect:true,
                toolbar:'#employee_toolbar',
                pagination:true,
                columns:[[
                    {field:'username',title:'名称',width:1,align:'center'},
                    {field:'realname',title:'姓名',width:1,align:'center'},
                    {field:'inputTime',title:'入职时间',width:1,align:'center'},
                    {field:'dept',title:'部门',width:1,align:'center',formatter:function (value,row,index) {
                        return value.name || "没有部门";
                    }},
                    {field:'tel',title:'手机',width:1,align:'center'},
                    {field:'email',title:'邮箱',width:1,align:'center'},
                    {field:'state',title:'状态',width:1,align:'center',formatter:function (value,row,index) {
                        return value == 0 ? '<span style="color: #00ee00">在职</span>' : '<span style="color: #CC2222">离职</span>';
                    }},
                    {field:'admin',title:'是管理员',width:1,align:'center',formatter:function (value,row,index) {
                        return value? "是":"否";
                    }}
                ]],
                onClickRow: function (rowIndex, rowData) {
                    $('#toUpdate, #leave').linkbutton(rowData.state == 0 ? 'enable' : 'disable');
                }
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
    <div id="employee_toolbar">
        <div>
            <%--<shiro:hasPermission name="employee:save">--%>
                <a data-cmd="toSave" href="#" class="easyui-linkbutton" data-options="iconCls:'icon-add',plain:true">新增</a>
           <%-- </shiro:hasPermission>
            <shiro:hasPermission name="employee:update">--%>
                <a data-cmd="toUpdate" href="#" class="easyui-linkbutton" data-options="iconCls:'icon-edit',plain:true">编辑</a>
           <%-- </shiro:hasPermission>
            <shiro:hasPermission name="employee:leave">--%>
                <a data-cmd="leave" href="#" class="easyui-linkbutton" data-options="iconCls:'icon-remove',plain:true">离职</a>
           <%-- </shiro:hasPermission>--%>
        </div>
        <div>
            <input type="text" name="keyword"><a data-cmd="search" href="#" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true">搜索</a>
        </div>
    </div>
    <table id="employee_datagrid"></table>

    <div id="employee_dialog" class="easyui-dialog" title="新增" style="width:500px;height:300px;"
         data-options="modal:true,closed:true,buttons:'#employee_diaglog_buttons'">
        <form id="employee_form" method="post">
            <input type="hidden" name="id">
            <table align="center" style="margin-top: 15px;">
                <tr>
                    <td>名称</td>
                    <td><input type="text" name="username"></td>
                </tr>
                <tr>
                    <td>姓名</td>
                    <td><input type="text" name="realname"></td>
                </tr>
                <tr>
                    <td>手机</td>
                    <td><input type="text" name="tel"></td>
                </tr>
                <tr>
                    <td>邮箱</td>
                    <td><input type="text" name="email"></td>
                </tr>
                <tr>
                    <td>部门</td>
                    <td><input id="employee_department" class="easyui-combobox" name="dept.id" data-options="valueField:'id',textField:'name',url:'/department/query', panelHeight:'auto'"></td>
                </tr>
                <tr>
                    <td>角色</td><td><input id="employee_role_combobox" class="easyui-combobox"
                                          data-options="multiple:true, valueField:'id',textField:'name',panelHeight:'auto',url:'/role/query'" /></td>
                </tr>
            </table>
        </form>
    </div>
    <div id="employee_diaglog_buttons">
        <a data-cmd="save" href="#" class="easyui-linkbutton" data-options="iconCls:'icon-save'">保存</a>
        <a data-cmd="cancel" href="#" class="easyui-linkbutton" data-options="iconCls:'icon-cancel'">关闭</a>
    </div>
</body>
</html>
