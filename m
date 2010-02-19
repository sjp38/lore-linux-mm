Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DB1CD6B007B
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 17:28:39 -0500 (EST)
Received: by fxm22 with SMTP id 22so684353fxm.6
        for <linux-mm@kvack.org>; Fri, 19 Feb 2010 14:28:37 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH -mmotm 4/4] memcg: Update memcg_test.txt to describe memory thresholds
Date: Sat, 20 Feb 2010 00:28:19 +0200
Message-Id: <fe8b000f9eb2cd469f21d92dcd87a6b3feb5efd7.1266618391.git.kirill@shutemov.name>
In-Reply-To: <6afbe14e8bb2480d88377c14cb15d96edd2d18f6.1266618391.git.kirill@shutemov.name>
References: <05f582d6cdc85fbb96bfadc344572924c0776730.1266618391.git.kirill@shutemov.name>
 <a2717b1f5e0b49db7b6ecd1a5a41e65c1dc6b50a.1266618391.git.kirill@shutemov.name>
 <6afbe14e8bb2480d88377c14cb15d96edd2d18f6.1266618391.git.kirill@shutemov.name>
In-Reply-To: <6afbe14e8bb2480d88377c14cb15d96edd2d18f6.1266618391.git.kirill@shutemov.name>
References: <05f582d6cdc85fbb96bfadc344572924c0776730.1266618391.git.kirill@shutemov.name> <a2717b1f5e0b49db7b6ecd1a5a41e65c1dc6b50a.1266618391.git.kirill@shutemov.name> <6afbe14e8bb2480d88377c14cb15d96edd2d18f6.1266618391.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
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
