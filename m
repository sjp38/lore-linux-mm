Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DAD826B01AC
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 05:26:22 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5U9QKHH006832
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 30 Jun 2010 18:26:20 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 79D9145DE4F
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:20 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F35445DE4C
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:20 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 49BCB1DB8014
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:20 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 053D21DB8012
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/9] oom: oom_kill_process() need to check p is unkillable
In-Reply-To: <alpine.DEB.2.00.1006211301110.8367@chino.kir.corp.google.com>
References: <20100617135224.FBAA.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006211301110.8367@chino.kir.corp.google.com>
Message-Id: <20100624211415.802E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Wed, 30 Jun 2010 18:26:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Mon, 21 Jun 2010, KOSAKI Motohiro wrote:
> 
> > > > When oom_kill_allocating_task is enabled, an argument task of
> > > > oom_kill_process is not selected by select_bad_process(), It's
> > > > just out_of_memory() caller task. It mean the task can be
> > > > unkillable. check it first.
> > > > 
> > > 
> > > This should be unnecessary if oom_kill_process() appropriately returns 
> > > non-zero when it cannot kill a task.  What problem are you addressing with 
> > > this fix?
> > 
> > oom_kill_process() only check its children are unkillable, not its own.
> 
> No, oom_kill_process() returns the value of oom_kill_task(victim) which is 
> non-zero for !victim->mm in mmotm-2010-06-11-16-40 (and 2.6.34 although 
> victim == p in that case).

oom_kill_task() only check OOM_DISABLE. and Minchan elaborated more detailed
concern. please see his mail.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
