Date: Wed, 3 Sep 2003 10:24:32 -0400 (EDT)
From: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Subject: removing clean anonymous pages
Message-ID: <Pine.GSO.4.51.0309031020290.21545@aria.ncl.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 Hi,

   I see in try_to_swap_out() (linux 2.4.19), that when we remove a clean
anonymous page, we clear the pte entries. So when a page is swapped out to
the disk and then brought back to the memory. If that page is again
selected for removal during page replacement, then if we just clear the
pte entries wont we be losing the data. I think I have understood it
wrong. Can you please try to explain me this.

 Thanks,
 Raghu
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
