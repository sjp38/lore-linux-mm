Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id B5EFF6B005D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 02:36:55 -0400 (EDT)
Received: by qafk30 with SMTP id k30so5008886qaf.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 23:36:54 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 5 Sep 2012 14:36:54 +0800
Message-ID: <CAPgLHd-3Uwj1Uf31xqPO8LyYT0DS2Tcb1fa5KTYXdATEOHT9qw@mail.gmail.com>
Subject: [PATCH] mm: use list_move_tail instead of list_del/list_add_tail
From: Wei Yongjun <weiyj.lk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: yongjun_wei@trendmicro.com.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using list_move_tail() instead of list_del() + list_add_tail().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 mm/rmap.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 0f3b7cd..6333654 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -307,8 +307,7 @@ void anon_vma_moveto_tail(struct vm_area_struct *dst)
 		struct anon_vma *anon_vma = pavc->anon_vma;
 		VM_BUG_ON(pavc->vma != dst);
 		root = lock_anon_vma_root(root, anon_vma);
-		list_del(&pavc->same_anon_vma);
-		list_add_tail(&pavc->same_anon_vma, &anon_vma->head);
+		list_move_tail(&pavc->same_anon_vma, &anon_vma->head);
 	}
 	unlock_anon_vma_root(root);
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
