Date: Mon, 25 Sep 2000 15:19:35 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VM
Message-ID: <20000925151935.B22882@athlon.random>
References: <20000925150258.B13011@athlon.random> <Pine.LNX.4.21.0009251503420.6224-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251503420.6224-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 03:04:10PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 03:04:10PM +0200, Ingo Molnar wrote:
> 
> On Mon, 25 Sep 2000, Andrea Arcangeli wrote:
> 
> > Please fix raid1 instead of making things worse.
> 
> huh, what do you mean?

I mean this:

		while (!( /* FIXME: now we are rather fault tolerant than nice */
		mirror_bh[i] = kmalloc (sizeof (struct buffer_head), GFP_KERNEL)
		) )

I've seen in the 2.4.0-test9-pre6 raid1 code the above is gone (and this looks
very promising :)), it is at least proof that some care about the deadlock is
been taken) and you instead sleep on a waitqueue now. While it's not obvious at
all that sleeping on the waitqueue is not deadlock prone (for example getblk
sleeps on a waitqueue bit it's deadlock prone too), at least it's not an
infinite loop anymore and that's still better.

Is it safe to sleep on the waitqueue in the kmalloc fail path in raid1?

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
