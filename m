Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j8FGgMwP196028
	for <linux-mm@kvack.org>; Thu, 15 Sep 2005 12:42:24 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8FGgKab532702
	for <linux-mm@kvack.org>; Thu, 15 Sep 2005 10:42:20 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8FGgJlw030615
	for <linux-mm@kvack.org>; Thu, 15 Sep 2005 10:42:19 -0600
Subject: [PATCH 1/2] fix mm/Kconfig spelling
From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 15 Sep 2005 09:42:18 -0700
Message-Id: <20050915164218.AD02EDC0@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

I might let this slide in a comment, but it's in a top-level
Kconfig option.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/mm/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN mm/Kconfig~A1-icantspell mm/Kconfig
--- memhotplug/mm/Kconfig~A1-icantspell	2005-09-14 09:32:36.000000000 -0700
+++ memhotplug-dave/mm/Kconfig	2005-09-14 09:32:36.000000000 -0700
@@ -29,7 +29,7 @@ config FLATMEM_MANUAL
 	  If unsure, choose this option (Flat Memory) over any other.
 
 config DISCONTIGMEM_MANUAL
-	bool "Discontigious Memory"
+	bool "Discontiguous Memory"
 	depends on ARCH_DISCONTIGMEM_ENABLE
 	help
 	  This option provides enhanced support for discontiguous
@@ -52,7 +52,7 @@ config SPARSEMEM_MANUAL
 	  memory hotplug systems.  This is normal.
 
 	  For many other systems, this will be an alternative to
-	  "Discontigious Memory".  This option provides some potential
+	  "Discontiguous Memory".  This option provides some potential
 	  performance benefits, along with decreased code complexity,
 	  but it is newer, and more experimental.
 
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
