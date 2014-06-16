Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4879B6B0036
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 05:29:18 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id hz1so1114352pad.38
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 02:29:18 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id ey5si10324407pbb.58.2014.06.16.02.29.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 02:29:17 -0700 (PDT)
Message-ID: <539EB803.9070001@huawei.com>
Date: Mon, 16 Jun 2014 17:25:23 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 8/8] doc: update Documentation/sysctl/vm.txt
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, aquini@redhat.com, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, Li Zefan <lizefan@huawei.com>

Update the doc.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 Documentation/sysctl/vm.txt |   43 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index dd9d0e3..8008e53 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -20,6 +20,10 @@ Currently, these files are in /proc/sys/vm:
 
 - admin_reserve_kbytes
 - block_dump
+- cache_limit_mbytes
+- cache_limit_ratio
+- cache_reclaim_s
+- cache_reclaim_weight
 - compact_memory
 - dirty_background_bytes
 - dirty_background_ratio
@@ -97,6 +101,45 @@ information on block I/O debugging is in Documentation/laptops/laptop-mode.txt.
 
 ==============================================================
 
+cache_limit_mbytes
+
+This is used to limit page cache amount. The input unit is MB, value range
+is from 0 to totalram_pages. If this is set to 0, it will not limit page cache.
+When written to the file, cache_limit_ratio will be updated too.
+
+The default value is 0.
+
+==============================================================
+
+cache_limit_ratio
+
+This is used to limit page cache amount. The input unit is percent, value
+range is from 0 to 100. If this is set to 0, it will not limit page cache.
+When written to the file, cache_limit_mbytes will be updated too.
+
+The default value is 0.
+
+==============================================================
+
+cache_reclaim_s
+
+This is used to reclaim page cache in circles. The input unit is second,
+the minimum value is 0. If this is set to 0, it will disable the feature.
+
+The default value is 0.
+
+==============================================================
+
+cache_reclaim_weight
+
+This is used to speed up page cache reclaim. It depend on enabling
+cache_limit_mbytes/cache_limit_ratio or cache_reclaim_s. Value range is
+from 1(slow) to 100(fast).
+
+The default value is 1.
+
+==============================================================
+
 compact_memory
 
 Available only when CONFIG_COMPACTION is set. When 1 is written to the file,
-- 
1.6.0.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
