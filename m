Date: Mon, 25 Sep 2000 12:17:36 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: the new VMt
In-Reply-To: <Pine.LNX.4.21.0009251821170.9122-100000@elte.hu>
Message-ID: <Pine.GSO.4.21.0009251217020.16980-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 25 Sep 2000, Ingo Molnar wrote:

> On Mon, 25 Sep 2000, Andrea Arcangeli wrote:
> 
> > > ie. 99.45% of all allocations are single-page! 0.50% is the 8kb
> > 
> > You're right. That's why it's a waste to have so many order in the
> > buddy allocator. [...]
> 
> yep, i agree. I'm not sure what the biggest allocation is, some drivers
> might use megabytes or contiguous RAM?

Stupidity has no limits...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
