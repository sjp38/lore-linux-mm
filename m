Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 304DE60080E
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 10:57:50 -0400 (EDT)
Received: by fxm3 with SMTP id 3so854052fxm.14
        for <linux-mm@kvack.org>; Tue, 10 Aug 2010 07:57:47 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] percpu: simplify the pcpu_alloc()
Date: Tue, 10 Aug 2010 23:00:40 +0800
Message-Id: <1281452440-22346-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: tj@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

   The `while' is not needed, replaced it with `if' to reduce
   an unnecessary check.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/percpu.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index e61dc2c..2e50004 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -724,7 +724,8 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
 			goto fail_unlock;
 		}
 
-		while ((new_alloc = pcpu_need_to_extend(chunk))) {
+		new_alloc = pcpu_need_to_extend(chunk);
+		if (new_alloc) {
 			spin_unlock_irqrestore(&pcpu_lock, flags);
 			if (pcpu_extend_area_map(chunk, new_alloc) < 0) {
 				err = "failed to extend area map of reserved chunk";
-- 
1.6.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
