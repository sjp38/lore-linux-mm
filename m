Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4BE698D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 00:55:34 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 06AED3EE0C2
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 14:55:28 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E159B45DE4E
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 14:55:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C9B1C45DE4F
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 14:55:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BBBD71DB8040
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 14:55:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8458C1DB8037
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 14:55:27 +0900 (JST)
Date: Tue, 8 Mar 2011 14:49:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20110308144901.fe34abd0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1103072126590.4593@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com>
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
	<20110308121332.de003f81.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103071954550.2883@chino.kir.corp.google.com>
	<20110308131723.e434cb89.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103072126590.4593@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Mon, 7 Mar 2011 21:30:19 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 8 Mar 2011, KAMEZAWA Hiroyuki wrote:
> 
> > Hmm? That's an unexpected answer. Why system's capacity is problem here ?
> > (root memcg has no 'limit' always.)
> > 
> > Is it a problem that 'there is no 'guarantee' or 'private page pool'
> > for daemons ?
> > 
> 
> It's not an inherent problem of memcg, it's a configuration issue: if your 
> userspace application cannot respond to address an oom condition in a 
> memcg for whatever reason (such as it being in an oom memcg itself), then 
> there's a chance that the memcg will livelock since the kernel cannot do 
> anything to fix the issue itself.
> 
> That's aside from the general purpose of the new 
> memory.oom_delay_millisecs: users may want a grace period for userspace to 
> increase the hard limit or kill a task before deferring to the kernel.  
> That seems exponentially more useful than simply disabling the oom killer 
> entirely with memory.oom_control.  I think it's unfortunate 
> memory.oom_control was merged frst and seems to have tainted this entire 
> discussion.
> 

That sounds like a mis-usage problem....what kind of workaround is offerred
if the user doesn't configure oom_delay_millisecs , a yet another mis-usage ?

THanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
