Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 3C7C16B0037
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:14:23 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Fri, 26 Jul 2013 17:14:22 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id F0D0238C803B
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:14:18 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6QLEKw2125668
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:14:20 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6QLEIr1013492
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 18:14:19 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 4/5] rbtree: allow tests to run as builtin
Date: Fri, 26 Jul 2013 14:13:42 -0700
Message-Id: <1374873223-25557-5-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Woodhouse <David.Woodhouse@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

No reason require rbtree test code to be a module, allow it to be
builtin (streamlines my development process)

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 lib/Kconfig.debug | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 1501aa5..606e3c8 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1442,7 +1442,7 @@ config BACKTRACE_SELF_TEST
 
 config RBTREE_TEST
 	tristate "Red-Black tree test"
-	depends on m && DEBUG_KERNEL
+	depends on DEBUG_KERNEL
 	help
 	  A benchmark measuring the performance of the rbtree library.
 	  Also includes rbtree invariant checks.
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
