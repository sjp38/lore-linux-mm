Date: Fri, 13 Oct 2000 14:29:08 -0700
Message-Id: <200010132129.OAA03105@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <E13k3HY-0000yb-00@the-village.bc.nu> (message from Alan Cox on
	Fri, 13 Oct 2000 12:45:47 +0100 (BST))
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
References: <E13k3HY-0000yb-00@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: alan@lxorguk.ukuu.org.uk
Cc: davej@suse.de, tytso@mit.edu, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   > It might make more sense to just make rss an atomic_t.

   Can we always be sure the rss will fit in an atomic_t - is it >
   32bits on the ultrsparc/alpha ?

Yes, this issue occurred to me last night as well.
It is 32-bit on Alpha/UltraSparc.

However, given the fact that this number measures "pages", the
PAGE_SIZE on Ultra/Alpha, and the size of the 64-bit user address
space on Ultra and Alpha, it would actually end up working.

This doesn't make it a good idea though.

Later,
David S. Miller
davem@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
