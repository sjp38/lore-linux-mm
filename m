Date: Mon, 25 Sep 2000 18:22:42 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: the new VMt
In-Reply-To: <20000925181121.A27023@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251821170.9122-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

> > ie. 99.45% of all allocations are single-page! 0.50% is the 8kb
> 
> You're right. That's why it's a waste to have so many order in the
> buddy allocator. [...]

yep, i agree. I'm not sure what the biggest allocation is, some drivers
might use megabytes or contiguous RAM?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
