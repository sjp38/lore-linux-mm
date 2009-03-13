Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C0F816B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 13:34:13 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/2] NOMMU: Make CONFIG_UNEVICTABLE_LRU available when
	CONFIG_MMU=n
Date: Fri, 13 Mar 2009 17:33:53 +0000
Message-ID: <20090313173353.10169.23515.stgit@warthog.procyon.org.uk>
In-Reply-To: <20090313173343.10169.58053.stgit@warthog.procyon.org.uk>
References: <20090313173343.10169.58053.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com
Cc: dhowells@redhat.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, peterz@infradead.org, nrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@surriel.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Make CONFIG_UNEVICTABLE_LRU available when CONFIG_MMU=n.  There's no logical
reason it shouldn't be available, and it can be used for ramfs.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 mm/Kconfig |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)


diff --git a/mm/Kconfig b/mm/Kconfig
index 8c89597..b53427a 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -206,7 +206,6 @@ config VIRT_TO_BUS
 config UNEVICTABLE_LRU
 	bool "Add LRU list to track non-evictable pages"
 	default y
-	depends on MMU
 	help
 	  Keeps unevictable pages off of the active and inactive pageout
 	  lists, so kswapd will not waste CPU time or have its balancing

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
