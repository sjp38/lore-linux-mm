Received: from wildwood.eecs.umich.edu (haih@wildwood.eecs.umich.edu [141.213.4.68])
	by smtp.eecs.umich.edu (8.12.2/8.12.3) with ESMTP id g6NLIEwK024129
	for <linux-mm@kvack.org>; Tue, 23 Jul 2002 17:18:14 -0400
Date: Tue, 23 Jul 2002 17:21:30 -0400 (EDT)
From: Hai Huang <haih@eecs.umich.edu>
Subject: Anyone seen this before
Message-ID: <Pine.LNX.4.33.0207231717120.3622-100000@wildwood.eecs.umich.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

By dumping the mem_map, I've observed some werid pages. Let me know
if you've seen this before or have a hunch about it.

Basically, I've seen many of pages with page->count == 1 and page->flags
= 0x1000000.  I'm using kernel 2.4.18-3 w/ rmap and w/HIGHMEM disabled.
The machine only has one entry on the pgdat_list (that's why the 1 in
0x1000000).  But I can decipher what can cause a page to be allocated with
an empty page->flag.  Any clues?

-
hai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
