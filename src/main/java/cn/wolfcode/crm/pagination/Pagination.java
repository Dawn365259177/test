package cn.wolfcode.crm.pagination;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Setter
@Getter
public class Pagination {
    private long total;
    private List rows;

    public Pagination(long total, List rows) {
        this.total = total;
        this.rows = rows;
    }
}
