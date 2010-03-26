Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 886F46B01AC
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 07:55:10 -0400 (EDT)
Date: Fri, 26 Mar 2010 11:54:57 +0000
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [rfc][patch] mm: lockdep page lock
Message-ID: <20100326115457.GB19308@shareable.org>
References: <20100315155859.GE2869@laptop> <20100315180759.GA7744@quack.suse.cz> <20100316022153.GJ2869@laptop> <1269437291.5109.238.camel@twins> <20100326031814.GQ19308@shareable.org> <1269586447.12097.118.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1269586447.12097.118.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nick Piggin <npiggin@suse.de>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Fri, 2010-03-26 at 03:18 +0000, Jamie Lokier wrote:
> > Peter Zijlstra wrote:
> > > On Tue, 2010-03-16 at 13:21 +1100, Nick Piggin wrote:
> > > > 
> > > > 
> > > > Agreed (btw. Peter is there any way to turn lock debugging back on?
> > > > it's annoying when cpufreq hotplug code or something early breaks and
> > > > you have to reboot in order to do any testing).
> > > 
> > > Not really, the only way to do that is to get the full system back into
> > > a known (zero) lock state and then fully reset the lockdep state.
> > 
> > How about: Set a variable nr_pending = number of CPUs, run a task on
> > each CPU which disables interrupts, atomically decrements nr_pending
> > and then spins waiting for it to become negative (raw, not counted in
> > lockdep), and whichever one takes it to zero, that task knows there
> > are no locks held, and can reset the lockdep state.  Then sets it to
> > -1 to wake everyone.
> 
> Nope, won't work, you can easily preempt a lock holder.

Doh, yes of course.

I promise to get some sleep before further appearances :-)

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
