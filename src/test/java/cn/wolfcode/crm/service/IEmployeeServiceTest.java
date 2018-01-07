package cn.wolfcode.crm.service;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("classpath:applicationContext.xml")
public class IEmployeeServiceTest {

    @Autowired
  //  private IEmployeeService employeeService;

    @Test
    public void save() {
       /* Employee employee = new Employee();
        employee.setUsername("zhangsan");
        employee.setRealname("张三");
        //employee.SE(1L);
        employee.setTel("13591239812");
        employee.setEmail("zhangsan@126.com");
        employee.setAdmin(true);
        employeeService.save(employee);*/
    }
}
