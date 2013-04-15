Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id CCCF06B0027
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 05:43:58 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 3/3] memblock: Fix missing comment of memblock_insert_region().
Date: Mon, 15 Apr 2013 17:46:47 +0800
Message-Id: <1366019207-27818-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1366019207-27818-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1366019207-27818-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, mgorman@suse.de, tj@kernel.org, liwanp@linux.vnet.ibm.com
Cc: tangchen@cn.fujitsu.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

There is no comment for parameter nid of memblock_insert_region().
This patch adds comment for it.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 mm/memblock.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index b8d9147..16eda3d 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -322,10 +322,11 @@ static void __init_memblock memblock_merge_regions(struct memblock_type *type)
 
 /**
  * memblock_insert_region - insert new memblock region
- * @type: memblock type to insert into
- * @idx: index for the insertion point
- * @base: base address of the new region
- * @size: size of the new region
+ * @type:	memblock type to insert into
+ * @idx:	index for the insertion point
+ * @base:	base address of the new region
+ * @size:	size of the new region
+ * @nid:	node id of the new region
  *
  * Insert new memblock region [@base,@base+@size) into @type at @idx.
  * @type must already have extra room to accomodate the new region.
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
