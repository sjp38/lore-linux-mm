Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 97F826B0044
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 15:51:32 -0500 (EST)
Date: Wed, 07 Jan 2009 12:51:33 -0800 (PST)
Message-Id: <20090107.125133.214628094.davem@davemloft.net>
Subject: Re: Increase dirty_ratio and dirty_background_ratio?
From: David Miller <davem@davemloft.net>
In-Reply-To: <alpine.LFD.2.00.0901070833430.3057@localhost.localdomain>
References: <20090107154517.GA5565@duck.suse.cz>
	<1231345546.11687.314.camel@twins>
	<alpine.LFD.2.00.0901070833430.3057@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: torvalds@linux-foundation.org
Cc: peterz@infradead.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 7 Jan 2009 08:39:01 -0800 (PST)

> On Wed, 7 Jan 2009, Peter Zijlstra wrote:
> > 
> > >   So the question is: What kind of workloads are lower limits supposed to
> > > help? Desktop? Has anybody reported that they actually help? I'm asking
> > > because we are probably going to increase limits to the old values for
> > > SLES11 if we don't see serious negative impact on other workloads...
> > 
> > Adding some CCs.
> > 
> > The idea was that 40% of the memory is a _lot_ these days, and writeback
> > times will be huge for those hitting sync or similar. By lowering these
> > you'd smooth that out a bit.
> 
> Not just a bit. If you have 4GB of RAM (not at all unusual for even just a 
> regular desktop, never mind a "real" workstation), it's simply crazy to 
> allow 1.5GB of dirty memory. Not unless you have a really wicked RAID 
> system with great write performance that can push it out to disk (with 
> seeking) in just a few seconds.
> 
> And few people have that.
> 
> For a server, where throughput matters but latency generally does not, go 
> ahead and raise it. But please don't raise it for anything sane. The only 
> time it makes sense upping that percentage is for some odd special-case 
> benchmark that otherwise can fit the dirty data set in memory, and never 
> syncs it (ie it deletes all the files after generating them).
> 
> In other words, yes, 40% dirty can make a big difference to benchmarks, 
> but is almost never actually a good idea any more.

I have to say that my workstation is still helped by reverting this
change and all I do is play around in GIT trees and read email.

It's a slow UltraSPARC-IIIi 1.5GHz machine with a very slow IDE disk
and 2GB of ram.

With the dirty ratio changeset there, I'm waiting for disk I/O
seemingly all the time.  Without it, I only feel the machine seize up
in disk I/O when I really punish it.

Maybe all the dirty I/O is from my not using 'noatime', and if that's
how I should "fix" this then we can ask why isn't it the default? :)

I did mention this when the original changeset went into the tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
