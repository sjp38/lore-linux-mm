Date: Wed, 4 Jun 2008 13:04:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 00/21] hugetlb multi size, giant hugetlb support, etc
Message-ID: <20080604110438.GB32654@wotan.suse.de>
References: <20080603095956.781009952@amd.local0.net> <20080604012938.53b1003c.akpm@linux-foundation.org> <20080604093517.GA32654@wotan.suse.de> <20080604024648.b05424df.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080604024648.b05424df.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Wed, Jun 04, 2008 at 02:46:48AM -0700, Andrew Morton wrote:
> On Wed, 4 Jun 2008 11:35:17 +0200 Nick Piggin <npiggin@suse.de> wrote:
> 
> > OK, well I'm keen to get it into mm so it's not holding up (or being
> > busted by) other work... can I just try replying with improved
> > changelogs? Or do you want me to resend the full series?
> 
> Full resend please - if I'm going to spend an hour with my nose stuck
> in this, there's not much point in getting all confused about what goes
> with what.

OK, coming right up...

Firstly, you need to fix hugetlb building with CONFIG_HUGETLB off...

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
