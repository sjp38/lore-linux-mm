Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 170C56B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 03:55:32 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so39712530pac.2
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 00:55:31 -0700 (PDT)
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com. [202.81.31.148])
        by mx.google.com with ESMTPS id i10si40131790pat.138.2015.09.03.00.55.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Sep 2015 00:55:31 -0700 (PDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 3 Sep 2015 17:55:26 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id B1F4F2CE8055
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 17:55:24 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t837tFn939256306
	for <linux-mm@kvack.org>; Thu, 3 Sep 2015 17:55:24 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t837sp8S016038
	for <linux-mm@kvack.org>; Thu, 3 Sep 2015 17:54:51 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 1/4] kasan: Rename kasan_enabled to kasan_report_enabled
Date: Thu,  3 Sep 2015 13:24:20 +0530
Message-Id: <1441266863-5435-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>
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
