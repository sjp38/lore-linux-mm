Date: Thu, 30 Jan 2003 01:46:00 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Linus rollup
Message-ID: <20030130004600.GI1237@dualathlon.random>
References: <20030128220729.1f61edfe.akpm@digeo.com> <20030129095949.A24161@flint.arm.linux.org.uk> <20030129.015134.19663914.davem@redhat.com> <20030129022617.62800a6e.akpm@digeo.com> <1043879752.10150.387.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1043879752.10150.387.camel@dell_ss3.pdx.osdl.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Hemminger <shemminger@osdl.org>
Cc: Andrew Morton <akpm@digeo.com>, "David S. Miller" <davem@redhat.com>, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 29, 2003 at 02:35:52PM -0800, Stephen Hemminger wrote:
> On Wed, 2003-01-29 at 02:26, Andrew Morton wrote:
> > "David S. Miller" <davem@redhat.com> wrote:
> > >
> > >    From: Russell King <rmk@arm.linux.org.uk>
> > >    Date: Wed, 29 Jan 2003 09:59:49 +0000
> > >    
> > >    	/* This function must be called with interrupts disabled
> > >    
> > >    which hasn't been true for some time, and is even less true now that
> > >    local IRQs don't get disabled.  Does this matter... for UP?
> > > 
> > > I disable local IRQs during gettimeofday() on sparc.
> > > 
> > > These locks definitely need to be taken with IRQs disabled.
> > > Why isn't x86 doing that?
> > 
> > Darned if I know.  Looks like Andrea's kernel will deadlock if
> > arch/i386/kernel/time.c:timer_interrupt() takes i8253_lock
> > while that cpu is holding the same lock in do_slow_gettimeoffset().
> 
> Rather than disabling interrupts in the i386 do_gettimeofday
> why not just change spin_lock(&i8253_lock) to spin_lock_irqsave
> in timer_pit.c

as you can see from my patch, I agree

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
