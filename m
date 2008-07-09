Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m69NZj6Y011575
	for <linux-mm@kvack.org>; Wed, 9 Jul 2008 19:35:45 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m69NZjM5234494
	for <linux-mm@kvack.org>; Wed, 9 Jul 2008 19:35:45 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m69NZj32012381
	for <linux-mm@kvack.org>; Wed, 9 Jul 2008 19:35:45 -0400
Subject: Re: Failing memory auto-hotremove support?
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20080704121745.21FE.E1E9C6FF@jp.fujitsu.com>
References: <486CC533.6080302@buttersideup.com>
	 <90872.19606.qm@web50110.mail.re2.yahoo.com>
	 <20080704121745.21FE.E1E9C6FF@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 09 Jul 2008 16:34:48 -0700
Message-Id: <1215646488.817.22.camel@badari-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Doug Thompson <norsk5@yahoo.com>, Tim Small <tim@buttersideup.com>, bluesmoke-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-07-04 at 14:24 +0900, Yasunori Goto wrote:
> Hi.
> 
> > > I just noticed that there is memory hotplug / hotremove support in the 
> > > kernel.org kernel now.
> > 
> > cool, good to hear. Now I (or others) need some cycles to review it and mod EDAC to utilize it if
> > possible and/or provide feedback to the memory guys
> 
> There is a documentation about memory hotplug. I hope it will help you.
> (Documentation/memory-hotplug.txt)
> 
> 
> > > I was thinking that it may be desirable (e.g. on large NUMA systems) to 
> > > automatically trigger the removal of memory modules (or just take a 
> > > section of the memory module out of use, if applicable), if a memory 
> > > module exceeded a pre-set correctable error rate (or RIGHT-NOW, if an 
> > > uncorrectable memory error was detected).
> > 
> > THAT is exactly what one of the goals of EDAC (then bluesmoke) had in mind years ago, but there
> > was no easy mechanism, within the kernel, to perform those types of controls (take a section of
> > memory out of commision).
> 
> At least, each memory section can be offlined "logically".
> So, if there is a (correctable) error in a section, the section will be not used
> after the section's offline. 
> There is no code for automatic offline yet. But I think it is not difficult.
> 
> 
> Physical (in other words, electrical) removing needs more works (except powerpc box.)
> In x86-64/ia64, the memory device (or container device)of ACPI must be support
> _EJD method, and physical removing code must be called. But I think its code is
> not completed yet.
> 
> 
> > When you have a NUMA node with 64 or 128 gigbabytes of memory and have 5,000 such nodes, rebooting
> > in not a very good thing to do. 
> > BUT being able to detect a bad DIMM (or a pair) via EDAC and then notify the memory subsystem to
> > de-activate that DIMM (pair) from active use is GREAT feature to have. The node graciously handles
> > the downed memory and stays UP running that big cluster task, all the while notifying the admin
> > that a DIMM needs replacement at the next maintaince cycle.
> 
> 
> Unfortunately, NUMA nodes can't be removed yet.
> The pgdat and other structures for each nodes can't be removed yet.
> 
> I'm planning how to remove them now, and will make it possible step by step.
> Please wait.

While we are trying to test hot remove nodes, we ran into this. There
are allocations on the first memblock on each node, preventing it from
removing the node.

If you have ideas/code to move these allocations out of the way - I 
will be more than happy to test/verify/help :)

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
