Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C66906B01BA
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 05:26:25 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5U9QMgk015308
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 30 Jun 2010 18:26:22 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 35C8D45DE55
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1696745DE51
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 003271DB8038
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:22 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AB43B1DB803A
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:26:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 16/18] oom: badness heuristic rewrite
In-Reply-To: <alpine.DEB.2.00.1006211344240.31743@chino.kir.corp.google.com>
References: <20100621200549.B53C.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006211344240.31743@chino.kir.corp.google.com>
Message-Id: <20100630181153.AA45.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Wed, 30 Jun 2010 18:26:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon, 21 Jun 2010, KOSAKI Motohiro wrote:
> 
> > > It was in the changelog (recall that the badness() function represents a 
> > > proportion of available memory used by a task, so subtracting 30 is the 
> > > equivalent of 3% of available memory):
> > > 
> > > Root tasks are given 3% extra memory just like __vm_enough_memory()
> > > provides in LSMs.  In the event of two tasks consuming similar amounts of
> > > memory, it is generally better to save root's task.
> > 
> > LSMs have obvious reason to tend to priotize admin's operation than root
> > privilege daemon. otherwise admins can't restore troubles.
> > 
> > But in this case, why do need priotize admin shell than daemons?
> > 
> 
> For the same reason.  We want to slightly bias admin shells and their 
> processes from being oom killed because they are typically in the business 
> of administering the machine and resolving issues that may arise.  It 
> would be irresponsible to consider them to have the same killing 
> preference as user tasks in the case of a tie.

Not same. Administrator freely login again. typically killing login
process makes to kill some processes in the same session. thus now they
have much memory. rest very few case, they can press SysRq+F as a last 
resort.

In the other hand, system daemon crash can makes all of system crash.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
