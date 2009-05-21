Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 81BE76B004D
	for <linux-mm@kvack.org>; Thu, 21 May 2009 15:38:47 -0400 (EDT)
Date: Thu, 21 May 2009 20:33:58 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH] hugh: update email address
Message-ID: <Pine.LNX.4.64.0905212028310.15596@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Rohland <hans-christoph.rohland@sap.com>, Matt Mackall <mpm@selenic.com>, Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

My old address will shut down in a few days time: remove it from the tree,
and add a tmpfs (shmem filesystem) maintainer entry with the new address.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 Documentation/filesystems/tmpfs.txt |    2 +-
 MAINTAINERS                         |    8 ++++++++
 mm/rmap.c                           |    2 +-
 3 files changed, 10 insertions(+), 2 deletions(-)

--- 2.6.30-rc6/Documentation/filesystems/tmpfs.txt	2008-07-13 22:51:29.000000000 +0100
+++ linux/Documentation/filesystems/tmpfs.txt	2009-05-20 20:22:50.000000000 +0100
@@ -133,4 +133,4 @@ RAM/SWAP in 10240 inodes and it is only
 Author:
    Christoph Rohland <cr@sap.com>, 1.12.01
 Updated:
-   Hugh Dickins <hugh@veritas.com>, 4 June 2007
+   Hugh Dickins, 4 June 2007
--- 2.6.30-rc6/MAINTAINERS	2009-05-09 09:06:41.000000000 +0100
+++ linux/MAINTAINERS	2009-05-20 20:22:50.000000000 +0100
@@ -5579,6 +5579,14 @@ M:	ian@mnementh.co.uk
 S:	Maintained
 F:	drivers/mmc/host/tmio_mmc.*
 
+TMPFS (SHMEM FILESYSTEM)
+P:	Hugh Dickins
+M:	hugh.dickins@tiscali.co.uk
+L:	linux-mm@kvack.org
+S:	Maintained
+F:	include/linux/shmem_fs.h
+F:	mm/shmem.c
+
 TPM DEVICE DRIVER
 P:	Debora Velarde
 M:	debora@linux.vnet.ibm.com
--- 2.6.30-rc6/mm/rmap.c	2009-03-23 23:12:14.000000000 +0000
+++ linux/mm/rmap.c	2009-05-20 20:22:50.000000000 +0100
@@ -14,7 +14,7 @@
  * Original design by Rik van Riel <riel@conectiva.com.br> 2001
  * File methods by Dave McCracken <dmccr@us.ibm.com> 2003, 2004
  * Anonymous methods by Andrea Arcangeli <andrea@suse.de> 2004
- * Contributions by Hugh Dickins <hugh@veritas.com> 2003, 2004
+ * Contributions by Hugh Dickins 2003, 2004
  */
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
