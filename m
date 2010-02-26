Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 00B786B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 08:39:00 -0500 (EST)
Received: by fxm22 with SMTP id 22so92743fxm.6
        for <linux-mm@kvack.org>; Fri, 26 Feb 2010 05:39:31 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH] memcg: fix typos in memcg_test.txt
Date: Fri, 26 Feb 2010 15:39:16 +0200
Message-Id: <1267191557-23444-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 Documentation/cgroups/memcg_test.txt |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
index 4d32e0e..f7f68b2 100644
--- a/Documentation/cgroups/memcg_test.txt
+++ b/Documentation/cgroups/memcg_test.txt
@@ -337,7 +337,7 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
 	race and lock dependency with other cgroup subsystems.
 
 	example)
-	# mount -t cgroup none /cgroup -t cpuset,memory,cpu,devices
+	# mount -t cgroup none /cgroup -o cpuset,memory,cpu,devices
 
 	and do task move, mkdir, rmdir etc...under this.
 
@@ -348,7 +348,7 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
 
 	For example, test like following is good.
 	(Shell-A)
-	# mount -t cgroup none /cgroup -t memory
+	# mount -t cgroup none /cgroup -o memory
 	# mkdir /cgroup/test
 	# echo 40M > /cgroup/test/memory.limit_in_bytes
 	# echo 0 > /cgroup/test/tasks
-- 
1.6.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
