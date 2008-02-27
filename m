Date: Wed, 27 Feb 2008 00:47:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH] page reclaim throttle take2
In-Reply-To: <47C51856.7060408@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.1.00.0802270045400.31372@chino.kir.corp.google.com>
References: <47C4EF2D.90508@linux.vnet.ibm.com> <alpine.DEB.1.00.0802262115270.1799@chino.kir.corp.google.com> <20080227143301.4252.KOSAKI.MOTOHIRO@jp.fujitsu.com> <alpine.DEB.1.00.0802262145410.31356@chino.kir.corp.google.com> <47C4F9C0.5010607@linux.vnet.ibm.com>
 <alpine.DEB.1.00.0802262201390.1613@chino.kir.corp.google.com> <47C51856.7060408@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2008, Balbir Singh wrote:

> Let's forget node hotplug for the moment, but what if someone
> 
> 1. Changes the machine configuration and adds more nodes, do we expect the
> kernel to be recompiled? Or is it easier to update /etc/sysctl.conf?
> 2. Uses fake NUMA nodes and increases/decreases the number of nodes across
> reboots. Should the kernel be recompiled?
> 

That is why the proposal was made to make this a static configuration 
option, such as CONFIG_NUM_RECLAIM_THREADS_PER_NODE, that will handle both 
situations.

> I am afraid it doesn't. Consider as you scale number of CPU's with the same
> amount of memory, we'll end up making the reclaim problem worse.
> 

The benchmark that have been posted suggest that memory locality is more 
important than lock contention, as I've already mentioned.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
