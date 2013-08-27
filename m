Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id A8FE76B003B
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 05:39:15 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 04/11] memblock: Introduce memblock_set_current_limit_low() to set lower limit of memblock.
Date: Tue, 27 Aug 2013 17:37:41 +0800
Message-Id: <1377596268-31552-5-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Corresponding to memblock_set_current_limit_high(), we introduce memblock_set_current_limit_low()
to set the lowest limit for memblock.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/memblock.h |    9 ++++++++-
 mm/memblock.c            |    5 +++++
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 40eb18e..cabd685 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -174,6 +174,14 @@ static inline void memblock_dump_all(void)
 }
 
 /**
+ * memblock_set_current_limit_low - Set the current allocation lower limit to
+ *                         allow limiting allocations to what is currently
+ *                         accessible during boot
+ * @limit: New lower limit value (physical address)
+ */
+void memblock_set_current_limit_low(phys_addr_t limit);
+
+/**
  * memblock_set_current_limit_high - Set the current allocation upper limit to
  *                         allow limiting allocations to what is currently
  *                         accessible during boot
@@ -181,7 +189,6 @@ static inline void memblock_dump_all(void)
  */
 void memblock_set_current_limit_high(phys_addr_t limit);
 
-
 /*
  * pfn conversion functions
  *
diff --git a/mm/memblock.c b/mm/memblock.c
index 0dd5387..54c1c2e 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -989,6 +989,11 @@ void __init_memblock memblock_trim_memory(phys_addr_t align)
 	}
 }
 
+void __init_memblock memblock_set_current_limit_low(phys_addr_t limit)
+{
+	memblock.current_limit_low = limit;
+}
+
 void __init_memblock memblock_set_current_limit_high(phys_addr_t limit)
 {
 	memblock.current_limit_high = limit;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
