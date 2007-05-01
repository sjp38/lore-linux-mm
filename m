Date: Tue, 1 May 2007 14:31:49 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Antifrag patchset comments
In-Reply-To: <Pine.LNX.4.64.0704301016180.32439@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0705011416220.12797@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0704271854480.6208@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704281229040.20054@skynet.skynet.ie>
 <Pine.LNX.4.64.0704281425550.12304@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704301016180.32439@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Apr 2007, Mel Gorman wrote:
> On Sat, 28 Apr 2007, Christoph Lameter wrote:
> 
> > > > 11. shmem_alloc_page() shmem pages are only __GFP_RECLAIMABLE?
> > > > They can be swapped out and moved by page migration, so GFP_MOVABLE?
> > >
> > > Because they might be ramfs pages which are not movable -
> > > http://lkml.org/lkml/2006/11/24/150
> >
> > URL does not provide any useful information regarding the issue.
> 
> Not all pages allocated via shmem_alloc_page() are movable because they may
> pages for ramfs.

We seem to have a miscommunication here.

shmem_alloc_page() is static to mm/shmem.c, is used for all shm/tmpfs
data pages (unless CONFIG_TINY_SHMEM), and all those data pages may be
swapped out (while not locked in use).

ramfs pages cannot be swapped out; but shmem_alloc_page() is not used
to allocate them.  CONFIG_TINY_SHMEM uses mm/tiny-shmem.c instead of
mm/shmem.c, redirecting all shm/tmpfs requests to the simpler but
unswappable ramfs.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
