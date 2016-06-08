Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE856B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 02:43:46 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 5so1675645ioy.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 23:43:46 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id p186si32413431pfb.113.2016.06.07.23.43.45
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Jun 2016 23:43:45 -0700 (PDT)
From: roy.qing.li@gmail.com
Subject: [PATCH] mm: memcontrol: fix documentation for compound parameter
Date: Wed,  8 Jun 2016 14:43:36 +0800
Message-Id: <1465368216-9393-1-git-send-email-roy.qing.li@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov@virtuozzo.com

From: Li RongQing <roy.qing.li@gmail.com>

commit f627c2f53786 ("memcg: adjust to support new THP refcounting")
adds a compound parameter for several functions, and change one as
compound for mem_cgroup_move_account but it does not change the
comments.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 mm/memcontrol.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bc79b38..4d9a215 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4387,7 +4387,7 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
 /**
  * mem_cgroup_move_account - move account of the page
  * @page: the page
- * @nr_pages: number of regular pages (>1 for huge pages)
+ * @compound: charge the page as compound or small page
  * @from: mem_cgroup which the page is moved from.
  * @to:	mem_cgroup which the page is moved to. @from != @to.
  *
@@ -5249,6 +5249,7 @@ bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
  * @mm: mm context of the victim
  * @gfp_mask: reclaim mode
  * @memcgp: charged memcg return
+ * @compound: charge the page as compound or small page
  *
  * Try to charge @page to the memcg that @mm belongs to, reclaiming
  * pages according to @gfp_mask if necessary.
@@ -5311,6 +5312,7 @@ out:
  * @page: page to charge
  * @memcg: memcg to charge the page to
  * @lrucare: page might be on LRU already
+ * @compound: charge the page as compound or small page
  *
  * Finalize a charge transaction started by mem_cgroup_try_charge(),
  * after page->mapping has been set up.  This must happen atomically
@@ -5362,6 +5364,7 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
  * mem_cgroup_cancel_charge - cancel a page charge
  * @page: page to charge
  * @memcg: memcg to charge the page to
+ * @compound: charge the page as compound or small page
  *
  * Cancel a charge transaction started by mem_cgroup_try_charge().
  */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
