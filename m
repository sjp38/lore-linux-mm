Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 6EC046B00A0
	for <linux-mm@kvack.org>; Tue, 14 May 2013 07:49:41 -0400 (EDT)
Received: by mail-da0-f42.google.com with SMTP id r6so266749dad.1
        for <linux-mm@kvack.org>; Tue, 14 May 2013 04:49:40 -0700 (PDT)
Message-ID: <519224CE.6030303@gmail.com>
Date: Tue, 14 May 2013 19:49:34 +0800
From: majianpeng <majianpeng@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 1/3] mm/kmemleak.c: Use %u to print ->checksum.
Content-Type: multipart/mixed;
 boundary="------------080509040303010101050606"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------080509040303010101050606
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Signed-off-by: Jianpeng Ma <majianpeng@gmail.com>
---
 mm/kmemleak.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index c8d7f31..b1525db 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -386,7 +386,7 @@ static void dump_object_info(struct kmemleak_object *object)
     pr_notice("  min_count = %d\n", object->min_count);
     pr_notice("  count = %d\n", object->count);
     pr_notice("  flags = 0x%lx\n", object->flags);
-    pr_notice("  checksum = %d\n", object->checksum);
+    pr_notice("  checksum = %u\n", object->checksum);
     pr_notice("  backtrace:\n");
     print_stack_trace(&trace, 4);
 }
-- 
1.8.3.rc1.44.gb387c77



--------------080509040303010101050606
Content-Type: text/x-patch;
 name="0001-mm-kmemleak.c-Use-u-to-print-checksum.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-mm-kmemleak.c-Use-u-to-print-checksum.patch"


--------------080509040303010101050606--
