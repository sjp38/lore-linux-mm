Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5Q9SLNd008513
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 05:28:21 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5Q9SKFt169866
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 03:28:20 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5Q9SKZc020896
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 03:28:20 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 26 Jun 2008 14:58:15 +0530
Message-Id: <20080626092815.16841.54817.sendpatchset@balbir-laptop>
Subject: [0/5] memrlimit fixes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, Andrew,

These are fixes for the memrlimit cgroup controller. Patch 1, improve
error handling has been redone. Detailed changelog can be found in every
patch. I've tested the patches by running kernbench in a memrlimit
controlled cgroup.

series
------
memrlimit-cgroup-add-better-error-handling
memrlimit-cgroup-fix-attach-task
memrlimit-fix-sleep-in-spinlock-bug
memrlimit-improve-fork-error-handling
memrlimit-fix-move-vma-accounting

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
