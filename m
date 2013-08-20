Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id DB4626B0037
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 13:13:06 -0400 (EDT)
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 2/7] drivers: base: remove unneeded variable
Date: Tue, 20 Aug 2013 12:12:58 -0500
Message-Id: <1377018783-26756-2-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Yinghai Lu <yinghai@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

The error variable is not needed.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/base/memory.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 278bb3da..e771e2b 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -565,16 +565,13 @@ static const struct attribute_group *memory_memblk_attr_groups[] = {
 static
 int register_memory(struct memory_block *memory)
 {
-	int error;
-
 	memory->dev.bus = &memory_subsys;
 	memory->dev.id = memory->start_section_nr / sections_per_block;
 	memory->dev.release = memory_block_release;
 	memory->dev.groups = memory_memblk_attr_groups;
 	memory->dev.offline = memory->state == MEM_OFFLINE;
 
-	error = device_register(&memory->dev);
-	return error;
+	return device_register(&memory->dev);
 }
 
 static int init_memory_block(struct memory_block **memory,
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
