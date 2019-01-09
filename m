Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v3 PATCH 5/5] doc: memcontrol: add description for wipe_on_offline
Date: Thu, 10 Jan 2019 03:14:45 +0800
Message-Id: <1547061285-100329-6-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: linux-kernel-owner@vger.kernel.org
To: mhocko@suse.com, hannes@cmpxchg.org, shakeelb@google.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Add desprition of wipe_on_offline interface in cgroup documents.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shakeel Butt <shakeelb@google.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 Documentation/admin-guide/cgroup-v2.rst |  9 +++++++++
 Documentation/cgroup-v1/memory.txt      | 10 ++++++++++
 2 files changed, 19 insertions(+)

diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
index 0290c65..e4ef08c 100644
--- a/Documentation/admin-guide/cgroup-v2.rst
+++ b/Documentation/admin-guide/cgroup-v2.rst
@@ -1303,6 +1303,15 @@ PAGE_SIZE multiple when read back.
         memory pressure happens. If you want to avoid that, force_empty will be
         useful.
 
+  memory.wipe_on_offline
+
+        This is similar to force_empty, but it just does memory reclaim
+        asynchronously in css offline kworker.
+
+        Writing into 1 will enable it, disable it by writing into 0.
+
+        It would reclaim as much as possible memory just as what force_empty does.
+
 
 Usage Guidelines
 ~~~~~~~~~~~~~~~~
diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
index 8e2cb1d..1c6e1ca 100644
--- a/Documentation/cgroup-v1/memory.txt
+++ b/Documentation/cgroup-v1/memory.txt
@@ -71,6 +71,7 @@ Brief summary of control files.
  memory.stat			 # show various statistics
  memory.use_hierarchy		 # set/show hierarchical account enabled
  memory.force_empty		 # trigger forced page reclaim
+ memory.wipe_on_offline		 # trigger forced page reclaim when offlining
  memory.pressure_level		 # set memory pressure notifications
  memory.swappiness		 # set/show swappiness parameter of vmscan
 				 (See sysctl's vm.swappiness)
@@ -581,6 +582,15 @@ hierarchical_<counter>=<counter pages> N0=<node 0 pages> N1=<node 1 pages> ...
 
 The "total" count is sum of file + anon + unevictable.
 
+5.7 wipe_on_offline
+
+This is similar to force_empty, but it just does memory reclaim asynchronously
+in css offline kworker.
+
+Writing into 1 will enable it, disable it by writing into 0.
+
+It would reclaim as much as possible memory just as what force_empty does.
+
 6. Hierarchy support
 
 The memory controller supports a deep hierarchy and hierarchical accounting.
-- 
1.8.3.1
