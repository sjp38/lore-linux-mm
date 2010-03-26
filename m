Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D41886B01AC
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 02:54:15 -0400 (EDT)
Received: from e35131.upc-e.chello.nl ([213.93.35.131] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Nv3Qq-0001gs-0z
	for linux-mm@kvack.org; Fri, 26 Mar 2010 06:54:12 +0000
Subject: Re: [rfc][patch] mm: lockdep page lock
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100326031814.GQ19308@shareable.org>
References: <20100315155859.GE2869@laptop>
	 <20100315180759.GA7744@quack.suse.cz> <20100316022153.GJ2869@laptop>
	 <1269437291.5109.238.camel@twins>  <20100326031814.GQ19308@shareable.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 26 Mar 2010 07:54:07 +0100
Message-ID: <1269586447.12097.118.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jamie Lokier <jamie@shareable.org>
Cc: Nick Piggin <npiggin@suse.de>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-03-26 at 03:18 +0000, Jamie Lokier wrote:
> Peter Zijlstra wrote:
> > On Tue, 2010-03-16 at 13:21 +1100, Nick Piggin wrote:
> > > 
> > > 
> > > Agreed (btw. Peter is there any way to turn lock debugging back on?
> > > it's annoying when cpufreq hotplug code or something early breaks and
> > > you have to reboot in order to do any testing).
> > 
> > Not really, the only way to do that is to get the full system back into
> > a known (zero) lock state and then fully reset the lockdep state.
> 
> How about: Set a variable nr_pending = number of CPUs, run a task on
> each CPU which disables interrupts, atomically decrements nr_pending
> and then spins waiting for it to become negative (raw, not counted in
> lockdep), and whichever one takes it to zero, that task knows there
> are no locks held, and can reset the lockdep state.  Then sets it to
> -1 to wake everyone.

Nope, won't work, you can easily preempt a lock holder.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
