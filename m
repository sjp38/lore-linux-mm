Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 29A746B005D
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 04:28:44 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 1/2] memory-hotplug: Add help info for CONFIG_MOVABLE_NODE option
Date: Fri, 14 Dec 2012 17:27:49 +0800
Message-Id: <1355477270-19922-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1355477270-19922-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1355477270-19922-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, tangchen@cn.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, mingo@elte.hu, penberg@kernel.org
Cc: torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch adds help info for CONFIG_MOVABLE_NODE option.

This option allows user to online all memory of a node as movable
memory. So that the whole node can be hotpluged. Users who don't
use hotplug feature are also fine with this option on since they
won't online memory as movable.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 mm/Kconfig |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 71259e0..2ad51cb 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -150,6 +150,16 @@ config MOVABLE_NODE
 	depends on X86_64
 	depends on NUMA
 	depends on BROKEN
+	help
+	  Allow a node to have only movable memory. Pages used by kernel, such
+	  as direct mapping pages can not be migrated. So the corresponding
+	  memory device can not be hotpluged. This option allows users to
+	  online all the memory of a node as movable memory so that the whole
+	  node can be hotpluged. Users who don't use hotplug feature are fine
+	  with this option on since they don't online memory as movable.
+
+	  Say Y here if you want to hotplug a whole node.
+	  Say N here if you want kernel to use memory on all nodes evenly.
 
 # eventually, we can have this option just 'select SPARSEMEM'
 config MEMORY_HOTPLUG
-- 
1.7.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
