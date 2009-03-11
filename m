Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A4AC56B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 15:03:45 -0400 (EDT)
Date: Wed, 11 Mar 2009 15:03:38 -0400 (EDT)
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
In-Reply-To: <20090311195601.47fe7798@mjolnir.ossman.eu>
Message-ID: <alpine.DEB.2.00.0903111501070.3062@gandalf.stny.rr.com>
References: <20090310024135.GA6832@localhost> <20090310081917.GA28968@localhost> <20090310105523.3dfd4873@mjolnir.ossman.eu> <20090310122210.GA8415@localhost> <20090310131155.GA9654@localhost> <20090310212118.7bf17af6@mjolnir.ossman.eu> <20090311013739.GA7078@localhost>
 <20090311075703.35de2488@mjolnir.ossman.eu> <20090311071445.GA13584@localhost> <20090311082658.06ff605a@mjolnir.ossman.eu> <20090311073619.GA26691@localhost> <alpine.DEB.2.00.0903111022480.16494@gandalf.stny.rr.com> <20090311175556.2a127801@mjolnir.ossman.eu>
 <alpine.DEB.2.00.0903111325560.3062@gandalf.stny.rr.com> <20090311193358.194cf3fb@mjolnir.ossman.eu> <alpine.DEB.2.00.0903111441190.3062@gandalf.stny.rr.com> <20090311195601.47fe7798@mjolnir.ossman.eu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>


On Wed, 11 Mar 2009, Pierre Ossman wrote:

> On Wed, 11 Mar 2009 14:48:02 -0400 (EDT)
> Steven Rostedt <rostedt@goodmis.org> wrote:
> 
> > 
> > Hmm, I assumed (but could be wrong) that on boot up, the system checked 
> > how many CPUs were physically possible, and updated the possible CPU 
> > mask accordingly (default being NR_CPUS).
> > 
> > If this is not the case, then I'll have to implement hot plug allocation. 
> > :-/
> > 
> 
> I have no idea, but every system doesn't suffer from this problem so
> there is something more to this. Modern fedora kernels have NR_CPUS set
> to 512, and it's not like I'm missing 1.5 GB here. :)
> 

I'm thinking it is a system dependent feature. I'm working on implementing 
the ring buffers to only allocate for online CPUS. I just realized that 
there's a check of a ring buffer cpu mask to see if it is OK to write to 
that CPU buffer. This works out perfectly, to keep non allocated buffers 
from being written to.

Thanks,

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
