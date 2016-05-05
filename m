Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 801F26B0253
	for <linux-mm@kvack.org>; Thu,  5 May 2016 04:26:22 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id zy2so124012794pac.1
        for <linux-mm@kvack.org>; Thu, 05 May 2016 01:26:22 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id w63si9767016pfw.96.2016.05.05.01.26.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 May 2016 01:26:21 -0700 (PDT)
From: Qiang Huang <h.huangqiang@huawei.com>
Subject: [PATCH] Documentation/memcg: remove restriction of setting kmem limit
Message-ID: <572B0105.50503@huawei.com>
Date: Thu, 5 May 2016 16:15:01 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, corbet@lwn.net, tj@kernel.org, Zefan Li <lizefan@huawei.com>, hannes@cmpxchg.org, akpm@linux-foundation.org
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

We don't have this restriction for a long time, docs should
be fixed.

Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>
---
 Documentation/cgroup-v1/memory.txt | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
index ff71e16..d45b201 100644
--- a/Documentation/cgroup-v1/memory.txt
+++ b/Documentation/cgroup-v1/memory.txt
@@ -281,11 +281,9 @@ different than user memory, since it can't be swapped out, which makes it
 possible to DoS the system by consuming too much of this precious resource.
 
 Kernel memory won't be accounted at all until limit on a group is set. This
-allows for existing setups to continue working without disruption.  The limit
-cannot be set if the cgroup have children, or if there are already tasks in the
-cgroup. Attempting to set the limit under those conditions will return -EBUSY.
-When use_hierarchy == 1 and a group is accounted, its children will
-automatically be accounted regardless of their limit value.
+allows for existing setups to continue working without disruption. When
+use_hierarchy == 1 and a group is accounted, its children will automatically
+be accounted regardless of their limit value.
 
 After a group is first limited, it will be kept being accounted until it
 is removed. The memory limitation itself, can of course be removed by writing
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
