Date: Mon, 4 Aug 2003 15:50:57 -0400 (EDT)
From: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Subject: buffer head and buffer pages
Message-ID: <Pine.GSO.4.51.0308041544400.29728@aria.ncl.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  Hi,

  Please help me to understand this better. each buffer has a buffer
head. the b_page of buffer_head points to the page that contains the
mapped data. Will both these pages ( the page that holds the buffer_head
structure and buffer page that contains the actual data) mapped to the
process OR only the page with the buffer_head is mapped to the process ?
In other words, the rss value of the process accounts for both these pages
or it accounts for only the page with the buffer_head ?

 Thanks a lot,
 Raghu
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
