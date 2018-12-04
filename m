Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id AF8196B6CFA
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 00:14:29 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id j30so12665612wre.16
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 21:14:29 -0800 (PST)
Received: from delany.relativists.org (delany.relativists.org. [176.31.98.17])
        by mx.google.com with ESMTPS id b1si12076826wrj.176.2018.12.03.21.14.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Dec 2018 21:14:27 -0800 (PST)
From: =?UTF-8?q?Adeodato=20Sim=C3=B3?= <dato@net.com.org.es>
Subject: [PATCH 3/3] mm: add missing declaration of memmap_init in linux/mm.h
Date: Tue,  4 Dec 2018 02:14:24 -0300
Message-Id: <fccff943020c51f2319b673dd9e5720672e64a6e.1543899764.git.dato@net.com.org.es>
In-Reply-To: <466ad4ebe5d788e7be6a14fbbcaaa9596bac7141.1543899764.git.dato@net.com.org.es>
References: <466ad4ebe5d788e7be6a14fbbcaaa9596bac7141.1543899764.git.dato@net.com.org.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org

This follows-up commit dfb3ccd00a06 ("mm: make memmap_init a proper
function"), which changed memmap_init from macro to function.

Signed-off-by: Adeodato Simó <dato@net.com.org.es>
---
scripts/checkpatch.pl complained about use of extern for a prototype,
but I preferred to maintain consistency with surrounding code. -d

 include/linux/mm.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3eb3bf7774f1..8597b864dd91 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2268,6 +2268,8 @@ static inline void zero_resv_unavail(void) {}
 #endif
 
 extern void set_dma_reserve(unsigned long new_dma_reserve);
+extern void memmap_init(unsigned long size, int nid,
+			unsigned long zone, unsigned long start_pfn);
 extern void memmap_init_zone(unsigned long, int, unsigned long, unsigned long,
 		enum memmap_context, struct vmem_altmap *);
 extern void setup_per_zone_wmarks(void);
-- 
2.19.2
