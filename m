Date: Sun, 5 Jun 2005 20:16:54 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: 2.6.12-rc4-mm2
Message-ID: <20050605201654.E26388@flint.arm.linux.org.uk>
References: <20050516130048.6f6947c1.akpm@osdl.org> <20050516210655.E634@flint.arm.linux.org.uk> <030401c55a6e$34e67cb0$0f01a8c0@max> <20050516163900.6daedc40.akpm@osdl.org> <20050602220213.D3468@flint.arm.linux.org.uk> <008201c569c3$61b30ab0$0f01a8c0@max> <20050605124556.A23271@flint.arm.linux.org.uk> <010a01c569fe$83899a10$0f01a8c0@max>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <010a01c569fe$83899a10$0f01a8c0@max>; from rpurdie@rpsys.net on Sun, Jun 05, 2005 at 07:43:38PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Purdie <rpurdie@rpsys.net>
Cc: Andrew Morton <akpm@osdl.org>, Wolfgang Wander <wwc@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 05, 2005 at 07:43:38PM +0100, Richard Purdie wrote:
> Russell King:
> >>     [PATCH] ARM: Move copy/clear user_page locking into implementation
> >
> > This one changes the way we do these operations on SA1100, but it got
> > tested prior to submission on the Assabet which didn't show anything
> > up.  However, if I had to pick one, it'd be this.
> 
> The test system is ARM PXA255 based (v5te core, preempt enabled) and its 
> using copypage-xscale.S. I suspect the locking below is needed on the xscale 
> for some reason.
> 
> Does that make sense and highlight a problem?

You must be running with preemption enabled then, and it looks like
I forgot to update the Xscale copypage functions for this change.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 Serial core
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
