Received: from rockstar.fsl.cs.sunysb.edu (rockstar.fsl.cs.sunysb.edu [130.245.126.62])
	by filer.fsl.cs.sunysb.edu (8.12.8/8.13.1) with ESMTP id k03Geb5e019114
	for <linux-mm@kvack.org>; Tue, 3 Jan 2006 11:40:37 -0500
Subject: set_page_count() patch
From: Avishay Traeger <atraeger@cs.sunysb.edu>
Content-Type: text/plain
Date: Tue, 03 Jan 2006 11:40:38 -0500
Message-Id: <1136306438.16675.10.camel@rockstar.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello all,

I believe the set_page_count() macro is broken, and should have
parentheses around the 'v' in the second argument (otherwise more
complex arguments will break).  Here is a patch to 2.6.15 - I haven't
really tested it, but it looks simple enough.  Any objections?

Avishay Traeger
http://www.fsl.cs.sunysb.edu/~avishay/


diff -Naur linux-2.6.15/include/linux/mm.h
linux-2.6.15-mod/include/linux/mm.h
--- linux-2.6.15/include/linux/mm.h     2006-01-02 22:21:10.000000000
-0500
+++ linux-2.6.15-mod/include/linux/mm.h 2006-01-03 11:28:19.000000000
-0500
@@ -308,7 +308,7 @@
  */
 #define get_page_testone(p)    atomic_inc_and_test(&(p)->_count)

-#define set_page_count(p,v)    atomic_set(&(p)->_count, v - 1)
+#define set_page_count(p,v)    atomic_set(&(p)->_count, (v) - 1)
 #define __put_page(p)          atomic_dec(&(p)->_count)

 extern void FASTCALL(__page_cache_release(struct page *));


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
