Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 80A396B01AC
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 07:45:51 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5LBjnKR003977
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 21 Jun 2010 20:45:49 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DC4A45DE61
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:49 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EDF1745DD76
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CBDFD1DB8040
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:48 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 781E71DB803C
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 18/18] oom: deprecate oom_adj tunable
In-Reply-To: <alpine.DEB.2.00.1006162034330.21446@chino.kir.corp.google.com>
References: <20100613201922.619C.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006162034330.21446@chino.kir.corp.google.com>
Message-Id: <20100621194943.B536.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Mon, 21 Jun 2010 20:45:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Sun, 13 Jun 2010, KOSAKI Motohiro wrote:
> 
> > But oom_score_adj have no benefit form end-uses view. That's problem.
> > Please consider to make end-user friendly good patch at first.
> > 
> 
> Of course it does, it actually has units whereas oom_adj only grows or 
> shrinks the badness score exponentially.  oom_score_adj's units are well 
> understood: on a machine with 4G of memory, 250 means we're trying to 
> prejudice it by 1G of memory so that can be used by other tasks, -250 
> means other tasks should be prejudiced by 1G in comparison to this task, 
> etc.  It's actually quite powerful.

And, no real user want such power.

When we consider desktop user case, End-users don't use oom_adj by themself.
their application are using it.  It mean now oom_adj behave as syscall like
system interface, unlike kernel knob. application developers also don't 
need oom_score_adj because application developers don't know end-users 
machine mem size.

Then, you will get the change's merit but end users will get the demerit.
That's out of balance.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
