Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA21565
	for <linux-mm@kvack.org>; Sat, 5 Dec 1998 21:01:14 -0500
Date: Sun, 6 Dec 1998 02:59:57 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] VM improvements for 2.1.131
In-Reply-To: <m1hfva9g1y.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.96.981206025816.14437A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Linux MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On 5 Dec 1998, Eric W. Biederman wrote:
> >>>>> "RR" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:
> 
>  
> RR 	/* Don't allow too many pending pages in flight.. */
> RR-	if (atomic_read(&nr_async_pages) > SWAP_CLUSTER_MAX)
> RR+	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
> RR 		wait = 1;
> 
> How will this possibly work if we are using a swapfile 
> and we always swap synchronously?

It won't. But if you are using a swapfile you'll always
lose. Due to on-drive track buffers and head-locality it
won't be a real performance loss though... (I hope).

What we really need is somebody to fix swapfile I/O.

regards,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
