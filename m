Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 876226B0098
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 05:36:45 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200908051136.682859934@firstfloor.org>
In-Reply-To: <200908051136.682859934@firstfloor.org>
Subject: [PATCH] [17/19] HWPOISON: Enable error_remove_page for NFS
Message-Id: <20090805093644.E3607B15D8@basil.firstfloor.org>
Date: Wed,  5 Aug 2009 11:36:44 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: Trond.Myklebust@netapp.com, akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com
List-ID: <linux-mm.kvack.org>


Enable hardware memory error handling for NFS

Truncation of data pages at runtime should be safe in NFS,
even when it doesn't support migration so far.

Cc: Trond.Myklebust@netapp.com

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 fs/nfs/file.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux/fs/nfs/file.c
===================================================================
--- linux.orig/fs/nfs/file.c
+++ linux/fs/nfs/file.c
@@ -480,6 +480,7 @@ const struct address_space_operations nf
 	.releasepage = nfs_release_page,
 	.direct_IO = nfs_direct_IO,
 	.launder_page = nfs_launder_page,
+	.error_remove_page = generic_error_remove_page,
 };
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
