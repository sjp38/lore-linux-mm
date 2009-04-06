Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 266C45F0001
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 08:21:05 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/2] Point the UNEVICTABLE_LRU config option at the
	documentation
Date: Mon, 06 Apr 2009 13:21:18 +0100
Message-ID: <20090406122118.30881.28315.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: torvalds@osdl.org, akpm@linux-foundation.org
Cc: dhowells@redhat.com, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
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
