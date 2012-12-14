Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 5C5896B0062
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 04:28:46 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 2/2] memory-hotplug: Disable CONFIG_MOVABLE_NODE option by default.
Date: Fri, 14 Dec 2012 17:27:50 +0800
Message-Id: <1355477270-19922-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1355477270-19922-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1355477270-19922-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, tangchen@cn.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, mingo@elte.hu, penberg@kernel.org
Cc: torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch set CONFIG_MOVABLE_NODE to "default n" instead of
"depends on BROKEN".

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 mm/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 2ad51cb..1ed3295 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -149,7 +149,7 @@ config MOVABLE_NODE
 	depends on NO_BOOTMEM
 	depends on X86_64
 	depends on NUMA
-	depends on BROKEN
+	default n
 	help
 	  Allow a node to have only movable memory. Pages used by kernel, such
 	  as direct mapping pages can not be migrated. So the corresponding
-- 
1.7.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
