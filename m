Date: Wed, 28 Jun 2000 17:22:09 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: kmap_kiobuf() 
In-Reply-To: <200006282016.PAA19321@jen.americas.sgi.com>
Message-ID: <Pine.LNX.3.96.1000628165811.22084F-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lord@sgi.com
Cc: "Stephen C. Tweedie" <sct@redhat.com>, David Woodhouse <dwmw2@infradead.org>, linux-mm@kvack.org, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jun 2000 lord@sgi.com wrote:

...
> Ben mentioned large page support as another way to get around this
> problem. Where is that in the grand scheme of things?
...

For filesystems, I meant increasing PAGE_CACHE_SIZE.  I'm planning on
getting this working for 2.5.early.  Of course, this will put more
pressure on the memory allocator which means that it will have to go along
with zoning changes.

Large page support will be a somewhat different beast: using 4MB pages (on
x86) for mapping/io purposes.  The idea there is that the individual pages
would still be put into the page cache, but they would be marked with a
flag as part of a large page (should be fairly similar to how other unices
implement it).  It's really only relevant to the mm subsystem and the
tlb's on machines that support varying page sizes.

> p.s. Woudn't the remapping of pages be a way to let modules etc get larger
> arrays of memory after boot time - doing it a few times is not going to
> kill the system.

Hrm?  Allocating physically contiguous memory is a problem that requires
big changes to the allocator and the swapper.  Sure, once we get these
fixed, all sorts of things become possible.  But this doesn't help with
the fact that kernel mappings for objects larger than a single page just
aren't possible right now.  Hmm.  How bad would supporting a small number
of fixed higher-order kmaps be?  (and what's Linus' opinion on such a
change?)

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
