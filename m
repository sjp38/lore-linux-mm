Date: Fri, 16 Aug 2002 15:15:07 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: clean up mem_map usage ... part 1
Message-ID: <2457760000.1029536107@flay>
In-Reply-To: <3D5D7572.DD7ACA23@zip.com.au>
References: <3D5D6CFF.9153184D@zip.com.au> <2448940000.1029533820@flay> <3D5D7572.DD7ACA23@zip.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> 2. mapnr. This is the index into the mem_map array. For contigmem,
>> thats equiv to a pfn, and more or less made some sense.
>> For discontigmem that's a nasty hack. We don't have a mem_map array,
>> we have an lmem_map array per pg_data_t (aka node or memory chunk).
>> But we somehow decided to define mem_map = PAGE_OFFSET, then
>> retend the whole of the virtual address space is some kind of klunky
>> mem_map array with holes in. So node_start_mapnr = lmem_map - mem_map ....
>> except that's really arith on struct pages, so it's the distance / sizeof(struct page).
>> So we have to align lmem_map allocations on a boundary of size sizeof(struct page),
>> except that's really a boundary from PAGE_OFFSET, not absolute vaddr.
>> Gack. Look at free_area_init_core. It's unpleasant ;-)
> 
> I wish you hadn't told me all that.

;-) 

But when I send you the patch to rip it all out, you'll be happy now ;-)

M.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
