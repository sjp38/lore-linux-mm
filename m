Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id E962B6B0032
	for <linux-mm@kvack.org>; Thu, 23 May 2013 04:43:08 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 23 May 2013 14:06:24 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 0D5C61258053
	for <linux-mm@kvack.org>; Thu, 23 May 2013 14:15:02 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4N8gu3Z32440426
	for <linux-mm@kvack.org>; Thu, 23 May 2013 14:12:56 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4N8gxcN019375
	for <linux-mm@kvack.org>; Thu, 23 May 2013 18:43:00 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 3/4] mm/hugetlb: remove hugetlb_prefault 
Date: Thu, 23 May 2013 16:42:47 +0800
Message-Id: <1369298568-20094-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1369298568-20094-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1369298568-20094-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 v1 -> v2: 
	* add Michal reviewed-by 

hugetlb_prefault are not used any more, this patch remove it.

Reviewed-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 6b4890f..a811149 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -55,7 +55,6 @@ void __unmap_hugepage_range_final(struct mmu_gather *tlb,
 void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 				unsigned long start, unsigned long end,
 				struct page *ref_page);
-int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
 void hugetlb_report_meminfo(struct seq_file *);
 int hugetlb_report_node_meminfo(int, char *);
 void hugetlb_show_meminfo(void);
@@ -110,7 +109,6 @@ static inline unsigned long hugetlb_total_pages(void)
 #define follow_hugetlb_page(m,v,p,vs,a,b,i,w)	({ BUG(); 0; })
 #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
 #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
-#define hugetlb_prefault(mapping, vma)		({ BUG(); 0; })
 static inline void hugetlb_report_meminfo(struct seq_file *m)
 {
 }
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
