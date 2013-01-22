Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 1D4866B0012
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 06:47:16 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH Bug fix 3/4] Bug fix: Remove the unused sanitize_zone_movable_limit() definition.
Date: Tue, 22 Jan 2013 19:46:20 +0800
Message-Id: <1358855181-6160-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1358855181-6160-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1358855181-6160-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com, julian.calaby@gmail.com, sfr@canb.auug.org.au
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org

When CONFIG_HAVE_MEMBLOCK_NODE_MAP is not defined, sanitize_zone_movable_limit()
is also not used. So remove it.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 mm/page_alloc.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cd6f8a6..2bd529e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4459,11 +4459,6 @@ static inline unsigned long __meminit zone_absent_pages_in_node(int nid,
 
 	return zholes_size[zone_type];
 }
-
-static void __meminit sanitize_zone_movable_limit(void)
-{
-}
-
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
