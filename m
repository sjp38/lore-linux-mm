Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 433F3280272
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 22:48:12 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 199so4777717pfy.18
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 19:48:12 -0800 (PST)
Received: from heian.cn.fujitsu.com (mail.cn.fujitsu.com. [183.91.158.132])
        by mx.google.com with ESMTP id n4si2974757pgu.65.2018.01.16.19.48.10
        for <linux-mm@kvack.org>;
        Tue, 16 Jan 2018 19:48:11 -0800 (PST)
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Subject: [PATCH] mm/page_poison: Make early_page_poison_param __init
Date: Wed, 17 Jan 2018 11:47:57 +0800
Message-ID: <20180117034757.27024-1-douly.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dou Liyang <douly.fnst@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Michal Hocko <mhocko@suse.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org

The early_param() is only called during kernel initialization, So Linux
marks the function of it with __init macro to save memory.

But it forgot to mark the early_page_poison_param(). So, Make it __init
as well.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Philippe Ombredanne <pombredanne@nexb.com>
Cc: Kate Stewart <kstewart@linuxfoundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org
Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
---
 mm/page_poison.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_poison.c b/mm/page_poison.c
index e83fd44867de..aa2b3d34e8ea 100644
--- a/mm/page_poison.c
+++ b/mm/page_poison.c
@@ -9,7 +9,7 @@
 
 static bool want_page_poisoning __read_mostly;
 
-static int early_page_poison_param(char *buf)
+static int __init early_page_poison_param(char *buf)
 {
 	if (!buf)
 		return -EINVAL;
-- 
2.14.3



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
