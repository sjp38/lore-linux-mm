Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7E2F36B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 04:28:48 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so90589421pac.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 01:28:48 -0700 (PDT)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id qg1si18856345pbb.66.2015.09.07.01.28.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Sep 2015 01:28:47 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 7 Sep 2015 13:58:44 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id C56BDE0058
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 13:58:05 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t878SfbC34865392
	for <linux-mm@kvack.org>; Mon, 7 Sep 2015 13:58:41 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t878Selt009879
	for <linux-mm@kvack.org>; Mon, 7 Sep 2015 13:58:40 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 1/4] mm/kasan: Rename kasan_enabled to kasan_report_enabled
Date: Mon,  7 Sep 2015 13:58:36 +0530
Message-Id: <1441614519-20298-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, ryabinin.a.a@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

The function only disable/enable reporting. In the later patch
we will be adding a kasan early enable/disable. Rename kasan_enabled
to properly reflect its function.

Reviewed-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/kasan/kasan.h  | 2 +-
 mm/kasan/report.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index c242adf6bc85..a6b46cc94907 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -63,7 +63,7 @@ static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
 		<< KASAN_SHADOW_SCALE_SHIFT);
 }
 
-static inline bool kasan_enabled(void)
+static inline bool kasan_report_enabled(void)
 {
 	return !current->kasan_depth;
 }
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index e07c94fbd0ac..6c3f82b0240b 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -220,7 +220,7 @@ void kasan_report(unsigned long addr, size_t size,
 {
 	struct kasan_access_info info;
 
-	if (likely(!kasan_enabled()))
+	if (likely(!kasan_report_enabled()))
 		return;
 
 	info.access_addr = (void *)addr;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
