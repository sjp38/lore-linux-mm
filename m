Date: Tue, 27 Jun 2000 13:46:43 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: Deleting an element from a free_list?
Message-Id: <20000627185658Z131176-21002+56@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

free_area[x].free_list.next points to the head of a linked list of free blocks
of order x (2^x contiguous pages).  If I simply remove one element from one of
these linked lists, using function list_del() in list.h, does that effectively
remove that block from the free list and hence prevent the kernel from
allocating those blocks of memory to anyone else?  This is assuming that I never
ever plan to "unallocate" those blocks of memory.  Will I need to also update
the corresponding mem_map_t structures by doing something like setting the usage
count to 1 or setting some bits in the flags field?



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
