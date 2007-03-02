Date: Thu, 1 Mar 2007 19:44:27 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
In-Reply-To: <45E7835A.8000908@in.ibm.com>
Message-ID: <Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org>
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org>
 <45E7835A.8000908@in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@in.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Fri, 2 Mar 2007, Balbir Singh wrote:
>
> > My personal opinion is that while I'm not a huge fan of virtualization,
> > these kinds of things really _can_ be handled more cleanly at that layer,
> > and not in the kernel at all. Afaik, it's what IBM already does, and has
> > been doing for a while. There's no shame in looking at what already works,
> > especially if it's simpler.
> 
> Could you please clarify as to what "that layer" means - is it the
> firmware/hardware for virtualization? or does it refer to user space?

Virtualization in general. We don't know what it is - in IBM machines it's 
a hypervisor. With Xen and VMware, it's usually a hypervisor too. With 
KVM, it's obviously a host Linux kernel/user-process combination.

The point being that in the guests, hotunplug is almost useless (for 
bigger ranges), and we're much better off just telling the virtualization 
hosts on a per-page level whether we care about a page or not, than to 
worry about fragmentation.

And in hosts, we usually don't care EITHER, since it's usually done in a 
hypervisor.

> It would also be useful to have a resource controller like per-container
> RSS control (container refers to a task grouping) within the kernel or
> non-virtualized environments as well.

.. but this has again no impact on anti-fragmentation.

In other words, I really don't see a huge upside. I see *lots* of 
downsides, but upsides? Not so much. Almost everybody who wants unplug 
wants virtualization, and right now none of the "big virtualization" 
people would want to have kernel-level anti-fragmentation anyway sicne 
they'd need to do it on their own.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
