Date: Mon, 2 Oct 2000 16:32:27 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <20001003012546.C27493@athlon.random>
Message-ID: <Pine.LNX.4.10.10010021630390.4306-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@conectiva.com.br>, MM mailing list <linux-mm@kvack.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


On Tue, 3 Oct 2000, Andrea Arcangeli wrote:

> On Tue, Oct 03, 2000 at 01:29:27AM +0200, Ingo Molnar wrote:
> > it can and does lose them - but only all of them. Aging OTOH is a per-bh
> > thing, this kind of granularity is simply not present in the current
> > page->buffers handling. This is all i wanted to mention. Not unsolvable,
> 
> I'm pretty sure it doesn't worth the per-bh thing. And even if it would make
> any difference with a 1k fs for good performance 4k blksize is necessary anyway
> for other reasons.

Well, remember that some page sizes are large. A page size is not
necessarily 4k. It could be 64k.

Now, you're probably right that if you want to perform well, a 64k block
is not that large, and most things that do ordered writes might not be too
badly off with even that kind of big ordering granularity. But let's not
take it for granted.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
