Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 3797A6B009C
	for <linux-mm@kvack.org>; Wed, 22 May 2013 06:50:59 -0400 (EDT)
Date: Wed, 22 May 2013 12:50:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] mm/hugetlb: remove hugetlb_prefault
Message-ID: <20130522105057.GE19989@dhcp22.suse.cz>
References: <1369214970-1526-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1369214970-1526-3-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369214970-1526-3-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 22-05-13 17:29:29, Wanpeng Li wrote:
> hugetlb_prefault are not used any more, this patch remove it.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/hugetlb.h | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 6b4890f..a811149 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -55,7 +55,6 @@ void __unmap_hugepage_range_final(struct mmu_gather *tlb,
>  void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  				unsigned long start, unsigned long end,
>  				struct page *ref_page);
> -int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
>  void hugetlb_report_meminfo(struct seq_file *);
>  int hugetlb_report_node_meminfo(int, char *);
>  void hugetlb_show_meminfo(void);
> @@ -110,7 +109,6 @@ static inline unsigned long hugetlb_total_pages(void)
>  #define follow_hugetlb_page(m,v,p,vs,a,b,i,w)	({ BUG(); 0; })
>  #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
>  #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
> -#define hugetlb_prefault(mapping, vma)		({ BUG(); 0; })
>  static inline void hugetlb_report_meminfo(struct seq_file *m)
>  {
>  }
> -- 
> 1.8.1.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
