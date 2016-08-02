Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 84C926B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 11:59:53 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m130so384723033ioa.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 08:59:53 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0090.outbound.protection.outlook.com. [104.47.1.90])
        by mx.google.com with ESMTPS id h133si2236390oib.179.2016.08.02.08.59.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 08:59:52 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] kasan-improve-double-free-reports-fix
Date: Tue, 2 Aug 2016 19:00:54 +0300
Message-ID: <1470153654-30160-1-git-send-email-aryabinin@virtuozzo.com>
In-Reply-To: <CAG_fn=WP2VmNNuzp1YMi+vPLaG9B3JH9TD4FfzxVyeZL2AyM_Q@mail.gmail.com>
References: <CAG_fn=WP2VmNNuzp1YMi+vPLaG9B3JH9TD4FfzxVyeZL2AyM_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>

Change doulbe free message per Alexander

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
---
 mm/kasan/report.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index ee2bdb4..24c1211 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -172,7 +172,7 @@ void kasan_report_double_free(struct kmem_cache *cache, void *object,
 	unsigned long flags;
 
 	kasan_start_report(&flags);
-	pr_err("BUG: Double free or corrupt pointer\n");
+	pr_err("BUG: Double free or freeing an invalid pointer\n");
 	pr_err("Unexpected shadow byte: 0x%hhX\n", shadow);
 	kasan_object_err(cache, object);
 	kasan_end_report(&flags);
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
