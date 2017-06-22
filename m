Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E33706B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 05:00:53 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r103so2779932wrb.0
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:00:53 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id 69si988027wra.135.2017.06.22.02.00.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Jun 2017 02:00:52 -0700 (PDT)
From: Colin King <colin.king@canonical.com>
Subject: [PATCH] kasan: make function get_wild_bug_type static
Date: Thu, 22 Jun 2017 10:00:49 +0100
Message-Id: <20170622090049.10658-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The helper function get_wild_bug_type does not need to be in global scope,
so make it static.

Cleans up sparse warning:
"symbol 'get_wild_bug_type' was not declared. Should it be static?"

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 mm/kasan/report.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index beee0e980e2d..04bb1d3eb9ec 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -107,7 +107,7 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
 	return bug_type;
 }
 
-const char *get_wild_bug_type(struct kasan_access_info *info)
+static const char *get_wild_bug_type(struct kasan_access_info *info)
 {
 	const char *bug_type = "unknown-crash";
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
