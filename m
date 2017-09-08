Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DBD586B04CE
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 18:15:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e64so2740558wmi.0
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 15:15:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b26sor1131844edj.19.2017.09.08.15.15.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Sep 2017 15:15:42 -0700 (PDT)
From: gurugio@gmail.com
Subject: [RFC] mm/memblock.c: using uninitialized value idx in memblock_add_range()
Date: Sat,  9 Sep 2017 00:15:33 +0200
Message-Id: <1504908933-31667-1-git-send-email-gurugio@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Gioh Kim <gurugio@hanmail.net>, Gioh Kim <gi-oh.kim@profitbricks.com>

From: Gioh Kim <gurugio@hanmail.net>

In memblock_add_range(), idx variable is a local value
but I cannot find initialization of idx value.
I checked idx value on my Qemu emulator. It was zero.
Is there any hidden initialization code?

Signed-off-by: Gioh Kim <gi-oh.kim@profitbricks.com>
---
 mm/memblock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 7b8a5db..23374bc 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -515,7 +515,7 @@ int __init_memblock memblock_add_range(struct memblock_type *type,
 	bool insert = false;
 	phys_addr_t obase = base;
 	phys_addr_t end = base + memblock_cap_size(base, &size);
-	int idx, nr_new;
+	int idx = 0, nr_new;
 	struct memblock_region *rgn;
 
 	if (!size)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
