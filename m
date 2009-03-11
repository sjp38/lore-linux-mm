Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2676F6B004D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 14:48:04 -0400 (EDT)
Date: Wed, 11 Mar 2009 14:48:02 -0400 (EDT)
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
In-Reply-To: <20090311193358.194cf3fb@mjolnir.ossman.eu>
Message-ID: <alpine.DEB.2.00.0903111441190.3062@gandalf.stny.rr.com>
References: <20090310024135.GA6832@localhost> <20090310081917.GA28968@localhost> <20090310105523.3dfd4873@mjolnir.ossman.eu> <20090310122210.GA8415@localhost> <20090310131155.GA9654@localhost> <20090310212118.7bf17af6@mjolnir.ossman.eu> <20090311013739.GA7078@localhost>
 <20090311075703.35de2488@mjolnir.ossman.eu> <20090311071445.GA13584@localhost> <20090311082658.06ff605a@mjolnir.ossman.eu> <20090311073619.GA26691@localhost> <alpine.DEB.2.00.0903111022480.16494@gandalf.stny.rr.com> <20090311175556.2a127801@mjolnir.ossman.eu>
 <alpine.DEB.2.00.0903111325560.3062@gandalf.stny.rr.com> <20090311193358.194cf3fb@mjolnir.ossman.eu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>


On Wed, 11 Mar 2009, Pierre Ossman wrote:

> On Wed, 11 Mar 2009 13:28:31 -0400 (EDT)
> Steven Rostedt <rostedt@goodmis.org> wrote:
> 
> > 
> > On Wed, 11 Mar 2009, Pierre Ossman wrote:
> > 
> > > 
> > > Is this per actual CPU though? Or per CONFIG_NR_CPUS? 3 MB times 64
> > > equals roughly the lost memory. But then again, you said it was 10 MB
> > > per CPU for 2.6.27...
> > 
> > It uses the possible_cpu mask. How many possible CPUs are on your box? 
> > I've thought about making this handle hot plug CPUs, but that will
> > require a little more overhead for everyone, whether or not you hot plug a 
> > cpu.
> > 
> 
> CONFIG_NR_CPUS is 64 for these compiles.

Hmm, I assumed (but could be wrong) that on boot up, the system checked 
how many CPUs were physically possible, and updated the possible CPU 
mask accordingly (default being NR_CPUS).

If this is not the case, then I'll have to implement hot plug allocation. 
:-/

Thanks,

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
