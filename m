Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2E7DF6B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 19:25:50 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o230PlBu011931
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Mar 2010 09:25:47 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F11A45DE52
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:25:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FB8945DE51
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:25:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 170001DB803C
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:25:47 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CB67EE38003
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:25:42 +0900 (JST)
Date: Wed, 3 Mar 2010 09:22:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
Message-Id: <20100303092210.a730a903.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003021600020.11946@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com>
	<20100301052306.GG19665@balbir.in.ibm.com>
	<alpine.DEB.2.00.1003010159420.26824@chino.kir.corp.google.com>
	<20100302085532.ff9d3cf4.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003021600020.11946@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Mar 2010 16:01:41 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 2 Mar 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > Kame said earlier it would be no problem to rebase his memcg oom work on 
> > > mmotm if my patches were merged.
> > > 
> > 
> > But I also said this patch cause regression.
> 
> This patch causes a regression???  You never said that in any of your 
> reviews and I have no idea what you're talking about, this patch simply 
> cleans up the code and closes a race where VM_FAULT_OOM could needlessly 
> kill tasks in parallel oom conditions.
> 
try_set_system_oom() is not called in memory_cgroup_out_of_memory() path.
Then, oom kill twice.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
