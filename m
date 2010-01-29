Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8F7006B0047
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 06:02:16 -0500 (EST)
Date: Fri, 29 Jan 2010 11:03:21 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
Message-ID: <20100129110321.564cb866@lxorguk.ukuu.org.uk>
In-Reply-To: <4B62327F.3010208@gmail.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126151202.75bd9347.akpm@linux-foundation.org>
	<20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126161952.ee267d1c.akpm@linux-foundation.org>
	<20100127095812.d7493a8f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100128001636.2026a6bc@lxorguk.ukuu.org.uk>
	<4B622AEE.3080906@gmail.com>
	<20100129003547.521a1da9@lxorguk.ukuu.org.uk>
	<4B62327F.3010208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: vedran.furac@gmail.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> off by default. Problem is that it breaks java and some other stuff that
> allocates much more memory than it needs. Very quickly Committed_AS hits
> CommitLimit and one cannot allocate any more while there is plenty of
> memory still unused.

So how about you go and have a complain at the people who are causing
your problem, rather than the kernel.

> > theoretical limit, but you generally need more swap (it's one of the
> > reasons why things like BSD historically have a '3 * memory' rule).
> 
> Say I have 8GB of memory and there's always some free, why would I need
> swap?

So that all the applications that allocate tons of address space and
don't use it can swap when you hit that corner case, and as a result you
don't need to go OOM. You should only get an OOM when you run out of
memory + swap.

> > So sounds to me like a problem between the keyboard and screen (coupled
> 
> Unfortunately it is not. Give me ssh access to your computer (leave
> overcommit on) and I'll kill your X with anything running on it.

If you have overcommit on then you can cause stuff to get killed. Thats
what the option enables.

It's really very simple: overcommit off you must have enough RAM and swap
to hold all allocations requested. Overcommit on - you don't need this
but if you do use more than is available on the system something has to
go.

It's kind of like banking  overcommit off is proper banking, overcommit
on is modern western banking.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
