Received: from mail.ccr.net (ccr@alogconduit1af.ccr.net [208.130.159.6])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA10613
	for <linux-mm@kvack.org>; Sun, 7 Feb 1999 19:43:43 -0500
Subject: Re: swapcache bug?
References: <36BDD9B2.8718B21@stud.uni-sb.de>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 07 Feb 1999 15:30:51 -0600
In-Reply-To: Manfred Spraul's message of "Sun, 07 Feb 1999 19:21:38 +0100"
Message-ID: <m1679dq4tw.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: masp0008@stud.uni-sb.de
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "MS" == Manfred Spraul <masp0008@stud.uni-sb.de> writes:

MS> I'm currently debugging my physical memory ramdisk, and I see lots of
MS> entries in the page cache that have 'page->offset' which aren't
MS> multiples of 4096. (they are multiples of 256)
MS> All of them belong to swapper_inode.

MS> If this is the intended behaviour, then page_hash() should be changed:
MS> it assumes that 'page->offset' is a multiple of 4096.

Yes.  Because for the swap cache we store the swap entry which is already
has the page size shifted out of it, but it's also setup so you can store
it directly in a pte which means some 0 bits.

Good spotting, but unless someone can show a significant performance impact 
changing page_hash should wait for 2.3.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
