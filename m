Received: from cs1p51.dial.cistron.nl ([62.216.3.52] helo=test.augan)
	by smtp.cistron.nl with esmtp (Exim 3.13 #1 (Debian))
	id 139QgM-0006ch-00
	for <linux-mm@kvack.org>; Tue, 04 Jul 2000 13:16:02 +0200
Received: from augan.com (IDENT:roman@serv2.augan [130.1.1.31])
	by test.augan (8.9.3/8.8.7) with ESMTP id NAA24458
	for <linux-mm@kvack.org>; Tue, 4 Jul 2000 13:15:37 +0200
Message-ID: <3961C759.DA95744E@augan.com>
Date: Tue, 04 Jul 2000 13:15:37 +0200
From: Roman Zippel <roman@augan.com>
MIME-Version: 1.0
Subject: how does the fs cache work?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I'm currently trying to understand how the fs cache in 2.4 works, but
I'm slightly confused, how a few things are supposed to work.
Am I seeing it correctly, that if we're looking for a free page we're
basically looking into three caches? We check for mapped pages
(swap_out), we shrink the lru_cache (shrink_mmap) and we clean the inode
cache (shrink_icache_memory).
Furthermore the only policy that I see that prevents a page being freed
is "was it used last time we checked?", how is that supposed to work
under load?
Is there any way to share a block that is read from a file and the same
read from the block device? A possible user might be e2fsck, but
currently it doesn't seem to be problem, as ext2 doesn't use the page
cache for meta data.
Hmm, I think, that's enough questions for now, I come up with more
later. :)

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
