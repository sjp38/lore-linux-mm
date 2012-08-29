Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id AD27E6B0069
	for <linux-mm@kvack.org>; Wed, 29 Aug 2012 18:38:13 -0400 (EDT)
Received: from cpec03f0ed08c7f-cm001ac318e826.cpe.net.cable.rogers.com ([174.115.5.73]:35617 helo=crashcourse.ca)
	by astoria.ccjclearline.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.77)
	(envelope-from <rpjday@crashcourse.ca>)
	id 1T6qtl-0004Y9-2g
	for linux-mm@kvack.org; Wed, 29 Aug 2012 18:38:09 -0400
Date: Wed, 29 Aug 2012 18:38:07 -0400 (EDT)
From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: [PATCH] MEMORY MANAGEMENT: Correct "vm_inert_page" typo.
Message-ID: <alpine.DEB.2.02.1208291836460.30507@oneiric>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

---

  picky correction, apply if you want.

diff --git a/mm/memory.c b/mm/memory.c
index 5736170..91dd88e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2132,7 +2132,7 @@ out:
  * @addr: target user address of this page
  * @pfn: source kernel pfn
  *
- * Similar to vm_inert_page, this allows drivers to insert individual pages
+ * Similar to vm_insert_page, this allows drivers to insert individual pages
  * they've allocated into a user vma. Same comments apply.
  *
  * This function should only be called from a vm_ops->fault handler, and


rday

-- 

========================================================================
Robert P. J. Day                                 Ottawa, Ontario, CANADA
                        http://crashcourse.ca

Twitter:                                       http://twitter.com/rpjday
LinkedIn:                               http://ca.linkedin.com/in/rpjday
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
