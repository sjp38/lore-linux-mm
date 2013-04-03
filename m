Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 652AB6B0006
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 19:52:41 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id jt11so1121093pbb.37
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 16:52:40 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [RFC PATCH 1/4] vrange: Make various vrange.c local functions static
Date: Wed,  3 Apr 2013 16:52:20 -0700
Message-Id: <1365033144-15156-2-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1365033144-15156-1-git-send-email-john.stultz@linaro.org>
References: <1365033144-15156-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>

Make a number of local functions in vrange.c static.

Cc: linux-mm@kvack.org
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Arun Sharma <asharma@fb.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@sr71.net>
Cc: Rik van Riel <riel@redhat.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Jason Evans <je@fb.com>
Cc: sanjay@google.com
Cc: Paul Turner <pjt@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 mm/vrange.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/vrange.c b/mm/vrange.c
index c0c5d50..d07884d 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -45,7 +45,7 @@ static inline void __set_vrange(struct vrange *range,
 	range->node.last = end_idx;
 }
 
-void lru_add_vrange(struct vrange *vrange)
+static void lru_add_vrange(struct vrange *vrange)
 {
 	spin_lock(&lru_lock);
 	WARN_ON(!list_empty(&vrange->lru));
@@ -53,7 +53,7 @@ void lru_add_vrange(struct vrange *vrange)
 	spin_unlock(&lru_lock);
 }
 
-void lru_remove_vrange(struct vrange *vrange)
+static void lru_remove_vrange(struct vrange *vrange)
 {
 	spin_lock(&lru_lock);
 	if (!list_empty(&vrange->lru))
@@ -130,7 +130,7 @@ static inline void range_resize(struct rb_root *root,
 	__add_range(range, root, mm);
 }
 
-int add_vrange(struct mm_struct *mm,
+static int add_vrange(struct mm_struct *mm,
 			unsigned long start, unsigned long end)
 {
 	struct rb_root *root;
@@ -172,7 +172,7 @@ out:
 	return 0;
 }
 
-int remove_vrange(struct mm_struct *mm,
+static int remove_vrange(struct mm_struct *mm,
 		unsigned long start, unsigned long end)
 {
 	struct rb_root *root;
@@ -292,7 +292,7 @@ out:
 	return ret;
 }
 
-bool __vrange_address(struct mm_struct *mm,
+static bool __vrange_address(struct mm_struct *mm,
 			unsigned long start, unsigned long end)
 {
 	struct rb_root *root = &mm->v_rb;
@@ -387,7 +387,7 @@ static void __vrange_purge(struct mm_struct *mm,
 	}
 }
 
-int try_to_discard_one(struct page *page, struct vm_area_struct *vma,
+static int try_to_discard_one(struct page *page, struct vm_area_struct *vma,
 		unsigned long address)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -602,7 +602,7 @@ static int vrange_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 
 }
 
-unsigned int discard_vma_pages(struct zone *zone, struct mm_struct *mm,
+static unsigned int discard_vma_pages(struct zone *zone, struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, unsigned int nr_to_discard)
 {
@@ -669,7 +669,7 @@ out:
  * Get next victim vrange from LRU and hold a vrange refcount
  * and vrange->mm's refcount.
  */
-struct vrange *get_victim_vrange(void)
+static struct vrange *get_victim_vrange(void)
 {
 	struct mm_struct *mm;
 	struct vrange *vrange = NULL;
@@ -711,7 +711,7 @@ struct vrange *get_victim_vrange(void)
 	return vrange;
 }
 
-void put_victim_range(struct vrange *vrange)
+static void put_victim_range(struct vrange *vrange)
 {
 	put_vrange(vrange);
 	mmdrop(vrange->mm);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
