Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 3D4376B0031
	for <linux-mm@kvack.org>; Sun,  8 Sep 2013 23:28:51 -0400 (EDT)
Message-ID: <522D403C.3040801@huawei.com>
Date: Mon, 9 Sep 2013 11:27:56 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] mm/cleanup: use pfn_to_nid() instead of page_to_nid(pfn_to_page())
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>

Use "pfn_to_nid(pfn)" instead of "page_to_nid(pfn_to_page(pfn))".

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/memory_hotplug.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 85f80b7..a95dd28 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -937,7 +937,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	arg.nr_pages = nr_pages;
 	node_states_check_changes_online(nr_pages, zone, &arg);
 
-	nid = page_to_nid(pfn_to_page(pfn));
+	nid = pfn_to_nid(pfn);
 
 	ret = memory_notify(MEM_GOING_ONLINE, &arg);
 	ret = notifier_to_errno(ret);
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
