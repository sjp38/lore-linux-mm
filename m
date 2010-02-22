Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1357762001B
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 10:44:05 -0500 (EST)
Received: by mail-fx0-f222.google.com with SMTP id 22so2837093fxm.6
        for <linux-mm@kvack.org>; Mon, 22 Feb 2010 07:43:59 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH v2 -mmotm 4/4] memcg: Update memcg_test.txt to describe memory thresholds
Date: Mon, 22 Feb 2010 17:43:42 +0200
Message-Id: <31d1e8b43222486d8bb1873007b5cde1b5067f28.1266853234.git.kirill@shutemov.name>
In-Reply-To: <458c3169608cb333f390b2cb732565fec9fec67e.1266853234.git.kirill@shutemov.name>
References: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name>
 <690745ebd257c74a1c47d552fec7fbb0b5efb7d0.1266853233.git.kirill@shutemov.name>
 <458c3169608cb333f390b2cb732565fec9fec67e.1266853234.git.kirill@shutemov.name>
In-Reply-To: <458c3169608cb333f390b2cb732565fec9fec67e.1266853234.git.kirill@shutemov.name>
References: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name> <690745ebd257c74a1c47d552fec7fbb0b5efb7d0.1266853233.git.kirill@shutemov.name> <458c3169608cb333f390b2cb732565fec9fec67e.1266853234.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

Decription of sanity check for memory thresholds.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memcg_test.txt |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
index e011488..4d32e0e 100644
--- a/Documentation/cgroups/memcg_test.txt
+++ b/Documentation/cgroups/memcg_test.txt
@@ -396,3 +396,24 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
 	memory.stat of both A and B.
 	See 8.2 of Documentation/cgroups/memory.txt to see what value should be
 	written to move_charge_at_immigrate.
+
+ 9.10 Memory thresholds
+	Memory controler implements memory thresholds using cgroups notification
+	API. You can use Documentation/cgroups/cgroup_event_listener.c to test
+	it.
+
+	(Shell-A) Create cgroup and run event listener
+	# mkdir /cgroup/A
+	# ./cgroup_event_listener /cgroup/A/memory.usage_in_bytes 5M
+
+	(Shell-B) Add task to cgroup and try to allocate and free memory
+	# echo $$ >/cgroup/A/tasks
+	# a="$(dd if=/dev/zero bs=1M count=10)"
+	# a=
+
+	You will see message from cgroup_event_listener every time you cross
+	the thresholds.
+
+	Use /cgroup/A/memory.memsw.usage_in_bytes to test memsw thresholds.
+
+	It's good idea to test root cgroup as well.
-- 
1.6.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
