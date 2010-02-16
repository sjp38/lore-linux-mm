Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4C8DB6B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 03:14:26 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1G8ENhJ027486
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Feb 2010 17:14:23 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BA6545DE4E
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 17:14:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F170F45DE4D
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 17:14:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B6AEA1DB803E
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 17:14:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CF1C1DB803F
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 17:14:22 +0900 (JST)
Date: Tue, 16 Feb 2010 17:10:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
Message-Id: <20100216171051.aebbffe5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100216080817.GK5723@laptop>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com>
	<20100216062035.GA5723@laptop>
	<alpine.DEB.2.00.1002152252310.2745@chino.kir.corp.google.com>
	<20100216072047.GH5723@laptop>
	<alpine.DEB.2.00.1002152342120.7470@chino.kir.corp.google.com>
	<20100216080817.GK5723@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010 19:08:17 +1100
Nick Piggin <npiggin@suse.de> wrote:

> On Mon, Feb 15, 2010 at 11:53:33PM -0800, David Rientjes wrote:
> > On Tue, 16 Feb 2010, Nick Piggin wrote:
> > 
> > > > Because it is inconsistent at the user's expense, it has never panicked 
> > > > the machine for memory controller ooms, so why is a cpuset or mempolicy 
> > > > constrained oom conditions any different?
> > > 
> > > Well memory controller was added later, wasn't it? So if you think
> > > that's a bug then a fix to panic on memory controller ooms might
> > > be in order.
> > > 
> > 
> > But what about the existing memcg users who set panic_on_oom == 2 and 
> > don't expect the memory controller to be influenced by that?
> 
> But that was a bug in the addition of the memory controller. Either the
> documentation should be fixed, or the implementation should be fixed.
> 
I'll add a documentation to memcg. As

"When you exhaust memory resource under memcg, oom-killer may be invoked.
 But in this case, the system never panics even when panic_on_oom is set."

Maybe I should add "memcg_oom_notify (netlink message or file-decriptor or some".
Because memcg's oom is virtual oom, automatic management software can show
report to users and can do fail-over. I'll consider something useful for
memcg oom-fail-over instead of panic. In the simplest case, cgroup's notiifer
file descriptor can be used.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
