Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA05168
	for <linux-mm@kvack.org>; Thu, 3 Dec 1998 08:31:41 -0500
Received: from mirkwood.dummy.home (root@anx1p4.phys.uu.nl [131.211.33.93])
	by max.phys.uu.nl (8.8.7/8.8.7/hjm) with ESMTP id OAA04866
	for <linux-mm@kvack.org>; Thu, 3 Dec 1998 14:06:38 +0100 (MET)
Received: from localhost (riel@localhost) by mirkwood.dummy.home (8.9.0/8.8.3) with SMTP id MAA01530 for <linux-mm@kvack.org>; Thu, 3 Dec 1998 12:19:47 +0100
Date: Thu, 3 Dec 1998 12:19:44 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: swapin readahead v4 -- first tests
Message-ID: <Pine.LNX.3.96.981203121615.1008A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I've done some quick tests with v4 of my swapin readahead
patch and the system seems to have stopped loosing memory.

I've been too lazy to test Zlatko's test proggie, but Gimp
with some large images frees all memory correctly so I assume
that things are working properly (there was quite a bit in
swap and it was freed correctly).

I'd really like a few comments on the patch, especially from
Stephen -- who is the expert on the swap cache code. I've
decided to stay out of bed, despite the flu, because I will
need to refill my energy reserves and I simply eat better when
out of bed :)

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
