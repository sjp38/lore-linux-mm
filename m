Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DFEAF6B002D
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 21:01:40 -0500 (EST)
Received: by gyg10 with SMTP id 10so1600064gyg.14
        for <linux-mm@kvack.org>; Tue, 08 Nov 2011 18:01:39 -0800 (PST)
Message-ID: <4EB9DEF6.4080905@gmail.com>
Date: Wed, 09 Nov 2011 10:01:26 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] mm/memblock.c: return -ENOMEM instead of -ENXIO on failure
 of debugfs_create_dir in memblock_init_debugfs
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On the failure of debugfs_create_dir, we should return -ENOMEM
instead of -ENXIO.

The patch is against 3.1.


Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/memblock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index ccbf973..4d4d5ee 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -852,7 +852,7 @@ static int __init memblock_init_debugfs(void)
 {
 	struct dentry *root = debugfs_create_dir("memblock", NULL);
 	if (!root)
-		return -ENXIO;
+		return -ENOMEM;
 	debugfs_create_file("memory", S_IRUGO, root, &memblock.memory, &memblock_debug_fops);
 	debugfs_create_file("reserved", S_IRUGO, root, &memblock.reserved, &memblock_debug_fops);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
