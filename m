Date: Mon, 15 Jan 2001 23:36:31 +0100
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: swapout selection change in pre1
Message-ID: <20010115233631.B19042@pcep-jamie.cern.ch>
References: <20010115224417.A19042@pcep-jamie.cern.ch> <Pine.LNX.4.10.10101151351360.850-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10101151351360.850-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Mon, Jan 15, 2001 at 01:57:10PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ed Tomlinson <tomlins@cam.org>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> It's just fairly slow to look things up that way. That's going to be
> especially true of you have _lots_ of people mapping that vma - you'd have
> to look them all up, even if only one or two actually have the page in
> question mapped.
>
> (The alternative, of course, is to add a new "struct list_head" to the
> "struct page" structure, and make that be the anchor for all VMA's that
> have this page actually inserted. That would be pretty efficient, but I'd
> hate wasting the memory, ugh. We could be clever and share a list for
> multiple pages, ho humm..)

I don't see how you can anchor "all VMAs that have this page actually
inserted".  That's a list per page.  Where do all the links live
(without using tons of memory)?

But anyway, as long as you can arrange that a page is hooked into a list
of regions, using region splitting, where on average at least X% of the
regions have the page mapped, that should be ok.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
