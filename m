Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8E78C6B00C8
	for <linux-mm@kvack.org>; Wed, 13 May 2009 04:30:23 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4D8UomQ016482
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 May 2009 17:30:50 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E3C7645DD74
	for <linux-mm@kvack.org>; Wed, 13 May 2009 17:30:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C11F845DD70
	for <linux-mm@kvack.org>; Wed, 13 May 2009 17:30:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BA6251DB8017
	for <linux-mm@kvack.org>; Wed, 13 May 2009 17:30:49 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 77FBD1DB8012
	for <linux-mm@kvack.org>; Wed, 13 May 2009 17:30:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED submenu
Message-Id: <20090513172904.7234.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 May 2009 17:30:45 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED submenu

Almost people always turn on CONFIG_UNEVICTABLE_LRU. this configuration is
used only embedded people.
Thus, moving it into embedded submenu is better.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
---
 init/Kconfig |   12 ++++++++++++
 mm/Kconfig   |   12 ------------
 2 files changed, 12 insertions(+), 12 deletions(-)

Index: b/mm/Kconfig
===================================================================
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -203,18 +203,6 @@ config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
 
-config UNEVICTABLE_LRU
-	bool "Add LRU list to track non-evictable pages"
-	default y
-	help
-	  Keeps unevictable pages off of the active and inactive pageout
-	  lists, so kswapd will not waste CPU time or have its balancing
-	  algorithms thrown off by scanning these pages.  Selecting this
-	  will use one page flag and increase the code size a little,
-	  say Y unless you know what you are doing.
-
-	  See Documentation/vm/unevictable-lru.txt for more information.
-
 config HAVE_MLOCK
 	bool
 	default y if MMU=y
Index: b/init/Kconfig
===================================================================
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -954,6 +954,18 @@ config SLUB_DEBUG
 	  SLUB sysfs support. /sys/slab will not exist and there will be
 	  no support for cache validation etc.
 
+config UNEVICTABLE_LRU
+	bool "Add LRU list to track non-evictable pages" if EMBEDDED
+	default y
+	help
+	  Keeps unevictable pages off of the active and inactive pageout
+	  lists, so kswapd will not waste CPU time or have its balancing
+	  algorithms thrown off by scanning these pages.  Selecting this
+	  will use one page flag and increase the code size a little,
+	  say Y unless you know what you are doing.
+
+	  See Documentation/vm/unevictable-lru.txt for more information.
+
 config STRIP_ASM_SYMS
 	bool "Strip assembler-generated symbols during link"
 	default n


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
