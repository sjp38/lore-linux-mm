Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 192736B01B2
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 07:45:52 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5LBjoiO024559
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 21 Jun 2010 20:45:50 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EA2045DE4E
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:50 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 09DD545DD71
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:50 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DA7651DB8017
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:49 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 99DEC1DB8013
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/9] oom: oom_kill_process() need to check p is unkillable
In-Reply-To: <alpine.DEB.2.00.1006162118520.14101@chino.kir.corp.google.com>
References: <20100617104647.FB89.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006162118520.14101@chino.kir.corp.google.com>
Message-Id: <20100617135224.FBAA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Mon, 21 Jun 2010 20:45:45 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Thu, 17 Jun 2010, KOSAKI Motohiro wrote:
> 
> > When oom_kill_allocating_task is enabled, an argument task of
> > oom_kill_process is not selected by select_bad_process(), It's
> > just out_of_memory() caller task. It mean the task can be
> > unkillable. check it first.
> > 
> 
> This should be unnecessary if oom_kill_process() appropriately returns 
> non-zero when it cannot kill a task.  What problem are you addressing with 
> this fix?

oom_kill_process() only check its children are unkillable, not its own.
To add check oom_kill_process() also solve the issue. as my previous patch does.
but Minchan pointed out it's unnecessary. because when !oom_kill_allocating_task
case, we have the same check in select_bad_process(). 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
