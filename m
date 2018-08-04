Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4ADB46B0005
	for <linux-mm@kvack.org>; Sat,  4 Aug 2018 18:08:30 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w128-v6so8234367oiw.14
        for <linux-mm@kvack.org>; Sat, 04 Aug 2018 15:08:30 -0700 (PDT)
Received: from gateway31.websitewelcome.com (gateway31.websitewelcome.com. [192.185.143.39])
        by mx.google.com with ESMTPS id c184-v6si5830184oib.137.2018.08.04.15.08.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Aug 2018 15:08:29 -0700 (PDT)
Received: from cm16.websitewelcome.com (cm16.websitewelcome.com [100.42.49.19])
	by gateway31.websitewelcome.com (Postfix) with ESMTP id CE9AE3658
	for <linux-mm@kvack.org>; Sat,  4 Aug 2018 17:08:28 -0500 (CDT)
Date: Sat, 4 Aug 2018 17:08:27 -0500
From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] mm/kasan/kasan_init: use true and false for boolean values
Message-ID: <20180804220827.GA12559@embeddedor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Gustavo A. R. Silva" <gustavo@embeddedor.com>

Return statements in functions returning bool should use true or false
instead of an integer value.

This code was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 mm/kasan/kasan_init.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index 7a2a2f1..c742dc5 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -42,7 +42,7 @@ static inline bool kasan_p4d_table(pgd_t pgd)
 #else
 static inline bool kasan_p4d_table(pgd_t pgd)
 {
-	return 0;
+	return false;
 }
 #endif
 #if CONFIG_PGTABLE_LEVELS > 3
@@ -54,7 +54,7 @@ static inline bool kasan_pud_table(p4d_t p4d)
 #else
 static inline bool kasan_pud_table(p4d_t p4d)
 {
-	return 0;
+	return false;
 }
 #endif
 #if CONFIG_PGTABLE_LEVELS > 2
@@ -66,7 +66,7 @@ static inline bool kasan_pmd_table(pud_t pud)
 #else
 static inline bool kasan_pmd_table(pud_t pud)
 {
-	return 0;
+	return false;
 }
 #endif
 pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
-- 
2.7.4
