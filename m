Date: Mon, 15 Jan 2001 13:57:10 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: swapout selection change in pre1
In-Reply-To: <20010115224417.A19042@pcep-jamie.cern.ch>
Message-ID: <Pine.LNX.4.10.10101151351360.850-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Ed Tomlinson <tomlins@cam.org>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 15 Jan 2001, Jamie Lokier wrote:
> 
> No, that's the point, you _don't_ need a structure per page table entry.

Ok. In that case, we already have all the infrastructure. It's just too
slow to use as a generic replacement for scanning the VM.

It's just fairly slow to look things up that way. That's going to be
especially true of you have _lots_ of people mapping that vma - you'd have
to look them all up, even if only one or two actually have the page in
question mapped.

(The alternative, of course, is to add a new "struct list_head" to the
"struct page" structure, and make that be the anchor for all VMA's that
have this page actually inserted. That would be pretty efficient, but I'd
hate wasting the memory, ugh. We could be clever and share a list for
multiple pages, ho humm..)

I still don't think it's actually worth it, but hey, I still say that if
you find a good use for it, go right ahead..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
