Date: Mon, 21 Oct 2002 17:14:30 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH] mm mremap freeze
Message-ID: <Pine.LNX.4.44.0210211708030.16869-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

mremap's move_one_page tried to lock src_page twice
#ifndef CONFIG_SHAREPTE (do I hear you hissing my disloyalty?)

--- 2.5.44-mm2/mm/mremap.c	Mon Oct 21 12:57:53 2002
+++ linux/mm/mremap.c	Mon Oct 21 16:46:58 2002
@@ -43,8 +43,8 @@
 		goto out_unlock;
 
 	src_page = pmd_page(*src_pmd);
-	pte_page_lock(src_page);
 #ifdef CONFIG_SHAREPTE
+	pte_page_lock(src_page);
 	/*
 	 * Unshare if necessary.  We unmap the return
 	 * pointer because we may need to map it nested later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
