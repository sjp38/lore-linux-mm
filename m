Received: from northrelay02.pok.ibm.com (northrelay02.pok.ibm.com [9.117.200.22])
	by e4.ny.us.ibm.com (8.9.3/8.9.3) with ESMTP id OAA196844
	for <linux-mm@kvack.org>; Tue, 27 Jun 2000 14:52:38 -0400
From: frankeh@us.ibm.com
Received: from D51MTA03.pok.ibm.com (d51mta03.pok.ibm.com [9.117.200.31])
	by northrelay02.pok.ibm.com (8.8.8m3/NCO v4.9) with SMTP id OAA234556
	for <linux-mm@kvack.org>; Tue, 27 Jun 2000 14:54:30 -0400
Message-ID: <8525690B.0067D1F0.00@D51MTA03.pok.ibm.com>
Date: Tue, 27 Jun 2000 14:55:15 -0400
Subject: Re: Deleting an element from a free_list?
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

NO, it will NOT prevent the kernel of allocating these blocks. They have to
be properly marked in the
bitmaps of the buddy algorithm...
You basically have to do what alloc_pages() does !!
If you know the addresses upfront at boottime ... you might screw around
with the reserve_bootmem or the
BIOS E820 bootmem map.....  (assuming you are sitting on an x86 box).

-- Hubertus

Timur Tabi <ttabi@interactivesi.com>@kvack.org on 06/27/2000 02:46:43 PM

Sent by:  owner-linux-mm@kvack.org


To:   Linux MM mailing list <linux-mm@kvack.org>
cc:
Subject:  Deleting an element from a free_list?



free_area[x].free_list.next points to the head of a linked list of free
blocks
of order x (2^x contiguous pages).  If I simply remove one element from one
of
these linked lists, using function list_del() in list.h, does that
effectively
remove that block from the free list and hence prevent the kernel from
allocating those blocks of memory to anyone else?  This is assuming that I
never
ever plan to "unallocate" those blocks of memory.  Will I need to also
update
the corresponding mem_map_t structures by doing something like setting the
usage
count to 1 or setting some bits in the flags field?



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then
I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
