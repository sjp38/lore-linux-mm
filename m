Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C166C6B0085
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 10:10:04 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id kx10so3198263pab.11
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 07:10:04 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id uz6si2414047pac.156.2015.02.04.07.10.03
        for <linux-mm@kvack.org>;
        Wed, 04 Feb 2015 07:10:04 -0800 (PST)
Date: Wed, 4 Feb 2015 23:09:42 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [PATCH mmotm] x86_64: __asan_load2 can be static
Message-ID: <20150204150942.GA100965@lkp-sb04>
References: <201502042321.YTAJE4EN%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502042321.YTAJE4EN%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

mm/kasan/kasan.c:276:1: sparse: symbol '__asan_load2' was not declared. Should it be static?
mm/kasan/kasan.c:277:1: sparse: symbol '__asan_load4' was not declared. Should it be static?
mm/kasan/kasan.c:278:1: sparse: symbol '__asan_load8' was not declared. Should it be static?
mm/kasan/kasan.c:279:1: sparse: symbol '__asan_load16' was not declared. Should it be static?
mm/kasan/report.c:188:1: sparse: symbol '__asan_report_load1_noabort' was not declared. Should it be static?
mm/kasan/report.c:189:1: sparse: symbol '__asan_report_load2_noabort' was not declared. Should it be static?
mm/kasan/report.c:190:1: sparse: symbol '__asan_report_load4_noabort' was not declared. Should it be static?
mm/kasan/report.c:191:1: sparse: symbol '__asan_report_load8_noabort' was not declared. Should it be static?
mm/kasan/report.c:192:1: sparse: symbol '__asan_report_load16_noabort' was not declared. Should it be static?
mm/kasan/report.c:193:1: sparse: symbol '__asan_report_store1_noabort' was not declared. Should it be static?
mm/kasan/report.c:194:1: sparse: symbol '__asan_report_store2_noabort' was not declared. Should it be static?
mm/kasan/report.c:195:1: sparse: symbol '__asan_report_store4_noabort' was not declared. Should it be static?
mm/kasan/report.c:196:1: sparse: symbol '__asan_report_store8_noabort' was not declared. Should it be static?
mm/kasan/report.c:197:1: sparse: symbol '__asan_report_store16_noabort' was not declared. Should it be static?

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 kasan.c  |    8 ++++----
 report.c |   20 ++++++++++----------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index def8110..6066986 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -273,10 +273,10 @@ static __always_inline void check_memory_region(unsigned long addr,
 	EXPORT_SYMBOL(__asan_store##size##_noabort)
 
 DEFINE_ASAN_LOAD_STORE(1);
-DEFINE_ASAN_LOAD_STORE(2);
-DEFINE_ASAN_LOAD_STORE(4);
-DEFINE_ASAN_LOAD_STORE(8);
-DEFINE_ASAN_LOAD_STORE(16);
+static DEFINE_ASAN_LOAD_STORE(2);
+static DEFINE_ASAN_LOAD_STORE(4);
+static DEFINE_ASAN_LOAD_STORE(8);
+static DEFINE_ASAN_LOAD_STORE(16);
 
 void __asan_loadN(unsigned long addr, size_t size)
 {
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 5835d69..be56573 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -185,16 +185,16 @@ void __asan_report_store##size##_noabort(unsigned long addr) \
 }                                                          \
 EXPORT_SYMBOL(__asan_report_store##size##_noabort)
 
-DEFINE_ASAN_REPORT_LOAD(1);
-DEFINE_ASAN_REPORT_LOAD(2);
-DEFINE_ASAN_REPORT_LOAD(4);
-DEFINE_ASAN_REPORT_LOAD(8);
-DEFINE_ASAN_REPORT_LOAD(16);
-DEFINE_ASAN_REPORT_STORE(1);
-DEFINE_ASAN_REPORT_STORE(2);
-DEFINE_ASAN_REPORT_STORE(4);
-DEFINE_ASAN_REPORT_STORE(8);
-DEFINE_ASAN_REPORT_STORE(16);
+static DEFINE_ASAN_REPORT_LOAD(1);
+static DEFINE_ASAN_REPORT_LOAD(2);
+static DEFINE_ASAN_REPORT_LOAD(4);
+static DEFINE_ASAN_REPORT_LOAD(8);
+static DEFINE_ASAN_REPORT_LOAD(16);
+static DEFINE_ASAN_REPORT_STORE(1);
+static DEFINE_ASAN_REPORT_STORE(2);
+static DEFINE_ASAN_REPORT_STORE(4);
+static DEFINE_ASAN_REPORT_STORE(8);
+static DEFINE_ASAN_REPORT_STORE(16);
 
 void __asan_report_load_n_noabort(unsigned long addr, size_t size)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
