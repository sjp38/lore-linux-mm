Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A6B6F6B0260
	for <linux-mm@kvack.org>; Tue, 24 May 2016 22:57:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 77so64863193pfz.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 19:57:21 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id k4si9075732paw.171.2016.05.24.19.57.16
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 19:57:16 -0700 (PDT)
From: roy.qing.li@gmail.com
Subject: [PATCH] mm: memcontrol: remove the useless parameter for mc_handle_swap_pte
Date: Wed, 25 May 2016 10:57:06 +0800
Message-Id: <1464145026-26693-1-git-send-email-roy.qing.li@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov@virtuozzo.com

From: Li RongQing <roy.qing.li@gmail.com>

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 mm/memcontrol.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 36b7ecf..c628c90 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4386,7 +4386,7 @@ static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
 
 #ifdef CONFIG_SWAP
 static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
-			unsigned long addr, pte_t ptent, swp_entry_t *entry)
+			pte_t ptent, swp_entry_t *entry)
 {
 	struct page *page = NULL;
 	swp_entry_t ent = pte_to_swp_entry(ptent);
@@ -4405,7 +4405,7 @@ static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
 }
 #else
 static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
-			unsigned long addr, pte_t ptent, swp_entry_t *entry)
+			pte_t ptent, swp_entry_t *entry)
 {
 	return NULL;
 }
@@ -4570,7 +4570,7 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 	if (pte_present(ptent))
 		page = mc_handle_present_pte(vma, addr, ptent);
 	else if (is_swap_pte(ptent))
-		page = mc_handle_swap_pte(vma, addr, ptent, &ent);
+		page = mc_handle_swap_pte(vma, ptent, &ent);
 	else if (pte_none(ptent))
 		page = mc_handle_file_pte(vma, addr, ptent, &ent);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
