Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 40C416B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 11:20:40 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id g6so593964obn.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 08:20:40 -0700 (PDT)
Received: from resqmta-po-07v.sys.comcast.net (resqmta-po-07v.sys.comcast.net. [2001:558:fe16:19:96:114:154:166])
        by mx.google.com with ESMTPS id k193si52426816iok.152.2016.06.01.08.20.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 08:20:32 -0700 (PDT)
From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH] kasan: change memory hot-add error messages to info messages
Date: Wed,  1 Jun 2016 09:20:30 -0600
Message-Id: <1464794430-5486-1-git-send-email-shuahkh@osg.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com
Cc: Shuah Khan <shuahkh@osg.samsung.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Change the following memory hot-add error messages to info messages. There
is no need for these to be errors.

[    8.221108] kasan: WARNING: KASAN doesn't support memory hot-add
[    8.221117] kasan: Memory hot-add will be disabled

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
Note: This is applicable to 4.6 stable releases.

 mm/kasan/kasan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 18b6a2b..28439ac 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -763,8 +763,8 @@ static int kasan_mem_notifier(struct notifier_block *nb,
 
 static int __init kasan_memhotplug_init(void)
 {
-	pr_err("WARNING: KASAN doesn't support memory hot-add\n");
-	pr_err("Memory hot-add will be disabled\n");
+	pr_info("WARNING: KASAN doesn't support memory hot-add\n");
+	pr_info("Memory hot-add will be disabled\n");
 
 	hotplug_memory_notifier(kasan_mem_notifier, 0);
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
