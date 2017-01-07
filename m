Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8936B025E
	for <linux-mm@kvack.org>; Sat,  7 Jan 2017 04:33:27 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id l127so37376518lfl.3
        for <linux-mm@kvack.org>; Sat, 07 Jan 2017 01:33:27 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id x22si33953990lfb.339.2017.01.07.01.33.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Jan 2017 01:33:25 -0800 (PST)
Received: by mail-lf0-x244.google.com with SMTP id v186so1589818lfa.2
        for <linux-mm@kvack.org>; Sat, 07 Jan 2017 01:33:25 -0800 (PST)
From: Adygzhy Ondar <ondar07@gmail.com>
Subject: [PATCH] mm/bootmem.c: cosmetic improvement of code readability
Date: Sat,  7 Jan 2017 12:33:20 +0300
Message-Id: <1483781600-5136-1-git-send-email-ondar07@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: tj@kernel.org, linux-mm@kvack.org

The obvious number of bits in a byte is replaced
by BITS_PER_BYTE macro in bootmap_bytes()

Signed-off-by: Adygzhy Ondar <ondar07@gmail.com>
---
 mm/bootmem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index e8a55a3..9fedb27 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -53,7 +53,7 @@ early_param("bootmem_debug", bootmem_debug_setup);
 
 static unsigned long __init bootmap_bytes(unsigned long pages)
 {
-	unsigned long bytes = DIV_ROUND_UP(pages, 8);
+	unsigned long bytes = DIV_ROUND_UP(pages, BITS_PER_BYTE);
 
 	return ALIGN(bytes, sizeof(long));
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
