Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BA68D6B002E
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 06:26:05 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v6 7/8] Display current tcp memory allocation in kmem cgroup
Date: Mon, 10 Oct 2011 14:24:27 +0400
Message-Id: <1318242268-2234-8-git-send-email-glommer@parallels.com>
In-Reply-To: <1318242268-2234-1-git-send-email-glommer@parallels.com>
References: <1318242268-2234-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, Glauber Costa <glommer@parallels.com>

This patch introduces kmem.tcp_current_memory file, living in the
kmem_cgroup filesystem. It is a simple read-only file that displays the
amount of kernel memory currently consumed by the cgroup.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: David S. Miller <davem@davemloft.net>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
CC: Eric W. Biederman <ebiederm@xmission.com>
---
 Documentation/cgroups/memory.txt |    1 +
 mm/memcontrol.c                  |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index c1db134..00f1a88 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -79,6 +79,7 @@ Brief summary of control files.
  memory.independent_kmem_limit	 # select whether or not kernel memory limits are
 				   independent of user limits
  memory.kmem.tcp.limit_in_bytes  # set/show hard limit for tcp buf memory
+ memory.kmem.tcp.usage_in_bytes  # show current tcp buf memory allocation
 
 1. History
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 60e0ec0..ca08be2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -543,6 +543,11 @@ static struct cftype tcp_files[] = {
 		.read_u64 = mem_cgroup_read,
 		.private = MEMFILE_PRIVATE(_KMEM_TCP, RES_LIMIT),
 	},
+	{
+		.name = "kmem.tcp.usage_in_bytes",
+		.read_u64 = mem_cgroup_read,
+		.private = MEMFILE_PRIVATE(_KMEM_TCP, RES_USAGE),
+	},
 };
 
 static void tcp_create_cgroup(struct mem_cgroup *cg, struct cgroup_subsys *ss)
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
