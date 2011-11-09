Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9781E6B002D
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 06:37:20 -0500 (EST)
Received: by iaae16 with SMTP id e16so2402838iaa.14
        for <linux-mm@kvack.org>; Wed, 09 Nov 2011 03:37:18 -0800 (PST)
Message-ID: <4EBA65E5.1050506@gmail.com>
Date: Wed, 09 Nov 2011 19:37:09 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 1/3][RESEND] mm/memblock.c: return -ENOMEM instead of -ENXIO
 on failure of debugfs_create_dir in memblock_init_debugfs
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On the failure of debugfs_create_dir, we should return -ENOMEM
instead of -ENXIO.

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
