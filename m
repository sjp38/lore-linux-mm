Date: Tue, 12 Aug 2003 15:31:59 -0400 (EDT)
From: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Subject: removing clean mapped pages
Message-ID: <Pine.GSO.4.51.0308121522570.23513@aria.ncl.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 Hi,

   How does a frame, mapped to a disk file gets released to the free list.
I do not see any place in shrink_cache() nor in try_to_swap_out() such a
page getting released.
What am i missing over here ?

 Thanks,
 Raghu
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
