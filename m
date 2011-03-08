Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7977E8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 22:20:00 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 164D13EE0B6
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 12:19:54 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B94F445DE54
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 12:19:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DDD945DE58
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 12:19:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F48D1DB804E
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 12:19:53 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5753E1DB8048
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 12:19:53 +0900 (JST)
Date: Tue, 8 Mar 2011 12:13:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20110308121332.de003f81.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1103071905400.1640@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1102091417410.5697@chino.kir.corp.google.com>
	<20110223150850.8b52f244.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1102231636260.21906@chino.kir.corp.google.com>
	<20110303135223.0a415e69.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103071602080.23035@chino.kir.corp.google.com>
	<20110307162912.2d8c70c1.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103071631080.23844@chino.kir.corp.google.com>
	<20110307165119.436f5d21.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103071657090.24549@chino.kir.corp.google.com>
	<20110307171853.c31ec416.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103071721330.25197@chino.kir.corp.google.com>
	<20110308115108.36b184c5.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103071905400.1640@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Mon, 7 Mar 2011 19:07:10 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 8 Mar 2011, KAMEZAWA Hiroyuki wrote:
> 
> > BTW, why "the memcg is livelocked and then no memory limits on the system have 
> > a chance of getting increased"
> > 
> 
> I was referring specifically to the memcg which a job scheduler or 
> userspace daemon responsible for doing so is attached.  If the thread 
> responsible for managing memcgs and increasing limits or killing off lower 
> priority jobs is in a memcg that is oom, there is a chance it will never 
> be able to respond to the condition.
> 

I just think memcg for such daemons shouldn't have any limit or must not
set oom_disable. I think you know that. So, the question is why you can't
do it ?  Is there special reason which comes from cgroup's characteristics ?


Thanks,
-kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
