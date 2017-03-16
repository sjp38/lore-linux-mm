Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E9D5E6B03A6
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:01:28 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id z13so41858992iof.7
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:01:28 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0095.hostedemail.com. [216.40.44.95])
        by mx.google.com with ESMTPS id c102si4695415iod.53.2017.03.15.19.01.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 19:01:28 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/15] mm: page_alloc: Fix typo acording -> according & the the -> to the
Date: Wed, 15 Mar 2017 19:00:05 -0700
Message-Id: <d18c3116815d70609eb063d8ce97d5a9fe05a2b9.1489628477.git.joe@perches.com>
In-Reply-To: <cover.1489628477.git.joe@perches.com>
References: <cover.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Just a typo fix...

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 60ec74894a56..e417d52b9de9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5419,7 +5419,7 @@ static int zone_batchsize(struct zone *zone)
  * locking.
  *
  * Any new users of pcp->batch and pcp->high should ensure they can cope with
- * those fields changing asynchronously (acording the the above rule).
+ * those fields changing asynchronously (according to the above rule).
  *
  * mutex_is_locked(&pcp_batch_high_lock) required when calling this function
  * outside of boot time (or some other assurance that no concurrent updaters
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
