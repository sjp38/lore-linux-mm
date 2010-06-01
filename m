Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9A06B01CD
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:18:46 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id o517IiFJ022581
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:18:45 -0700
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by hpaq5.eem.corp.google.com with ESMTP id o517Ig3g025706
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:18:43 -0700
Received: by pxi7 with SMTP id 7so2303628pxi.13
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 00:18:42 -0700 (PDT)
Date: Tue, 1 Jun 2010 00:18:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 07/18] oom: enable oom tasklist dump by default
In-Reply-To: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006010014390.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The oom killer tasklist dump, enabled with the oom_dump_tasks sysctl, is
very helpful information in diagnosing why a user's task has been killed.
It emits useful information such as each eligible thread's memory usage
that can determine why the system is oom, so it should be enabled by
default.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/sysctl/vm.txt |    2 +-
 mm/oom_kill.c               |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -511,7 +511,7 @@ information may not be desired.
 If this is set to non-zero, this information is shown whenever the
 OOM killer actually kills a memory-hogging task.
 
-The default value is 0.
+The default value is 1 (enabled).
 
 ==============================================================
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -32,7 +32,7 @@
 
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
-int sysctl_oom_dump_tasks;
+int sysctl_oom_dump_tasks = 1;
 static DEFINE_SPINLOCK(zone_scan_lock);
 /* #define DEBUG */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
