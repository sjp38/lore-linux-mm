Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7182E6B01C6
	for <linux-mm@kvack.org>; Sun,  6 Jun 2010 18:34:40 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o56MYcCN022556
	for <linux-mm@kvack.org>; Sun, 6 Jun 2010 15:34:38 -0700
Received: from pwj3 (pwj3.prod.google.com [10.241.219.67])
	by wpaz21.hot.corp.google.com with ESMTP id o56MYbbw031368
	for <linux-mm@kvack.org>; Sun, 6 Jun 2010 15:34:38 -0700
Received: by pwj3 with SMTP id 3so2483978pwj.18
        for <linux-mm@kvack.org>; Sun, 06 Jun 2010 15:34:37 -0700 (PDT)
Date: Sun, 6 Jun 2010 15:34:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 10/18] oom: enable oom tasklist dump by default
In-Reply-To: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006061525150.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The oom killer tasklist dump, enabled with the oom_dump_tasks sysctl, is
very helpful information in diagnosing why a user's task has been killed.
It emits useful information such as each eligible thread's memory usage
that can determine why the system is oom, so it should be enabled by
default.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
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
index ef048c1..833de48 100644
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
