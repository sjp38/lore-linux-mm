Subject: Re: Linus rollup
From: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030129022617.62800a6e.akpm@digeo.com>
References: <20030128220729.1f61edfe.akpm@digeo.com>
	 <20030129095949.A24161@flint.arm.linux.org.uk>
	 <20030129.015134.19663914.davem@redhat.com>
	 <20030129022617.62800a6e.akpm@digeo.com>
Content-Type: text/plain
Message-Id: <1043879752.10150.387.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Date: 29 Jan 2003 14:35:52 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "David S. Miller" <davem@redhat.com>, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2003-01-29 at 02:26, Andrew Morton wrote:
> "David S. Miller" <davem@redhat.com> wrote:
> >
> >    From: Russell King <rmk@arm.linux.org.uk>
> >    Date: Wed, 29 Jan 2003 09:59:49 +0000
> >    
> >    	/* This function must be called with interrupts disabled
> >    
> >    which hasn't been true for some time, and is even less true now that
> >    local IRQs don't get disabled.  Does this matter... for UP?
> > 
> > I disable local IRQs during gettimeofday() on sparc.
> > 
> > These locks definitely need to be taken with IRQs disabled.
> > Why isn't x86 doing that?
> 
> Darned if I know.  Looks like Andrea's kernel will deadlock if
> arch/i386/kernel/time.c:timer_interrupt() takes i8253_lock
> while that cpu is holding the same lock in do_slow_gettimeoffset().

Rather than disabling interrupts in the i386 do_gettimeofday
why not just change spin_lock(&i8253_lock) to spin_lock_irqsave
in timer_pit.c

-- 
Stephen Hemminger <shemminger@osdl.org>
Open Source Devlopment Lab


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
