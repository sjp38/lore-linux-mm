Date: Mon, 25 Sep 2000 18:33:43 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VMt
Message-ID: <20000925183343.B27677@athlon.random>
References: <20000925181121.A27023@athlon.random> <Pine.LNX.4.21.0009251821170.9122-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251821170.9122-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 06:22:42PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 06:22:42PM +0200, Ingo Molnar wrote:
> yep, i agree. I'm not sure what the biggest allocation is, some drivers
> might use megabytes or contiguous RAM?

I'm not sure (we should grep all the drivers to be sure...) but I bet the old
2.2.0 MAX_ORDER #define will work for everything.

The fact is that over a certain order there's no hope anyway at runtime
and the only big allocations done through the init sequence are for
the hashtable.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
