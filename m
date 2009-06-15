Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1F7986B0062
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 13:58:11 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 09/11] vfs: Export wakeup_pdflush
Date: Mon, 15 Jun 2009 19:59:56 +0200
Message-Id: <1245088797-29533-10-git-send-email-jack@suse.cz>
In-Reply-To: <1245088797-29533-1-git-send-email-jack@suse.cz>
References: <1245088797-29533-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

When we are running out of free space on a filesystem, we want to flush dirty
pages in the filesystem so that blocks reserved via delayed allocation get
written and unnecessary block reservation is released. Export wakeup_pdflush()
so that filesystem can start such writeback.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/page-writeback.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index bb553c3..43af1cf 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -730,6 +730,7 @@ int wakeup_pdflush(long nr_pages)
 				global_page_state(NR_UNSTABLE_NFS);
 	return pdflush_operation(background_writeout, nr_pages);
 }
+EXPORT_SYMBOL(wakeup_pdflush);
 
 static void wb_timer_fn(unsigned long unused);
 static void laptop_timer_fn(unsigned long unused);
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
