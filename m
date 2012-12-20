Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id B9F036B0068
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 14:14:02 -0500 (EST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm: memory_hotplug: no need to check res twice in add_memory
Date: Thu, 20 Dec 2012 14:11:32 -0500
Message-Id: <1356030701-16284-24-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1356030701-16284-1-git-send-email-sasha.levin@oracle.com>
References: <1356030701-16284-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Sasha Levin <sasha.levin@oracle.com>

Remove one redundant check of res.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/memory_hotplug.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 962e353..4082244 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -898,8 +898,7 @@ error:
 	/* rollback pgdat allocation and others */
 	if (new_pgdat)
 		rollback_node_hotadd(nid, pgdat);
-	if (res)
-		release_memory_resource(res);
+	release_memory_resource(res);
 
 out:
 	unlock_memory_hotplug();
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
