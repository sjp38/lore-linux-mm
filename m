Date: Tue, 5 Aug 2003 11:45:36 -0400 (EDT)
From: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Subject: anonymous buffer pages
Message-ID: <Pine.GSO.4.51.0308051141270.10476@aria.ncl.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 Hi,

  when are anonymous buffer pages created and how are they removed from
the system  in linux 2.4.19 ? In try_to_swap_out() when it encounters a
anonymous buffer page the page is not unmapped from the process. So how is
this page freed to the free-list ?

 Thanks a lot,
Raghu
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
