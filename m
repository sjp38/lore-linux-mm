Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7TLDZ81025206
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 17:13:35 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7TLDZL3291562
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 17:13:35 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7TLDZdD020172
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 17:13:35 -0400
Subject: RE: [RFC][PATCH 10/10] convert the "easy" architectures to generic
	PAGE_SIZE
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A728D28@scsmsx411.amr.corp.intel.com>
References: <617E1C2C70743745A92448908E030B2A728D28@scsmsx411.amr.corp.intel.com>
Content-Type: text/plain
Date: Tue, 29 Aug 2006 14:13:29 -0700
Message-Id: <1156886009.5408.183.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, rdunlap@xenotime.net, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-08-29 at 14:06 -0700, Luck, Tony wrote:
> > Note that, as promised, this removes ARCH_GENERIC_PAGE_SIZE
> > introduced by the first patch in this series.  It is no longer
> > needed as _all_ architectures now use this infrastructure.
> 
> Either I goofed when applying these patches, or you missed one
> in mm/Kconfig.  The version I ended up with had the "Kernel Page Size"
> choice still "depends on ARCH_GENERIC_PAGE_SIZE" ... so make
> menuconfig didn't let me choose the page size.

Yeah, during all of my repatching, I managed to forget to rip that out.
Thanks for finding that.  Just killing that depends line, or applying
this should fix it.

-- Dave

 threadalloc-dave/mm/Kconfig |    1 -
 1 files changed, 1 deletion(-)

diff -puN mm/Kconfig~fix-mm-Kconfig mm/Kconfig
--- threadalloc/mm/Kconfig~fix-mm-Kconfig	2006-08-29 14:11:25.000000000 -0700
+++ threadalloc-dave/mm/Kconfig	2006-08-29 14:11:26.000000000 -0700
@@ -4,7 +4,6 @@ config ARCH_HAVE_GET_ORDER
 
 choice
 	prompt "Kernel Page Size"
-	depends on ARCH_GENERIC_PAGE_SIZE
 	default PAGE_SIZE_4KB if MIPS || PARISC
 	default PAGE_SIZE_8KB if SPARC64
 	default PAGE_SIZE_16KB if IA64
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
