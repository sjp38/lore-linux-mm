Message-ID: <3D5D7572.DD7ACA23@zip.com.au>
Date: Fri, 16 Aug 2002 14:58:10 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: clean up mem_map usage ... part 1
References: <3D5D6CFF.9153184D@zip.com.au> <2448940000.1029533820@flay>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> > Looks good, thanks.  I'll nail an unneeded typecast in there.
> >
> > My queue runneth over at present, and the kmap patches need to
> 
> I'm not suprised ;-) I can queue more stuff here rather than send it
> to your queue, but I'd like you to keep an eye on me before I go too far
> astray from what you want to see ;-)

Oh whatever.  If it's in my pile then a few more people get to
bang on it for a while.  Looks like a long backlog will become
a permanent state, so I'll need to do something more organised
there.

> > I won't send the rmap locking hacklets until we've nailed that
> > BUG in __free_pages_ok.
> 
> That seems to occur with 2.5.31, AFIACS, it's not the extra patches
> you have ... unless you mean just not stirring the pot at the moment.

Well yes.  The code at present is pretty much the same as well-tested 2.4
code which presumably will make it easier to find this bug.  Changing
the code now would increase the volume of suspect code.
 
> ...
> 2. mapnr. This is the index into the mem_map array. For contigmem,
> thats equiv to a pfn, and more or less made some sense.
> For discontigmem that's a nasty hack. We don't have a mem_map array,
> we have an lmem_map array per pg_data_t (aka node or memory chunk).
> But we somehow decided to define mem_map = PAGE_OFFSET, then
> retend the whole of the virtual address space is some kind of klunky
> mem_map array with holes in. So node_start_mapnr = lmem_map - mem_map ....
> except that's really arith on struct pages, so it's the distance / sizeof(struct page).
> So we have to align lmem_map allocations on a boundary of size sizeof(struct page),
> except that's really a boundary from PAGE_OFFSET, not absolute vaddr.
> Gack. Look at free_area_init_core. It's unpleasant ;-)

I wish you hadn't told me all that.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
