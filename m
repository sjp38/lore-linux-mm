Date: Mon, 24 Jan 2000 14:40:51 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: GFP_XXX semantics (was: Re: [PATCH] 2.2.1{3,4,5} VM fix)
Message-ID: <20000124144051.A1340@fred.muc.de>
References: <Pine.LNX.4.21.0001221445150.440-100000@alpha.random> <Pine.LNX.4.10.10001241411310.24852-100000@nightmaster.csn. tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.10001241411310.24852-100000@nightmaster.csn. tu-chemnitz.de>; from Ingo Oeser on Mon, Jan 24, 2000 at 02:22:45PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@nl.linux.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 24, 2000 at 02:22:45PM +0100, Ingo Oeser wrote:
> On Sat, 22 Jan 2000, Andrea Arcangeli wrote:
> 
> [GFP-Mask semantics discussion]
> 
> ok, once we are about it here, could you please explain the
> _exact_ semantics for the GFP_XXX constants?
> 
> GFP_BUFFER
> GFP_ATOMIC
> GFP_BIGUSER
> GFP_USER
> GFP_KERNEL
> GFP_NFS
> GFP_KSWAPD
> 
> So which steps are tried to allocate these pages (freeing
> process, freeing globally, waiting, failing, kswapd-wakeup)? 
> 
> Because it is not easy to decide from a driver writers point of
> view, which one to use for which requests :(

As device driver writer you should only use two:
GFP_ATOMIC in interrupts/bottom halves/when you cannot sleep and
GFP_KERNEL when you're in user context and able to sleep.
All others are internal and only used by specific subsystems you
shouldn't care about.

-Andi

-- 
This is like TV. I don't like TV.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
