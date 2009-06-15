Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DF2EA6B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 03:04:13 -0400 (EDT)
Date: Mon, 15 Jun 2009 09:04:14 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 1/5] HWPOISON: define VM_FAULT_HWPOISON to 0 when	feature is disabled
Message-ID: <20090615070414.GD18390@wotan.suse.de>
References: <20090611142239.192891591@intel.com> <20090611144430.414445947@intel.com> <20090612112258.GA14123@elte.hu> <20090612125741.GA6140@localhost> <20090612131754.GA32105@elte.hu> <alpine.LFD.2.01.0906120827020.3237@localhost.localdomain> <20090612153501.GA5737@elte.hu> <4A328444.3010301@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A328444.3010301@zytor.com>
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 09:37:24AM -0700, H. Peter Anvin wrote:
> Ingo Molnar wrote:
> > 
> > So i think hwpoison simply does not affect our ability to get log 
> > messages out - but it sure allows crappier hardware to be used.
> > Am i wrong about that for some reason?
> > 
> 
> Crappy hardware isn't the kind of hardware that is likely to have the
> hwpoison features, just like crappy hardware generally doesn't even have
> ECC -- or even basic parity checking (I personally think non-ECC memory
> should be considered a crime against humanity in this day and age.)

What I would find interesting with this hwpoison would be the probability 
difference between detecting an uncorrected error, and undetected errors.

 
> These kinds of features are used when extremely high reliability is
> required, think for example a telco core router.  A page error may have
> happened due to stray radiation or through power supply glitches (which
> happen even in the best of systems), but if they are a pattern, a box
> needs to be replaced.  *How quickly* a box can be taken out of service
> and replaced can vary greatly, and its urgency depend on patterns;
> furthermore, in the meantime the device has to work the best it can.

I don't know how much improvements that hwpoison will give. Significant
amount of RAM cannot be corrected, so especially on like a core router
or embedded system which does not use a lot of disk/pagecache, then it
is probably more like 2x improvement rather than an order of magnitude
improvement.


> Consider, for example, a control computer on the Hubble Space Telescope
> -- the only way to replace it is by space shuttle, and you can safely
> guarantee that *that* won't happen in a heartbeat.  On the new Herschel
> Space Observatory, not even the space shuttle can help: if the computers
> die, *or* if bad data gets fed to its control system, the spacecraft is
> lost.  As such, it's of paramount importance for the computers to (a)
> continue to provide service at the level the hardware is capable of
> doing, (b) as accurately as possible continually assess and report that
> level of service, and (c) not allow a failure to pass undetected.  A lot
> of failures are simple one-time events (especially in space, a high-rad
> environment), others reflect decaying hardware but can be isolated (e.g.
> a RAM cell which has developed a short circuit, or a CPU core which has
> a damaged ALU), while others yet reflect a general ill health of the
> system that cannot be recovered.

I guess most of these examples have to go far beyond this and use
multiply redundant computation and voting systems and quickly
reboot members that are kicked out. :)

Not that it is a detrement of hwpoison. If they used Linux I'm
sure they would like to panic on uncorrected error too (but would
probably not bother trying to do heuristic recovery).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
