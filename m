Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA29177
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 11:50:36 -0500
Received: from mirkwood.dummy.home (root@anx1p8.phys.uu.nl [131.211.33.97])
	by max.phys.uu.nl (8.8.7/8.8.7/hjm) with ESMTP id RAA11952
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 17:50:25 +0100 (MET)
Received: from localhost (riel@localhost) by mirkwood.dummy.home (8.9.0/8.8.3) with ESMTP id RAA04258 for <linux-mm@kvack.org>; Thu, 7 Jan 1999 17:34:16 +0100
Date: Thu, 7 Jan 1999 17:34:15 +0100 (CET)
From: Rik van Riel <riel@humbolt.geo.uu.nl>
Subject: 2.2.0-pre5
Message-ID: <Pine.LNX.4.03.9901071730160.4197-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

while browsing the pre5 patch I saw quite a bit of
VM changes that made a lot of sense, but there was
one statement that really worried me (in vmscan.c)

+        * NOTE NOTE NOTE! This should just set a
+        * dirty bit in page_map, and just drop the
+        * pte. All the hard work would be done by
+        * shrink_mmap().
+        *
+        * That would get rid of a lot of problems.
+        */

Of course we should never do this since it would mean
we'd loose the benefit of clustered swapout (and
consequently clustered swapin).

The only way this could ever be implemented is by
using a linked list of things-to-swap-out that:
- is swapped out in the correct order and resorted
  if needs be (to preserve or actually improve the
  locality of reference in the swap area)
- can never be longer than X entries, to avoid ending
  up in all kinds of nasty situations

Rik -- If a Microsoft product fails, who do you sue?
+-------------------------------------------------------------------+
| Linux memory management tour guide.        riel@humbolt.geo.uu.nl |
| Scouting Vries cubscout leader.    http://humbolt.geo.uu.nl/~riel |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
