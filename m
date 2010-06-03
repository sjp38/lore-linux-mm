Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 63B836B01AC
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 01:48:42 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o535mdZ1012061
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 3 Jun 2010 14:48:39 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D16F45DE50
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:48:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D0B345DE4F
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:48:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E17491DB8018
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:48:38 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 95C5D1DB8013
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:48:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm 0521][PATCH 0/12] various OOM fixes for 2.6.35
Message-Id: <20100603135106.7247.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Jun 2010 14:48:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi

This patch series is collection of various OOM bugfixes. I think
all of patches can send to 2.6.35.
Recently, David Rientjes and Luis Claudio R. Goncalves posted other
various imporovement. I'll collect such 2.6.36 items and I plan to 
push -mm at next week.

patch lists
-------------------------------------
oom: select_bad_process: check PF_KTHREAD instead of !mm to skip kthreads
oom: introduce find_lock_task_mm() to fix !mm false positives
oom: the points calculation of child processes must use find_lock_task_mm() too
oom: __oom_kill_task() must use find_lock_task_mm() too
oom: make oom_unkillable() helper function
oom: remove warning for in mm-less task __oom_kill_process()
oom: Fix child process iteration properly
oom: dump_tasks() use find_lock_task_mm() too
oom: remove PF_EXITING check completely
oom: sacrifice child with highest badness score for parent
oom: remove special handling for pagefault ooms
oom: give current access to memory reserves if it has been killed

diffstat
------------
 mm/oom_kill.c |  303 ++++++++++++++++++++++++++++++--------------------------
 1 files changed, 162 insertions(+), 141 deletions(-)



Changes since last post
-------------------------
  - Drop Luis's "give the dying task a higher priority" patch
  - Add "remove PF_EXITING check completely" patch
  - Drop Oleg's "oom: select_bad_process: PF_EXITING check should 
    take ->mm into account" because conflict against "remove 
    PF_EXITING check completely"
  - Add "oom: sacrifice child with highest badness score for parent"
  - Add "oom: remove special handling for pagefault ooms"
  - Add "oom: give current access to memory reserves if it has been killed"




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
