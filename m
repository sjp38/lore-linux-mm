Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5319C6B0255
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 10:48:07 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so10949719wic.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:48:06 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id y14si11354997wiv.17.2015.09.03.07.48.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 07:48:06 -0700 (PDT)
Received: by wibz8 with SMTP id z8so101716050wib.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:48:05 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 4/7] kasan: update log messages
Date: Thu,  3 Sep 2015 16:47:39 +0200
Message-Id: <84eff5df162012da2d6161aa49054e89605012de.1441290220.git.andreyknvl@google.com>
In-Reply-To: <cover.1441290219.git.andreyknvl@google.com>
References: <cover.1441290219.git.andreyknvl@google.com>
In-Reply-To: <cover.1441290219.git.andreyknvl@google.com>
References: <cover.1441290219.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: dvyukov@google.com, glider@google.com, kcc@google.com, Andrey Konovalov <andreyknvl@google.com>

We decided to use KASAN as the short name of the tool and
KernelAddressSanitizer as the full one.
Update log messages according to that.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/x86/mm/kasan_init_64.c | 2 +-
 mm/kasan/kasan.c            | 2 +-
 mm/kasan/report.c           | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 9ce5da2..d470cf2 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -126,5 +126,5 @@ void __init kasan_init(void)
 	__flush_tlb_all();
 	init_task.kasan_depth = 0;
 
-	pr_info("Kernel address sanitizer initialized\n");
+	pr_info("KernelAddressSanitizer initialized\n");
 }
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 035f268..61c9620 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -519,7 +519,7 @@ static int kasan_mem_notifier(struct notifier_block *nb,
 
 static int __init kasan_memhotplug_init(void)
 {
-	pr_err("WARNING: KASan doesn't support memory hot-add\n");
+	pr_err("WARNING: KASAN doesn't support memory hot-add\n");
 	pr_err("Memory hot-add will be disabled\n");
 
 	hotplug_memory_notifier(kasan_mem_notifier, 0);
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 6126272..31b91b9 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -90,7 +90,7 @@ static void print_error_description(struct kasan_access_info *info)
 		break;
 	}
 
-	pr_err("BUG: KASan: %s in %pS at addr %p\n",
+	pr_err("BUG: KASAN: %s in %pS at addr %p\n",
 		bug_type, (void *)info->ip,
 		info->access_addr);
 	pr_err("%s of size %zu by task %s/%d\n",
@@ -213,7 +213,7 @@ static void kasan_report_error(struct kasan_access_info *info)
 			bug_type = "user-memory-access";
 		else
 			bug_type = "wild-memory-access";
-		pr_err("BUG: KASan: %s on address %p\n",
+		pr_err("BUG: KASAN: %s on address %p\n",
 			bug_type, info->access_addr);
 		pr_err("%s of size %zu by task %s/%d\n",
 			info->is_write ? "Write" : "Read",
-- 
2.5.0.457.gab17608

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
