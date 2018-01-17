Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 40422280272
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 22:47:55 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id n2so10541103pgs.0
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 19:47:55 -0800 (PST)
Received: from heian.cn.fujitsu.com (mail.cn.fujitsu.com. [183.91.158.132])
        by mx.google.com with ESMTP id h14si3320012pfj.360.2018.01.16.19.47.53
        for <linux-mm@kvack.org>;
        Tue, 16 Jan 2018 19:47:54 -0800 (PST)
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Subject: [PATCH] mm/page_owner: Make early_page_owner_param __init
Date: Wed, 17 Jan 2018 11:47:36 +0800
Message-ID: <20180117034736.26963-1-douly.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dou Liyang <douly.fnst@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org

The early_param() is only called during kernel initialization, So Linux
marks the functions of it with __init macro to save memory.

But it forgot to mark the early_page_owner_param(). So, Make it __init
as well.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org
Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
---
 mm/page_owner.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 8592543a0f15..745a8b8de206 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -35,7 +35,7 @@ static depot_stack_handle_t early_handle;
 
 static void init_early_allocated_pages(void);
 
-static int early_page_owner_param(char *buf)
+static int __init early_page_owner_param(char *buf)
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
