Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BCA9E6B0012
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 18:20:57 -0400 (EDT)
Date: Fri, 10 Jun 2011 23:20:20 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
	instead of failing
Message-ID: <20110610222020.GP24424@n2100.arm.linux.org.uk>
References: <alpine.LFD.2.02.1106012134120.3078@ionos> <4DF1C9DE.4070605@jp.fujitsu.com> <20110610004331.13672278.akpm@linux-foundation.org> <BANLkTimC8K2_H7ZEu2XYoWdA09-3XxpV7Q@mail.gmail.com> <20110610091233.GJ24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101150280.17197@chino.kir.corp.google.com> <20110610185858.GN24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101456080.23076@chino.kir.corp.google.com> <20110610220748.GO24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101510000.23076@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1106101510000.23076@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, pavel@ucw.cz

On Fri, Jun 10, 2011 at 03:16:00PM -0700, David Rientjes wrote:
> On Fri, 10 Jun 2011, Russell King - ARM Linux wrote:
> 
> > > We're talking about two different things.  Linus is saying that if GFP_DMA 
> > > should be a no-op if the hardware doesn't require DMA memory because the 
> > > kernel was correctly compiled without CONFIG_ZONE_DMA.  I'm asking about a 
> > > kernel that was incorrectly compiled without CONFIG_ZONE_DMA and now we're 
> > > returning memory from anywhere even though we actually require GFP_DMA.
> > 
> > How do you distinguish between the two states?  Answer: you can't.
> > 
> 
> By my warning which says "enable CONFIG_ZONE_DMA _if_ needed."  The 
> alternative is to silently return memory from anywhere, which is what the 
> page allocator does now, which doesn't seem very user friendly when the 
> device randomly works depending on the chance it was actually allocated 
> from the DMA mask.  If it actually wants DMA and the kernel is compiled 
> incorrectly, then I think a single line in the kernel log would be nice to 
> point them in the right direction.  Users who disable the option usually 
> know what they're doing (it's only allowed for CONFIG_EXPERT on x86, for 
> example), so I don't think they'll mind the notification and choose to 
> ignore it.

So those platforms which don't have a DMA zone, don't have any problems
with DMA, yet want to use the very same driver which does have a problem
on ISA hardware have to also put up with a useless notification that
their kernel might be broken?

Are you offering to participate on other architectures mailing lists to
answer all the resulting queries?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
