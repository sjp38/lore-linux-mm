Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id B77F76B0038
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:41:50 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id c1so1862461igq.16
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:41:50 -0700 (PDT)
Received: from cam-smtp0.cambridge.arm.com (fw-tnat.cambridge.arm.com. [217.140.96.21])
        by mx.google.com with ESMTPS id gw5si1117371icb.40.2014.05.02.06.41.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:41:50 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH 1/6] mm/kmemleak.c: Use %u to print ->checksum.
Date: Fri,  2 May 2014 14:41:05 +0100
Message-Id: <1399038070-1540-2-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <1399038070-1540-1-git-send-email-catalin.marinas@arm.com>
References: <1399038070-1540-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Jianpeng Ma <majianpeng@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

From: Jianpeng Ma <majianpeng@gmail.com>

Signed-off-by: Jianpeng Ma <majianpeng@gmail.com>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/kmemleak.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 91d67eaee050..3a36e2b16cba 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -387,7 +387,7 @@ static void dump_object_info(struct kmemleak_object *object)
 	pr_notice("  min_count = %d\n", object->min_count);
 	pr_notice("  count = %d\n", object->count);
 	pr_notice("  flags = 0x%lx\n", object->flags);
-	pr_notice("  checksum = %d\n", object->checksum);
+	pr_notice("  checksum = %u\n", object->checksum);
 	pr_notice("  backtrace:\n");
 	print_stack_trace(&trace, 4);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
