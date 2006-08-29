Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7TLXV30027666
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 17:33:31 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7TLXVg1270448
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 17:33:31 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7TLXVjc029372
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 17:33:31 -0400
Subject: Re: [RFC][PATCH 06/10] sparc64 generic PAGE_SIZE
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060829201938.8E1B700A@localhost.localdomain>
References: <20060829201934.47E63D1F@localhost.localdomain>
	 <20060829201938.8E1B700A@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 29 Aug 2006 14:33:24 -0700
Message-Id: <1156887204.5408.201.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, rdunlap@xenotime.net, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

There's s small issue on sparc64.  PAGE_SHIFT is used in a header where
it was previously available, but isn't now.  We need page.h

diff -puN include/asm-sparc64/pgtable.h~sparc64-fix include/asm-sparc64/pgtable.h
--- threadalloc/include/asm-sparc64/pgtable.h~sparc64-fix       2006-08-29 14:18:27.000000000 -0700
+++ threadalloc-dave/include/asm-sparc64/pgtable.h      2006-08-29 14:18:28.000000000 -0700
@@ -13,6 +13,7 @@
  */

 #include <asm-generic/pgtable-nopud.h>
+#include <asm-generic/page.h>

 #include <linux/compiler.h>
 #include <asm/types.h>

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
