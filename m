Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CFAEF6B01F0
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 10:58:55 -0400 (EDT)
Received: from guests.acceleratorcentre.net ([209.222.173.41] helo=crashcourse.ca)
	by astoria.ccjclearline.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <rpjday@crashcourse.ca>)
	id 1NynlG-0003SZ-VT
	for linux-mm@kvack.org; Mon, 05 Apr 2010 10:58:47 -0400
Date: Mon, 5 Apr 2010 10:56:30 -0400 (EDT)
From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: [PATCH] MM: Make "struct vm_region {...}" depend on !CONFIG_MMU.
Message-ID: <alpine.LFD.2.00.1004051052410.8295@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Since the "vm_region" structure appears to be relevant only under
NOMMU, conditionally include it in mm_types.h.

Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

---

  if i read mm_types.h, i can see the obvious conditional inclusion:

#ifndef CONFIG_MMU
        struct vm_region *vm_region;    /* NOMMU mapping region */
#endif

since that's the case, it seems only consistent to make the structure
declaration itself similarly conditional, no?

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index b8bb9a6..76f1174 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -102,6 +102,7 @@ struct page {
 #endif
 };

+#ifndef CONFIG_MMU
 /*
  * A region containing a mapping of a non-memory backed file under NOMMU
  * conditions.  These are held in a global tree and are pinned by the VMAs that
@@ -120,6 +121,7 @@ struct vm_region {
 	bool		vm_icache_flushed : 1; /* true if the icache has been flushed for
 						* this region */
 };
+#endif

 /*
  * This struct defines a memory VMM memory area. There is one of these


========================================================================
Robert P. J. Day                               Waterloo, Ontario, CANADA

            Linux Consulting, Training and Kernel Pedantry.

Web page:                                          http://crashcourse.ca
Twitter:                                       http://twitter.com/rpjday
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
