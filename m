Date: Fri, 9 May 2003 10:55:42 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.69-mm3
Message-ID: <20030509175542.GY8978@holomorphy.com>
References: <20030508013958.157b27b7.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030508013958.157b27b7.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 08, 2003 at 01:39:58AM -0700, Andrew Morton wrote:
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.69-mm3.gz
>   Will appear sometime at
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.5.69-mm3/

Microscopic hugetlb cleanup: some variables static to hugetlbpage.c are
later declared as extern within a function in the same file. This patch
removes their declaration.


-- wli

diff -urpN mm3-2.5.69-1/arch/i386/mm/hugetlbpage.c mm3-2.5.69-2/arch/i386/mm/hugetlbpage.c
--- mm3-2.5.69-1/arch/i386/mm/hugetlbpage.c	2003-05-04 16:53:41.000000000 -0700
+++ mm3-2.5.69-2/arch/i386/mm/hugetlbpage.c	2003-05-09 10:27:57.000000000 -0700
@@ -20,8 +20,6 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
-#include <linux/sysctl.h>
-
 static long    htlbpagemem;
 int     htlbpage_max;
 static long    htlbzone_pages;
@@ -398,8 +396,6 @@ int set_hugetlb_mem_size(int count)
 {
 	int lcount;
 	struct page *page;
-	extern long htlbzone_pages;
-	extern struct list_head htlbpage_freelist;
 
 	if (count < 0)
 		lcount = count;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
