Date: Tue, 3 Jun 2008 12:57:21 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 00/21] hugetlb multi size, giant hugetlb support, etc
Message-ID: <20080603105721.GB23454@wotan.suse.de>
References: <20080603095956.781009952@amd.local0.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080603095956.781009952@amd.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 03, 2008 at 07:59:56PM +1000, npiggin@suse.de wrote:
> Hi,
> 
> Here is my submission to be merged in -mm. Given the amount of hunks this
> patchset has, and the recent flurry of hugetlb development work, I'd hope to
> get this merged up provided there aren't major issues (I would prefer to fix
> minor ones with incremental patches). It's just a lot of error prone work to
> track -mm when multiple concurrent development is happening.
> 
> Patch against latest mmotm.

Ah, missed a couple of things required to compile with hugetlbfs configured
out. Here is a patch against mmotm, I will also send out a rediffed patch
in the series.

---
Index: linux-2.6/include/linux/hugetlb.h
===================================================================
--- linux-2.6.orig/include/linux/hugetlb.h	2008-06-03 20:44:40.000000000 +1000
+++ linux-2.6/include/linux/hugetlb.h	2008-06-03 20:45:07.000000000 +1000
@@ -76,7 +76,7 @@ static inline unsigned long hugetlb_tota
 #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
 #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
 #define hugetlb_prefault(mapping, vma)		({ BUG(); 0; })
-#define unmap_hugepage_range(vma, start, end)	BUG()
+#define unmap_hugepage_range(vma, start, end, page)	BUG()
 #define hugetlb_report_meminfo(buf)		0
 #define hugetlb_report_node_meminfo(n, buf)	0
 #define follow_huge_pmd(mm, addr, pmd, write)	NULL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
