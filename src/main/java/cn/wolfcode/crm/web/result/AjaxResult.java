package cn.wolfcode.crm.web.result;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class AjaxResult {
    private boolean success;
    private String msg;

    public AjaxResult(String msg) {
        this.msg = msg;
    }

    public AjaxResult(boolean success, String msg) {
        this.success = success;
        this.msg = msg;
    }
}
