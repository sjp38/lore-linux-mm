Date: Thu, 30 Jan 2003 18:50:06 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Linus rollup
Message-ID: <20030130175006.GO18538@dualathlon.random>
References: <20030129022617.62800a6e.akpm@digeo.com> <1043879752.10150.387.camel@dell_ss3.pdx.osdl.net> <20030129151206.269290ff.akpm@digeo.com> <20030129.163034.130834202.davem@redhat.com> <20030129172743.1e11d566.akpm@digeo.com> <20030130013522.GP1237@dualathlon.random> <20030129180054.03ac0d48.akpm@digeo.com> <20030130015427.GU1237@dualathlon.random> <1043948226.10150.587.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1043948226.10150.587.camel@dell_ss3.pdx.osdl.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Hemminger <shemminger@osdl.org>
Cc: Andrew Morton <akpm@digeo.com>, David Miller <davem@redhat.com>, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, rth@twiddle.net
List-ID: <linux-mm.kvack.org>

On Thu, Jan 30, 2003 at 09:37:06AM -0800, Stephen Hemminger wrote:
> 
> > you certainly mean wmb() not rmb(), right? If yes, then yes.
> > 
> > I actually didn't notice the write_begin/end, not sure who could need
> > them, I would suggest removing them, rather than to revert the mb()
> > there too.
> 
> The write_begin/end was suggested by Andrew as a simplification for use
> when using this to update values already write-locked by other means.
> 
> One possible usage was to fix the race issues with non-atomic update
> of 64 bit i_size.

It looks overdesign to me, you don't need the spinlock for that, the
i_sem is explicit too. The generalized abstraction is worthwhile when
you have to use it 99% of the time, the missing 1% doesn't need to be
abstracted, forward porting my implementation is the best for such
specific case IMHO.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
