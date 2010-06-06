Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 52D256B0071
	for <linux-mm@kvack.org>; Sun,  6 Jun 2010 18:34:05 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o56MY1RG008890
	for <linux-mm@kvack.org>; Sun, 6 Jun 2010 15:34:02 -0700
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by wpaz29.hot.corp.google.com with ESMTP id o56MXxFY028846
	for <linux-mm@kvack.org>; Sun, 6 Jun 2010 15:34:00 -0700
Received: by pwj8 with SMTP id 8so1813230pwj.26
        for <linux-mm@kvack.org>; Sun, 06 Jun 2010 15:33:59 -0700 (PDT)
Date: Sun, 6 Jun 2010 15:33:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 00/18] oom killer rewrite
Message-ID: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is the latest update of the oom killer rewrite based on
mmotm-2010-06-03-16-36, although it applies cleanly to 2.6.35-rc2 as
well.

There are two changes in this update, which I hope to now be considered
for -mm inclusion and pushed for 2.6.36:

 - reordered the patches to more accurately seperate fixes from
   enhancements: the order is now very close to how KAMEZAWA Hiroyuki
   suggested (thanks!), and

 - the changelog for "oom: badness heuristic rewrite" was slightly
   expanded to mention how this rewrite improves the oom killer's
   behavior on the desktop.

Many thanks to Nick Piggin <npiggin@suse.de> for converting the remaining
architectures that weren't using the oom killer to handle pagefault oom
conditions to do so.  His patches have hit mainline, so there is no
longer an inconsistency in the semantics of panic_on_oom in such cases!

Many thanks to KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> for his
help and patience in working with me on this patchset.
---
 Documentation/feature-removal-schedule.txt |   25 +
 Documentation/filesystems/proc.txt         |  100 ++--
 Documentation/sysctl/vm.txt                |   23 
 fs/proc/base.c                             |  107 ++++
 include/linux/memcontrol.h                 |    8 
 include/linux/mempolicy.h                  |   13 
 include/linux/oom.h                        |   27 +
 include/linux/sched.h                      |    3 
 kernel/fork.c                              |    1 
 kernel/sysctl.c                            |   12 
 mm/memcontrol.c                            |   18 
 mm/mempolicy.c                             |   44 +
 mm/oom_kill.c                              |  675 ++++++++++++++++-------------
 mm/page_alloc.c                            |   29 -
 14 files changed, 727 insertions(+), 358 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
