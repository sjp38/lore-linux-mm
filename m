Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C4CCC6B01B7
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:18:19 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o517IGii024703
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:18:17 -0700
Received: from pwj1 (pwj1.prod.google.com [10.241.219.65])
	by wpaz9.hot.corp.google.com with ESMTP id o517IErY012499
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:18:15 -0700
Received: by pwj1 with SMTP id 1so441364pwj.27
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 00:18:13 -0700 (PDT)
Date: Tue, 1 Jun 2010 00:18:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 00/18] oom killer rewrite
Message-ID: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is yet another version of my oom killer rewrite, now rebased to 
mmotm-2010-05-21-16-05.

This version removes the consolidation of the two existing sysctls, 
oom_kill_allocating_task and oom_dump_tasks, as recommended by a couple 
different people.

This version also makes pagefault oom handling consistent with 
panic_on_oom behavior now that all architectures have been converted to 
using the oom killer instead of simply issuing a SIGKILL for current.  
Many thanks to Nick Piggin for converting the existing archs.
---
 Documentation/feature-removal-schedule.txt |   25 +
 Documentation/filesystems/proc.txt         |  100 +++-
 Documentation/sysctl/vm.txt                |   23 +
 fs/proc/base.c                             |  107 ++++-
 include/linux/memcontrol.h                 |    8 
 include/linux/mempolicy.h                  |   13 
 include/linux/oom.h                        |   26 +
 include/linux/sched.h                      |    3 
 kernel/fork.c                              |    1 
 kernel/sysctl.c                            |   12 
 mm/memcontrol.c                            |   18 
 mm/mempolicy.c                             |   44 ++
 mm/oom_kill.c                              |  603 +++++++++++++++--------------
 mm/page_alloc.c                            |   29 -
 14 files changed, 680 insertions(+), 332 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
