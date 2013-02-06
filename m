Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 13C836B0007
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 00:25:54 -0500 (EST)
Message-ID: <5111E761.5070203@cn.fujitsu.com>
Date: Wed, 06 Feb 2013 13:17:21 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 3/7] fs/buffer.c: change type of max_buffer_heads to unsigned
 long
References: <5111E612.4010907@cn.fujitsu.com>
In-Reply-To: <5111E612.4010907@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

max_buffer_heads is calculated from nr_free_buffer_pages(), so
change its type to unsigned long in case of overflow.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 fs/buffer.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 7a75c3e..3eb675b 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -3227,7 +3227,7 @@ static struct kmem_cache *bh_cachep __read_mostly;
  * Once the number of bh's in the machine exceeds this level, we start
  * stripping them in writeback.
  */
-static int max_buffer_heads;
+static unsigned long max_buffer_heads;
 
 int buffer_heads_over_limit;
 
@@ -3343,7 +3343,7 @@ EXPORT_SYMBOL(bh_submit_read);
 
 void __init buffer_init(void)
 {
-	int nrpages;
+	unsigned long nrpages;
 
 	bh_cachep = kmem_cache_create("buffer_head",
 			sizeof(struct buffer_head), 0,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
