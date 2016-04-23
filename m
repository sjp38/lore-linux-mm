Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 133A16B0005
	for <linux-mm@kvack.org>; Sat, 23 Apr 2016 03:14:28 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e190so249508971pfe.3
        for <linux-mm@kvack.org>; Sat, 23 Apr 2016 00:14:28 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id q14si12519594par.57.2016.04.23.00.14.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 23 Apr 2016 00:14:27 -0700 (PDT)
Message-ID: <571B1F46.3040805@huawei.com>
Date: Sat, 23 Apr 2016 15:07:50 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: update the document of numa_zonelist_order
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik
 van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Kamezawa
 Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

commit 3193913ce62c63056bc67a6ae378beaf494afa66 change the default value
of numa_zonelist_order, this patch update the document.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 Documentation/sysctl/vm.txt |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index cb03684..34a5fec 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -581,15 +581,16 @@ Specify "[Nn]ode" for node order
 "Zone Order" orders the zonelists by zone type, then by node within each
 zone.  Specify "[Zz]one" for zone order.
 
-Specify "[Dd]efault" to request automatic configuration.  Autoconfiguration
-will select "node" order in following case.
-(1) if the DMA zone does not exist or
-(2) if the DMA zone comprises greater than 50% of the available memory or
-(3) if any node's DMA zone comprises greater than 70% of its local memory and
-    the amount of local memory is big enough.
-
-Otherwise, "zone" order will be selected. Default order is recommended unless
-this is causing problems for your system/application.
+Specify "[Dd]efault" to request automatic configuration.
+
+On 32-bit, the Normal zone needs to be preserved for allocations accessible
+by the kernel, so "zone" order will be selected.
+
+On 64-bit, devices that require DMA32/DMA are relatively rare, so "node"
+order will be selected.
+
+Default order is recommended unless this is causing problems for your
+system/application.
 
 ==============================================================
 
-- 
1.7.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
