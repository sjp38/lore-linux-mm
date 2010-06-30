Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5C0066B01AC
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 05:26:03 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5U9Pxuh006468
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 30 Jun 2010 18:26:00 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A809D45DE6F
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:25:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 83A2345DE60
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:25:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 610181DB803A
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:25:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 192E91DB803F
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:25:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm 0611][PATCH 00/11] various OOM bugfixes v3
Message-Id: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 30 Jun 2010 18:25:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi

Here is updated series for various OOM fixes.
Almost fixes are trivial. 

One big improvement is Luis's dying task priority boost patch.
This is necessary for RT folks.


  oom: don't try to kill oom_unkillable child
  oom: oom_kill_process() doesn't select kthread child
  oom: make oom_unkillable_task() helper function
  oom: oom_kill_process() need to check p is unkillable
  oom: /proc/<pid>/oom_score treat kernel thread honestly
  oom: kill duplicate OOM_DISABLE check
  oom: move OOM_DISABLE check from oom_kill_task to out_of_memory()
  oom: cleanup has_intersects_mems_allowed()
  oom: remove child->mm check from oom_kill_process()
  oom: give the dying task a higher priority
  oom: multi threaded process coredump don't make deadlock

 fs/proc/base.c |    5 ++-
 mm/oom_kill.c  |  100 +++++++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 73 insertions(+), 32 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
