Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B50196B031F
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:57:55 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 26so138829312pgy.6
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:57:55 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id n21si22246068pgj.254.2016.12.20.05.57.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 05:57:54 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id b1so11989394pgc.1
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:57:54 -0800 (PST)
From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] mm/vmalloc.c: use rb_entry_safe
Date: Tue, 20 Dec 2016 21:57:43 +0800
Message-Id: <81bb9820e5b9e4a1c596b3e76f88abf8c4a76cb0.1482221947.git.geliangtang@gmail.com>
In-Reply-To: <1e433cd03b01a3e89a22de5aa160b3442ff0cf16.1482222608.git.geliangtang@gmail.com>
References: <1e433cd03b01a3e89a22de5aa160b3442ff0cf16.1482222608.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, zijun_hu <zijun_hu@htc.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Chris Wilson <chris@chris-wilson.co.uk>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Use rb_entry_safe() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 mm/vmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index a558438..b9999fc 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2309,7 +2309,7 @@ EXPORT_SYMBOL_GPL(free_vm_area);
 #ifdef CONFIG_SMP
 static struct vmap_area *node_to_va(struct rb_node *n)
 {
-	return n ? rb_entry(n, struct vmap_area, rb_node) : NULL;
+	return rb_entry_safe(n, struct vmap_area, rb_node);
 }
 
 /**
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
