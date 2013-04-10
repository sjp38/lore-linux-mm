Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id A00AF6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 16:03:21 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 05:54:31 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id DBCD1357804E
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 06:03:14 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3AK2IYm5833092
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 06:02:18 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3AK2NML002916
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 06:02:23 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH] mm: Rewrite the comment over migrate_pages() more
 comprehensibly
Date: Thu, 11 Apr 2013 01:29:48 +0530
Message-ID: <20130410195919.17355.23052.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>

The comment over migrate_pages() looks quite weird, and makes it hard
to grasp what it is trying to say. Rewrite it more comprehensibly.

Cc: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/migrate.c |   22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 3bbaf5d..3618b04 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -973,19 +973,23 @@ out:
 }
 
 /*
- * migrate_pages
+ * migrate_pages - migrate the pages specified in a list, to the free pages
+ *		   supplied as the target for the page migration
  *
- * The function takes one list of pages to migrate and a function
- * that determines from the page to be migrated and the private data
- * the target of the move and allocates the page.
+ * @from:		The list of pages to be migrated.
+ * @get_new_page:	The function used to allocate free pages to be used
+ *			as the target of the page migration.
+ * @private:		Private data to be passed on to get_new_page()
+ * @mode:		The migration mode that specifies the constraints for
+ *			page migration, if any.
+ * @reason:		The reason for page migration.
  *
- * The function returns after 10 attempts or if no pages
- * are movable anymore because to has become empty
- * or no retryable pages exist anymore.
- * Caller should call putback_lru_pages to return pages to the LRU
+ * The function returns after 10 attempts or if no pages are movable any more
+ * because the list has become empty or no retryable pages exist any more.
+ * The caller should call putback_lru_pages() to return pages to the LRU
  * or free list only if ret != 0.
  *
- * Return: Number of pages not migrated or error code.
+ * Returns the number of pages that were not migrated, or an error code.
  */
 int migrate_pages(struct list_head *from, new_page_t get_new_page,
 		unsigned long private, enum migrate_mode mode, int reason)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
