Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DACCD6B01B5
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 07:45:53 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5LBjpjS024563
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 21 Jun 2010 20:45:51 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B69AB45DE51
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FDEB45DD76
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A29251DB803F
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:49 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 543041DB803B
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 16/18] oom: badness heuristic rewrite
In-Reply-To: <alpine.DEB.2.00.1006162213130.19549@chino.kir.corp.google.com>
References: <20100608160216.bc52112b.akpm@linux-foundation.org> <alpine.DEB.2.00.1006162213130.19549@chino.kir.corp.google.com>
Message-Id: <20100621200549.B53C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Mon, 21 Jun 2010 20:45:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > This change was unchangelogged, I don't know what it's for and I don't
> > understand your comment about it.
> > 
> 
> It was in the changelog (recall that the badness() function represents a 
> proportion of available memory used by a task, so subtracting 30 is the 
> equivalent of 3% of available memory):
> 
> Root tasks are given 3% extra memory just like __vm_enough_memory()
> provides in LSMs.  In the event of two tasks consuming similar amounts of
> memory, it is generally better to save root's task.

LSMs have obvious reason to tend to priotize admin's operation than root
privilege daemon. otherwise admins can't restore troubles.

But in this case, why do need priotize admin shell than daemons?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
