Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 2A3756B005A
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 18:34:33 -0400 (EDT)
Received: by yenr5 with SMTP id r5so79023yen.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 15:34:32 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 1/9] rbtree test: fix sparse warning about 64-bit constant
Date: Thu,  2 Aug 2012 15:34:10 -0700
Message-Id: <1343946858-8170-2-git-send-email-walken@google.com>
In-Reply-To: <1343946858-8170-1-git-send-email-walken@google.com>
References: <1343946858-8170-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

Just a small fix to make sparse happy.

Signed-off-by: Michel Lespinasse <walken@google.com>
Reported-by: Fengguang Wu <wfg@linux.intel.com>
---
 lib/rbtree_test.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/rbtree_test.c b/lib/rbtree_test.c
index 19dfca9..fd09465 100644
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
