Date: Mon, 9 Jul 2001 15:18:43 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [wip-PATCH] Re: Large PAGE_SIZE
In-Reply-To: <3B49AE09.CE19FBAC@mandrakesoft.com>
Message-ID: <Pine.LNX.4.21.0107091426450.1282-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: Ben LaHaise <bcrl@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Jul 2001, Jeff Garzik wrote:
> Hugh Dickins wrote:
> > On Sun, 8 Jul 2001, Ben LaHaise wrote:
> > >
> > > Hmmm, interesting.  At present page cache sizes from PAGE_SIZE to
> > > 8*PAGE_SIZE are working here.  Setting the shift to 4 or a 64KB page size
> > > results in the SCSI driver blowing up on io completion.
> > 
> > I hit that limit too: I believe it comes from unsigned short b_size.
> 
> That limit's not a big deal.. the limits in the lower-level disk drivers
> are what you start hitting...

Examples?

Limits below 64kB with some drivers we happen not to be using,
or limits >= 64kB we'd soon hit if we chose to do something about
unsigned short b_size (e.g. short sizes in the drivers own code)?

Limits in the disk drivers or limits in their firmware?  If the limits
are in the drivers, then they're probably PAGE_SIZE limits which raising
PAGE_SIZE deals with automatically, but raising PAGE_CACHE_SIZE needs
more edits to get working.

(Whereas raising PAGE_SIZE needs edits where it's the vm_pgoff
MMAP_? MMU_? PTE_? VM_? SUB? PAGE_SIZE that's needed.)

Linus believes it would be no more than a few buggy drivers which would
impose such limits; I don't know, I took little notice of the instances
I didn't need to change in raising PAGE_SIZE.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
