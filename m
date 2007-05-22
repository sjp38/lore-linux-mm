Received: from attica.americas.sgi.com (attica.americas.sgi.com [128.162.236.44])
	by netops-testserver-3.corp.sgi.com (Postfix) with ESMTP id 8D7DA908AC
	for <linux-mm@kvack.org>; Tue, 22 May 2007 13:53:00 -0700 (PDT)
Date: Tue, 22 May 2007 15:53:00 -0500
Subject: hotplug cpu: PATCHes for 3 issues
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20070522205300.58C7537188E@attica.americas.sgi.com>
From: cpw@sgi.com (Cliff Wickman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


In the 2.6.21 kernel there are still 3 hotplug issues that are cpuset-
related, and that I find to still be problems.   And for which I offer
patches.

These have been submitted before, and subsequently cleaned up per
comments received.

Submitted to LKML yesterday, but no feedback from that forum - should
have been to linux-mm@kvack.org 
I'm resubmitting all 3 for consideration and further comment.

1)  [PATCH 1/1] hotplug cpu: cpusets/sched_domain reconciliation
2)  [PATCH 1/1] hotplug cpu: move tasks in empty cpusets to parent
3)  [PATCH 1/1] hotplug cpu: migrate a task within its cpuset

1) Reconciles cpusets and sched_domains that get out of sync
   due to hotplug disabling and re-enabling of cpu's.
   Tasks can get into infinite hangs without this fix.
     kernel/cpuset.c
     kernel/sched.c 
[should have noted that this depends on 2) for correctnes]

2) When a cpuset is emptied by disabling its cpus, move tasks to 
   a parent cpuset.
   This is a correction of the current procedure, which moves such
   tasks to the wrong cpuset.
     kernel/cpuset.c

3) Causes a task running on a disabled cpu to migrate to a cpu within
   its cpuset.
   This behavior is particularly important for a NUMA system on which
   tasks have been explicitly placed.
     kernel/sched.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
