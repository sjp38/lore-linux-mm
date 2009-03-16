Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9538D6B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 06:59:54 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] Point the UNEVICTABLE_LRU config option at the documentation
Date: Mon, 16 Mar 2009 10:59:45 +0000
Message-ID: <20090316105945.18131.82359.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com
Cc: dhowells@redhat.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Point the UNEVICTABLE_LRU config option at the documentation describing the
option.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 mm/Kconfig |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)


diff --git a/mm/Kconfig b/mm/Kconfig
index b53427a..57971d2 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -213,6 +213,8 @@ config UNEVICTABLE_LRU
 	  will use one page flag and increase the code size a little,
 	  say Y unless you know what you are doing.
 
+	  See Documentation/vm/unevictable-lru.txt for more information.
+
 config HAVE_MLOCK
 	bool
 	default y if MMU=y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
