Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CE6796007F3
	for <linux-mm@kvack.org>; Sun, 18 Jul 2010 19:35:07 -0400 (EDT)
Received: by pxi7 with SMTP id 7so1920043pxi.14
        for <linux-mm@kvack.org>; Sun, 18 Jul 2010 16:35:06 -0700 (PDT)
Message-ID: <4C438FA5.2050503@gmail.com>
Date: Mon, 19 Jul 2010 07:35:01 +0800
From: shenghui <crosslonelyover@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] turn BUG_ON for out of bound in mb_cache_entry_find_first/mb_cache_entry_find_next
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>, kernel-janitors <kernel-janitors@vger.kernel.org>, error27@gmail.com
List-ID: <linux-mm.kvack.org>

Sorry. Will you recommend to me one mail client?
I have been suffering reformat by client these days.
Thanks,


Signed-off-by: Wang Sheng-Hui <crosslonelyover@gmail.com>
---
 fs/mbcache.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/mbcache.c b/fs/mbcache.c
index 5697d9e..5f96b82 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -614,7 +614,7 @@ mb_cache_entry_find_first(struct mb_cache *cache, int index,
 	struct list_head *l;
 	struct mb_cache_entry *ce;
 
-	mb_assert(index < mb_cache_indexes(cache));
+	BUG_ON(!(index < mb_cache_indexes(cache)));
 	spin_lock(&mb_cache_spinlock);
 	l = cache->c_indexes_hash[index][bucket].next;
 	ce = __mb_cache_entry_find(l, &cache->c_indexes_hash[index][bucket],
@@ -652,7 +652,7 @@ mb_cache_entry_find_next(struct mb_cache_entry *prev, int index,
 	struct list_head *l;
 	struct mb_cache_entry *ce;
 
-	mb_assert(index < mb_cache_indexes(cache));
+	BUG_ON(!(index < mb_cache_indexes(cache)));
 	spin_lock(&mb_cache_spinlock);
 	l = prev->e_indexes[index].o_list.next;
 	ce = __mb_cache_entry_find(l, &cache->c_indexes_hash[index][bucket],
-- 
1.7.1.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
