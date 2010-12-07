Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3A7866B0087
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 20:49:28 -0500 (EST)
Received: from sim by peace.netnation.com with local (Exim 4.69)
	(envelope-from <sim@netnation.com>)
	id 1PPmgD-0004zQ-Hx
	for linux-mm@kvack.org; Mon, 06 Dec 2010 17:49:21 -0800
Date: Mon, 6 Dec 2010 17:49:21 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Behaviour during slab leak
Message-ID: <20101207014921.GB13759@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

There was an NFS regression in 2.6.37-rc(1-4) that caused kmalloc-32 and
kmalloc-16 to leak all over the place, and I noticed that while this was
happening, the memory graphs looked odd in munin.  Is this expected?

This seems to relate to the size of Normal zone, which are the same as on
the other 4 GB box I reported.

http://0x.ca/sim/ref/2.6.37/nfsleak/memory_nfsleak.png
http://0x.ca/sim/ref/2.6.37/nfsleak/

Maybe this is related to the too much free memory problems I am seeing?

Simon-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
