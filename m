Received: from northrelay02.pok.ibm.com (northrelay02.pok.ibm.com [9.117.200.22])
	by e1.ny.us.ibm.com (8.9.3/8.9.3) with ESMTP id SAA111452
	for <linux-mm@kvack.org>; Sat, 7 Apr 2001 18:28:01 -0400
Received: from d01ml233.pok.ibm.com (d01ml233.pok.ibm.com [9.117.200.63])
	by northrelay02.pok.ibm.com (8.8.8m3/NCO v4.95) with ESMTP id SAA165770
	for <linux-mm@kvack.org>; Sat, 7 Apr 2001 18:24:50 -0400
Subject: (struct page *)->list
Message-ID: <OFF7EEC8B0.74CE8D02-ON85256A27.0079C289@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Sat, 7 Apr 2001 18:30:07 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Question about the ->list field in linux/include/mm.h
typedef struct page
{
     struct list_head list;
     ...
} mem_map_t;


I have a device driver that allocates pages with
alloc_pages(gfp_mask,0) call.  I want to use
the ->list field and associated list_add() and list_del()
functions to keep track of my pages.  The driver allocates
with GFP_KERNEL and GFP_HIGHUSER and will use the PAE
mode as well.

The question is if I unhook the page->list field after
page=alloc_page() and add page->list to my private linked list
will that cause a problem elsewhere in the kernel?

>From my reading the code, the list field
is used only when pages are in the free page pool or
in the mmap code in mm/filemap.c.   Appreciate any suggestions.

Bulent


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
