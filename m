Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA30305
	for <linux-mm@kvack.org>; Mon, 7 Dec 1998 08:13:25 -0500
Date: Mon, 7 Dec 1998 14:04:04 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] VM improvements for 2.1.131
In-Reply-To: <98Dec7.104648gmt.66310@gateway.ukaea.org.uk>
Message-ID: <Pine.LNX.3.96.981207140223.23360K-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Neil Conway <nconway.list@ukaea.org.uk>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Dec 1998, Neil Conway wrote:

> Won't making the min_percent values (cache/buffers) equal to 1%
> wreck performance on small memory machines? 

No. When the caches are heavily used they will need to be
freed anyway since we need the space for new data to be
read in.

Besides, we swap_out() doesn't free any memory any more,
so we need to run shrink_mmap() regardless.

what we really need is somebody to try it out on 4M and
8M machines...

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
