Date: Thu, 22 Jun 2000 12:33:24 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: What is field map in free_area_t?
Message-Id: <20000622174020Z131174-21004+48@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Before I ask my question, I'd like to thank everyone who's helped me so far.  I
really appreciate all this help, and it is making a big difference in my ability
to understand the Linux kernel.  I look forward to the day when I can answer
other people's questions, and once I'm done, I'm planning on writing a document
that explains what I've learned.

Could someone explain to me what the "map" field of struct free_area_t does? 
It's defined in mmzone.h:

typedef struct free_area_struct {
	struct list_head	free_list;
	unsigned int	*map;
} free_area_t;

It appears to be a pointer to some kind of field of bits, but that's all I
could figure out.  It's used in two places:

page_alloc.c, function __free_pages_ok:

	if (!test_and_change_bit(index, area->map))

and in function free_area_init_core:

	zone->free_area[i].map = 
	  (unsigned int *) alloc_bootmem_node(nid, bitmap_size);

It's also part of the MARK_USED macro:

#define MARK_USED(index, order, area) \
	change_bit((index) >> (1+(order)), (area)->map)

which is used in functions expand() and rmqueue().



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
