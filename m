Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A85736B0012
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 00:03:43 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3S3qrEK009031
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 23:52:53 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3S43fLF077626
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 00:03:41 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3S03oAC032704
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 21:03:51 -0300
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 2/3] comm: timerstats: Protect task->comm access by using get_task_comm()
Date: Wed, 27 Apr 2011 21:03:30 -0700
Message-Id: <1303963411-2064-3-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1303963411-2064-1-git-send-email-john.stultz@linaro.org>
References: <1303963411-2064-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Converts the timerstats code to use get_task_comm for protected
comm access.

CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: David Rientjes <rientjes@google.com>
CC: Dave Hansen <dave@linux.vnet.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-mm@kvack.org
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 kernel/timer.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/timer.c b/kernel/timer.c
index fd61986..85308fb 100644
--- a/kernel/timer.c
+++ b/kernel/timer.c
@@ -379,7 +379,7 @@ void __timer_stats_timer_set_start_info(struct timer_list *timer, void *addr)
 		return;
 
 	timer->start_site = addr;
-	memcpy(timer->start_comm, current->comm, TASK_COMM_LEN);
+	get_task_comm(timer->start_comm, current);
 	timer->start_pid = current->pid;
 }
 
-- 
1.7.3.2.146.gca209

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
