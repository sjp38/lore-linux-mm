Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA07663
	for <linux-mm@kvack.org>; Fri, 12 Jun 1998 00:28:47 -0400
Received: from localhost.phys.uu.nl (root@anx1p8.fys.ruu.nl [131.211.33.97])
	by max.fys.ruu.nl (8.8.7/8.8.7/hjm) with ESMTP id GAA14078
	for <linux-mm@kvack.org>; Fri, 12 Jun 1998 06:28:37 +0200 (MET DST)
Received: from localhost (riel@localhost) by mirkwood.dummy.home (8.8.3/8.8.3) with SMTP id AAA21758 for <linux-mm@kvack.org>; Fri, 12 Jun 1998 00:02:16 +0200
Date: Thu, 11 Jun 1998 23:59:45 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: TODO list, v0.01
Message-ID: <Pine.LNX.3.95.980611235823.21729A-100000@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

here's the MM TODO list, very first version, just listing
the projects people are working on.

Other projects are yet to be added -- what ones?

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

----------------------------------------------

Linux Memory Management TODO & being-done list.



Erik W. Biedermann <ebiederm+erik@npwt.de>

	Large file (40 bits on 32 bit) support in the page cache
	Write back caching through the page cache.
	Ability to use swap for non-process things. Shared memory etc.

Benjamin C.R. LaHaise <blah@kvack.org>

	Reverse PTE lookup (together with Stephen Tweedie).
	Swapout overhaul (comes with PTE chaining).

Stephen C. Tweedie

	Reverse PTE lookup (together with Benjamin C.R. LaHaise).
	Swapin readahead.
	MM subsystem overhaul.

Rik van Riel <H.H.vanRiel@phys.uu.nl>

	Zone based memory allocator.
	Better swapout clustering.	(help welcome)
	Real swapping (program suspension).
	Out of memory handler.		(help welcome)

Werner Fink <werner@suse.de>

	???
