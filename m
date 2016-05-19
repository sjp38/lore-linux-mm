Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9215D6B025E
	for <linux-mm@kvack.org>; Thu, 19 May 2016 03:57:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 4so142228902pfw.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 00:57:30 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id ey9si18328544pab.123.2016.05.19.00.57.29
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 19 May 2016 00:57:29 -0700 (PDT)
From: roy.qing.li@gmail.com
Subject: [PATCH] mm: memcontrol: move comments for get_mctgt_type to proper position
Date: Thu, 19 May 2016 15:57:18 +0800
Message-Id: <1463644638-7446-1-git-send-email-roy.qing.li@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov@virtuozzo.com

From: Li RongQing <roy.qing.li@gmail.com>

move the comments for get_mctgt_type before the get_mctgt_type function

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 mm/memcontrol.c | 37 +++++++++++++++++++------------------
 1 file changed, 19 insertions(+), 18 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fe787f5..00981d2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4290,24 +4290,6 @@ static int mem_cgroup_do_precharge(unsigned long count)
 	return 0;
 }
 
-/**
- * get_mctgt_type - get target type of moving charge
- * @vma: the vma the pte to be checked belongs
- * @addr: the address corresponding to the pte to be checked
- * @ptent: the pte to be checked
- * @target: the pointer the target page or swap ent will be stored(can be NULL)
- *
- * Returns
- *   0(MC_TARGET_NONE): if the pte is not a target for move charge.
- *   1(MC_TARGET_PAGE): if the page corresponding to this pte is a target for
- *     move charge. if @target is not NULL, the page is stored in target->page
- *     with extra refcnt got(Callers should handle it).
- *   2(MC_TARGET_SWAP): if the swap entry corresponding to this pte is a
- *     target for charge migration. if @target is not NULL, the entry is stored
- *     in target->ent.
- *
- * Called with pte lock held.
- */
 union mc_target {
 	struct page	*page;
 	swp_entry_t	ent;
@@ -4496,6 +4478,25 @@ out:
 	return ret;
 }
 
+/**
+ * get_mctgt_type - get target type of moving charge
+ * @vma: the vma the pte to be checked belongs
+ * @addr: the address corresponding to the pte to be checked
+ * @ptent: the pte to be checked
+ * @target: the pointer the target page or swap ent will be stored(can be NULL)
+ *
+ * Returns
+ *   0(MC_TARGET_NONE): if the pte is not a target for move charge.
+ *   1(MC_TARGET_PAGE): if the page corresponding to this pte is a target for
+ *     move charge. if @target is not NULL, the page is stored in target->page
+ *     with extra refcnt got(Callers should handle it).
+ *   2(MC_TARGET_SWAP): if the swap entry corresponding to this pte is a
+ *     target for charge migration. if @target is not NULL, the entry is stored
+ *     in target->ent.
+ *
+ * Called with pte lock held.
+ */
+
 static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 		unsigned long addr, pte_t ptent, union mc_target *target)
 {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
