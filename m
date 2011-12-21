Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id B5D856B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 06:09:46 -0500 (EST)
Received: by iacb35 with SMTP id b35so12954591iac.14
        for <linux-mm@kvack.org>; Wed, 21 Dec 2011 03:09:46 -0800 (PST)
Message-ID: <4EF1BE69.5090300@gmail.com>
Date: Wed, 21 Dec 2011 19:09:29 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] cleanup: mm/migrate.c: cleanup comment for function migration_entry_wait
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

migration_entry_wait can also be called from hugetlb_fault now.
Cleanup the comment.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/migrate.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 177aca4..640002a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -181,8 +181,6 @@ static void remove_migration_ptes(struct page *old, struct page *new)
  * Something used the pte of a page under migration. We need to
  * get to the page and wait until migration is finished.
  * When we return from this function the fault will be retried.
- *
- * This function is called from do_swap_page().
  */
 void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
 				unsigned long address)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
