Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id AB9526B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 10:30:45 -0400 (EDT)
Received: by pdea3 with SMTP id a3so5389032pde.3
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 07:30:45 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id pd3si3143226pdb.208.2015.04.01.07.30.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Apr 2015 07:30:44 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] Documentation/memcg: update memcg/kmem status
Date: Wed, 1 Apr 2015 17:30:36 +0300
Message-ID: <1427898636-4505-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Memcg/kmem reclaim support has been finally merged. Reflect this in the
documentation.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 Documentation/cgroups/memory.txt |    8 +++-----
 init/Kconfig                     |    6 ------
 2 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index a22df3ad35ff..f456b4315e86 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -275,11 +275,6 @@ When oom event notifier is registered, event will be delivered.
 
 2.7 Kernel Memory Extension (CONFIG_MEMCG_KMEM)
 
-WARNING: Current implementation lacks reclaim support. That means allocation
-	 attempts will fail when close to the limit even if there are plenty of
-	 kmem available for reclaim. That makes this option unusable in real
-	 life so DO NOT SELECT IT unless for development purposes.
-
 With the Kernel memory extension, the Memory Controller is able to limit
 the amount of kernel memory used by the system. Kernel memory is fundamentally
 different than user memory, since it can't be swapped out, which makes it
@@ -345,6 +340,9 @@ set:
     In this case, the admin could set up K so that the sum of all groups is
     never greater than the total memory, and freely set U at the cost of his
     QoS.
+    WARNING: In the current implementation, memory reclaim will NOT be
+    triggered for a cgroup when it hits K while staying below U, which makes
+    this setup impractical.
 
     U != 0, K >= U:
     Since kmem charges will also be fed to the user counter and reclaim will be
diff --git a/init/Kconfig b/init/Kconfig
index 7766b500f679..caffca37ccb7 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1059,12 +1059,6 @@ config MEMCG_KMEM
 	  the kmem extension can use it to guarantee that no group of processes
 	  will ever exhaust kernel resources alone.
 
-	  WARNING: Current implementation lacks reclaim support. That means
-	  allocation attempts will fail when close to the limit even if there
-	  are plenty of kmem available for reclaim. That makes this option
-	  unusable in real life so DO NOT SELECT IT unless for development
-	  purposes.
-
 config CGROUP_HUGETLB
 	bool "HugeTLB Resource Controller for Control Groups"
 	depends on HUGETLB_PAGE
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
