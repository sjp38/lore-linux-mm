Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6A48D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 19:53:21 -0500 (EST)
Date: Mon, 7 Mar 2011 16:51:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20110307165119.436f5d21.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1103071631080.23844@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1102091417410.5697@chino.kir.corp.google.com>
	<20110223150850.8b52f244.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1102231636260.21906@chino.kir.corp.google.com>
	<20110303135223.0a415e69.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103071602080.23035@chino.kir.corp.google.com>
	<20110307162912.2d8c70c1.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103071631080.23844@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Mon, 7 Mar 2011 16:36:47 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Mon, 7 Mar 2011, Andrew Morton wrote:
> 
> > > So the question I'd ask is
> > 
> > What about my question?  Why is your usersapce oom-handler "unresponsive"?
> > 
> 
> If we have a per-memcg userspace oom handler, then it's absolutely 
> required that it either increase the hard limit of the oom memcg or kill a 
> task to free memory; anything else risks livelocking that memcg.  At 
> the same time, the oom handler's memcg isn't really important: it may be 
> in a different memcg but it may be oom at the same time.  If we risk 
> livelocking the memcg when it is oom and the oom killer cannot respond 
> (the only reason for the oom killer to exist in the first place), then 
> there's no guarantee that a userspace oom handler could respond under 
> livelock.

So you're saying that your userspace oom-handler is in a memcg which is
also oom?  That this is the only situation you've observed in which the
userspace oom-handler is "unresponsive"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
