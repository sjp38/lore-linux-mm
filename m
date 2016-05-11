Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 51C746B0253
	for <linux-mm@kvack.org>; Wed, 11 May 2016 02:09:22 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id u5so66191269igk.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 23:09:22 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id j137si2133408oib.221.2016.05.10.23.09.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 23:09:21 -0700 (PDT)
Subject: [PATCH] Documentation/memcg: update kmem limit doc as codes behavior
References: <572B0105.50503@huawei.com> <20160505083221.GD4386@dhcp22.suse.cz>
From: Qiang Huang <h.huangqiang@huawei.com>
Message-ID: <5732CC23.2060101@huawei.com>
Date: Wed, 11 May 2016 14:07:31 +0800
MIME-Version: 1.0
In-Reply-To: <20160505083221.GD4386@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: corbet@lwn.net, tj@kernel.org, Zefan Li <lizefan@huawei.com>, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

The restriction of kmem setting is not there anymore because the
accounting is enabled by default even in the cgroup v1 - see
b313aeee2509 ("mm: memcontrol: enable kmem accounting for all
cgroups in the legacy hierarchy").

Update docs accordingly.

Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>
---
 Documentation/cgroup-v1/memory.txt | 14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
index ff71e16..b14abf2 100644
--- a/Documentation/cgroup-v1/memory.txt
+++ b/Documentation/cgroup-v1/memory.txt
@@ -280,17 +280,9 @@ the amount of kernel memory used by the system. Kernel memory is fundamentally
 different than user memory, since it can't be swapped out, which makes it
 possible to DoS the system by consuming too much of this precious resource.
 
-Kernel memory won't be accounted at all until limit on a group is set. This
-allows for existing setups to continue working without disruption.  The limit
-cannot be set if the cgroup have children, or if there are already tasks in the
-cgroup. Attempting to set the limit under those conditions will return -EBUSY.
-When use_hierarchy == 1 and a group is accounted, its children will
-automatically be accounted regardless of their limit value.
-
-After a group is first limited, it will be kept being accounted until it
-is removed. The memory limitation itself, can of course be removed by writing
--1 to memory.kmem.limit_in_bytes. In this case, kmem will be accounted, but not
-limited.
+Kernel memory accounting is enabled for all memory cgroups by default. But
+it can be disabled system-wide by passing cgroup.memory=nokmem to the kernel
+at boot time. In this case, kernel memory will not be accounted at all.
 
 Kernel memory limits are not imposed for the root cgroup. Usage for the root
 cgroup may or may not be accounted. The memory used is accumulated into
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
