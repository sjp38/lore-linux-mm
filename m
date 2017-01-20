Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 310D86B0069
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 07:35:05 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id r82so99299475ywg.3
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 04:35:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w4si1973637ybb.181.2017.01.20.04.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jan 2017 04:35:04 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0KCYPli115190
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 07:35:04 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 283etf13q0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 07:35:04 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Fri, 20 Jan 2017 12:35:02 -0000
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH 2/3] memblock: also dump physmem list within __memblock_dump_all
Date: Fri, 20 Jan 2017 13:34:55 +0100
In-Reply-To: <20170120123456.46508-1-heiko.carstens@de.ibm.com>
References: <20170120123456.46508-1-heiko.carstens@de.ibm.com>
Message-Id: <20170120123456.46508-3-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since commit 70210ed950b5 ("mm/memblock: add physical memory list")
the memblock structure knows about a physical memory list.

The physical memory list should also be dumped if memblock_dump_all()
is called in case memblock_debug is switched on. This makes debugging
a bit easier.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 mm/memblock.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memblock.c b/mm/memblock.c
index acbfa1dffff2..fbaaf713827c 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1709,6 +1709,9 @@ void __init_memblock __memblock_dump_all(void)
 
 	memblock_dump(&memblock.memory, "memory");
 	memblock_dump(&memblock.reserved, "reserved");
+#ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
+	memblock_dump(&memblock.physmem, "physmem");
+#endif
 }
 
 void __init memblock_allow_resize(void)
-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
