Date: Mon, 25 Sep 2000 18:11:21 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VMt
Message-ID: <20000925181121.A27023@athlon.random>
References: <20000925174138.D25814@athlon.random> <Pine.LNX.4.21.0009251747190.9122-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251747190.9122-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 06:02:18PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 06:02:18PM +0200, Ingo Molnar wrote:
> Frankly, how often do we allocate multi-order pages? I've just made quick

The deadlock Alan pointed out can happen also with single page allocation
if we in 2.4.x-current put a loop in GFP_KERNEL.

> ie. 99.45% of all allocations are single-page! 0.50% is the 8kb

You're right. That's why it's a waste to have so many order in the
buddy allocator. Even more now that the hashtables should be allocated
with the bootmem allocator! :) Chuck seen the slowdown of increasing
the highest order allocation in his bench. But of course in 2.2.x we can't
avoid that.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
