Date: Tue, 3 Oct 2000 14:05:46 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <20001003012546.C27493@athlon.random>
Message-ID: <Pine.LNX.4.21.0010031404300.3569-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Oct 2000, Andrea Arcangeli wrote:

> > it can and does lose them - but only all of them. Aging OTOH is a per-bh
> > thing, this kind of granularity is simply not present in the current
> > page->buffers handling. This is all i wanted to mention. Not unsolvable,
> 

> I'm pretty sure it doesn't worth the per-bh thing. And even if it
> would make any difference with a 1k fs for good performance 4k blksize
> is necessary anyway for other reasons.

well if those bhs are aged by the normal buffer-cache aging mechanizm,
then there is no choice but to age them at bh granularity, not page
granularity. (this is only interesting in the case of 1k filesystems.)
Aging page->buffers at bh granularity creates interesting situations.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
