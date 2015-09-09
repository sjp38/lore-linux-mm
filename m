Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id BDD7D6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 18:34:02 -0400 (EDT)
Received: by lanb10 with SMTP id b10so16266263lan.3
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 15:34:01 -0700 (PDT)
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com. [209.85.217.172])
        by mx.google.com with ESMTPS id ck10si8111900lbc.145.2015.09.09.15.34.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 15:34:00 -0700 (PDT)
Received: by lbcjc2 with SMTP id jc2so13763067lbc.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 15:34:00 -0700 (PDT)
From: Alexey Klimov <alexey.klimov@linaro.org>
Subject: [PATCH 1/1] mm: kmemleak: remove unneeded initialization of object to NULL
Date: Thu, 10 Sep 2015 01:33:49 +0300
Message-Id: <1441838029-4596-1-git-send-email-alexey.klimov@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, catalin.marinas@arm.com
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, klimov.linux@gmail.com, Alexey Klimov <alexey.klimov@linaro.org>

Few lines below object is reinitialized by lookup_object()
so we don't need to init it by NULL in the beginning of
find_and_get_object().

Signed-off-by: Alexey Klimov <alexey.klimov@linaro.org>
---
 mm/kmemleak.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index f532f6a..444a771 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -488,7 +488,7 @@ static void put_object(struct kmemleak_object *object)
 static struct kmemleak_object *find_and_get_object(unsigned long ptr, int alias)
 {
 	unsigned long flags;
-	struct kmemleak_object *object = NULL;
+	struct kmemleak_object *object;
 
 	rcu_read_lock();
 	read_lock_irqsave(&kmemleak_lock, flags);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
