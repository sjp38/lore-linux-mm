Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 81E1A6B0069
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 18:05:47 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so8652391pbb.14
        for <linux-mm@kvack.org>; Mon, 20 Aug 2012 15:05:46 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v3 1/9] rbtree test: fix sparse warning about 64-bit constant
Date: Mon, 20 Aug 2012 15:05:23 -0700
Message-Id: <1345500331-10546-2-git-send-email-walken@google.com>
In-Reply-To: <1345500331-10546-1-git-send-email-walken@google.com>
References: <1345500331-10546-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

Just a small fix to make sparse happy.

Signed-off-by: Michel Lespinasse <walken@google.com>
Reported-by: Fengguang Wu <wfg@linux.intel.com>
Acked-by: Rik van Riel <riel@redhat.com>

---
 lib/rbtree_test.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/rbtree_test.c b/lib/rbtree_test.c
index 19dfca9ff7d7..fd09465d82ca 100644
--- a/lib/rbtree_test.c
+++ b/lib/rbtree_test.c
@@ -88,7 +88,7 @@ static int rbtree_test_init(void)
 
 	printk(KERN_ALERT "rbtree testing");
 
-	prandom32_seed(&rnd, 3141592653589793238);
+	prandom32_seed(&rnd, 3141592653589793238ULL);
 	init();
 
 	time1 = get_cycles();
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
