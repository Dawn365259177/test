<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>角色管理</title>
    <%@ include file="common.jsp"%>
    <script>
        $(function () {
            var roleDatagrid = $('#role_datagrid');
            var roleForm = $('#role_form');
            var roleDialog = $('#role_dialog');
            var allPermissionsDatagrid = $('#all_permission_datagrid');
            var selfPermissionsDatagrid = $('#self_permission_datagrid');

            var roleMenuTree = $("#role_menu_tree");
            roleMenuTree.tree({
                url:'/systemMenu/queryForRole', // 查询所有菜单
                checkbox:true
            });
            // 当点击角色表格的一行，左边以勾选节点的方式回显角色的菜单
            function checkMenuTree(menuData, menuIds){
                for(var i = 0; i<menuData. length; i++){
                    /*if($.inArray(menuData[i].id,menuIds)>=0){
                        roleMenuTree.tree("check",menuData[i].target);
                    }else{
                        roleMenuTree.tree("uncheck",menuData[i].target);
                    }*/
                    roleMenuTree.tree($.inArray(menuData[i].id, menuIds) >= 0 ? 'check': 'uncheck', menuData[i].target);
                    var children = roleMenuTree.tree('getChildren', menuData[i].target);
                    if(children){
                        arguments.callee(children,menuIds);
                    }
                }
            }

            var srcData = {};

            roleDatagrid.datagrid({
                url:'/role/list',
                fitColumns:true,
                fit:true,
                pagination:true,
                rownumbers:true,
                singleSelect:true,
                toolbar : "#role_toolbar",
                columns:[[
                    {field:'name',title:'名称',width:1,align:'center'},
                    {field:'sn',title:'SN',width:1,align:'center'}
                ]],
                onClickRow:function(rowIndex, rowData){
                    //修改面板的标题头
                    $("#role_menu_title").panel("setTitle","角色["+rowData.name+"]的菜单");
                    //获取所有的菜单的集合
                    var menuData = roleMenuTree.tree("getRoots");
                    //需要做同步的操作需要使用 $.ajax
                    var menuIds = $.ajax({
                        url: "/systemMenu/queryMenuIdsListForRole?roleId="+rowData.id,
                        async: false//同步
                    }).responseText;
                    menuIds = $.parseJSON(menuIds);
                    checkMenuTree(menuData, menuIds);
                }
            });

            allPermissionsDatagrid.datagrid({
                url:'/permission/list?rows='+ (Math.pow(2, 31) - 1),
                title:"所有权限",
                fitColumns:true,
                width:200,
                height:280,
                rownumbers:true,
                singleSelect:true,
                columns:[[
                    {field:'name',title:'名称',width:1,align:'center'}
                ]],
                onDblClickRow: function (rowIndex, rowData) {
                    allPermissionsDatagrid.datagrid('deleteRow',rowIndex);
                    selfPermissionsDatagrid.datagrid('appendRow', rowData)
                },
                onLoadSuccess:function (data) {
                    srcData = $.extend(true, {}, data);
                }
            });

            selfPermissionsDatagrid.datagrid({
                title:"自身权限",
                fitColumns:true,
                width:200,
                height:280,
                rownumbers:true,
                singleSelect:true,
                columns:[[
                    {field:'name',title:'名称',width:1,align:'center'}
                ]],
                onDblClickRow: function (rowIndex, rowData) {
                    selfPermissionsDatagrid.datagrid('deleteRow',rowIndex);
                    allPermissionsDatagrid.datagrid('appendRow', rowData)
                },
                onLoadSuccess:function (data) {
                    // data 自身权限
                    // 去掉重复
                    var selfPermissionIds = $.map(data.rows, function (row, index) {
                        return row.id;
                    });
                    // 获取左边表格所有数据
                    var allPermissions = allPermissionsDatagrid.datagrid('getRows');
                    for(var i = allPermissions.length - 1; i >= 0; i --){
                        if($.inArray(allPermissions[i].id, selfPermissionIds) >= 0){
                            allPermissionsDatagrid.datagrid('deleteRow', i);
                        }
                    }
                }
            });

            // 统一对 a 标签的单击事件处理
            $('a').click(function () {
                var cmd = $(this).data('cmd');
                if(cmd){
                    cmdObj[cmd]();
                }
            });

            var cmdObj = {
                search:function () {
                    roleDatagrid.datagrid('load',{
                        keyword: $('input[name="keyword"]').val()
                    });
                },
                toSave:function () {
                    // 重新加载所有权限,加载缓存东西，避免频繁查询数据
                    allPermissionsDatagrid.datagrid('loadData', srcData);
                    // 清空自身的权限
                    selfPermissionsDatagrid.datagrid('loadData', {rows:[]});

                    roleForm.form('clear');
                    roleDialog.dialog('setTitle', '新增');
                    roleDialog.dialog('open');
                },
                toUpdate:function () {
                    var rowData = roleDatagrid.datagrid('getSelected');
                    if(!rowData){
                        $.messager.alert('温馨提示', '您未选中一行！','error');
                        return;
                    }

                    // 回显所有权限
                    allPermissionsDatagrid.datagrid('loadData', srcData);
                    // 回显自身权限
                    selfPermissionsDatagrid.datagrid('options').url= "/role/queryPermissionsByRole?roleId=" + rowData.id;
                    selfPermissionsDatagrid.datagrid('load');

                    roleForm.form('load', rowData);
                    roleDialog.dialog('setTitle', '编辑');
                    roleDialog.dialog('open');
                },
                save:function () {
                    var id = $('input[name="id"]').val();
                    var url = id ? '/role/update' : '/role/save';
                    roleForm.form('submit', {
                        url: url,
                        onSubmit:function (param) {
                            // 获取所有自身权限的 id
                            var rows = selfPermissionsDatagrid.datagrid('getRows');
                            $.each(rows, function (index, row) {
                                param["permissions[" + index + "].id"] = row.id;
                            });
                        },
                        success:function(data){
                            console.info(data);
                            data = JSON.parse(data); // 把JSON字符串解析成 JS 兑换 {"success":true, "msg":"xxx"}
                            if(!data.success){
                                $.messager.alert('温馨提示', data.msg,'error');
                                return;
                            }
                            $.messager.alert('温馨提示', data.msg,'info', function () {
                                // 成功之后要把对话框关闭
                                roleDialog.dialog('close');
                                roleDatagrid.datagrid('reload');
                            });
                        }

                    });
                },
                cancel:function () {
                    roleDialog.dialog('close');
                },
                menuSave:function(){
                    var rowData = roleDatagrid.datagrid("getSelected");
                    if(rowData){
                        //让用户确认是否需要添加菜单
                        $.messager.confirm("温馨提示","您确定需要给角色["+rowData.name+"]添加如下菜单吗?",function(yes){
                            if(yes){
                                var ids = [];
                                //获取所有被勾选的菜单的id集合
                                var checkedNodes = roleMenuTree.tree("getChecked");
                                var indeterminateNodes = roleMenuTree.tree('getChecked', 'indeterminate');
                                $.each(checkedNodes,function(index,item){
                                    ids.push(item.id);
                                });
                                $.each(indeterminateNodes,function(index,item){
                                    ids.push(item.id);
                                });
                                //需要把菜单的集合和对应需要保存的角色ID传递到后台.
                                $.post("/role/addMenu",{ids:ids,roleId:rowData.id},function(data){
                                    if(data.success){
                                        $.messager.alert("温馨提示",data.msg,"info");
                                    }else{
                                        $.messager.alert("温馨提示",data.msg,"error");
                                    }
                                },"json");
                            }
                        });
                    }else{
                        $.messager.alert("温馨提示","请选择右侧需要添加菜单的角色!","warning");
                    }
                }
            }
        });
    </script>
</head>
<body>
    <div id="role_toolbar">
        <div>

            <a data-cmd="toSave" href="#" class="easyui-linkbutton" data-options="iconCls:'icon-add',plain:true">新增</a>
            <a data-cmd="toUpdate" href="#" class="easyui-linkbutton" data-options="iconCls:'icon-edit',plain:true">编辑</a>
        </div>
    </div>
    <div class="easyui-layout" fit="true">
        <div id="role_menu_title" data-options="region:'west',width:180,title:'角色[--]的菜单',tools:'#role_menu_toolbar'">
            <ul id="role_menu_tree"></ul>
        </div>
        <div data-options="region:'center',title:'角色表格'">
            <!-- 数据表格 -->
            <table id="role_datagrid">
                <thead>
                <tr>
                    <th data-options="field:'sn',width:1,align:'center'">编号</th>
                    <th data-options="field:'name',width:1,align:'center'">名称</th>
                </tr>
                </thead>
            </table>
        </div>
    </div>

    <!-- 工具栏按钮 -->
    <div id="role_menu_toolbar">
        <a class="icon-save" data-cmd="menuSave"></a>
    </div>


    <div id="role_dialog" class="easyui-dialog" title="新增" style="width:500px;height:300px;"
         data-options="modal:true,closed:true,buttons:'#role_diaglog_buttons',width:600,height:400">
        <form id="role_form" method="post">
            <input type="hidden" name="id">
            <table align="center" style="margin-top: 15px;">
                <tr>
                    <td>SN：<input type="text" name="sn"></td>
                    <td>名称：<input type="text" name="name"></td>
                </tr>
                <tr>
                    <td><table id="all_permission_datagrid"></table></td>
                    <td><table id="self_permission_datagrid"></table></td>
                </tr>
            </table>
        </form>
    </div>
    <div id="role_diaglog_buttons">
        <a data-cmd="save" href="#" class="easyui-linkbutton" data-options="iconCls:'icon-save'">保存</a>
        <a data-cmd="cancel" href="#" class="easyui-linkbutton" data-options="iconCls:'icon-cancel'">关闭</a>
    </div>
</body>
</html>
