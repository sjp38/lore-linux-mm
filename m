Received: from hermes.rz.uni-sb.de (hermes.rz.uni-sb.de [134.96.7.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA07443
	for <linux-mm@kvack.org>; Sun, 7 Feb 1999 13:22:00 -0500
Received: from sbustd.stud.uni-sb.de (1OCdJ/TfriDCin1Rq0DQl4dQzNo21ghJ@eris.rz.uni-sb.de [134.96.7.8])
	by hermes.rz.uni-sb.de (8.8.8/8.8.7/8.7.7) with ESMTP id TAA22617
	for <linux-mm@kvack.org>; Sun, 7 Feb 1999 19:21:52 +0100 (CET)
Message-ID: <36BDD9B2.8718B21@stud.uni-sb.de>
Date: Sun, 07 Feb 1999 19:21:38 +0100
From: Manfred Spraul <masp0008@stud.uni-sb.de>
Reply-To: masp0008@stud.uni-sb.de
MIME-Version: 1.0
Subject: swapcache bug?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I'm currently debugging my physical memory ramdisk, and I see lots of
entries in the page cache that have 'page->offset' which aren't
multiples of 4096. (they are multiples of 256)
All of them belong to swapper_inode.

If this is the intended behaviour, then page_hash() should be changed:
it assumes that 'page->offset' is a multiple of 4096.

If this should not happen, please ask me for further details.

Note that there is NO crash, just lots of entries with the same hash
value.
---
- 2.2.1 kernel
- 12 MB Ram
- 72256 kB Swap-partition
---
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
