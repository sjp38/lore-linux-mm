Date: Mon, 25 Sep 2000 19:15:40 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VMt
Message-ID: <20000925191540.F27677@athlon.random>
References: <Pine.LNX.4.21.0009251338340.14614-100000@duckman.distro.conectiva> <Pine.LNX.4.10.10009250948170.1739-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10009250948170.1739-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Mon, Sep 25, 2000 at 09:49:46AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 09:49:46AM -0700, Linus Torvalds wrote:
> [..] I
> don't think the balancing has to take the order of the allocation into
> account [..]

Why do you prefer to throw away most of the cache (potentially at fork time)
instead of freeing only the few contigous bits that we need?

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
