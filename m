Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA12872
	for <linux-mm@kvack.org>; Tue, 17 Nov 1998 18:01:10 -0500
Date: Tue, 17 Nov 1998 21:18:39 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: useless report -- perhaps memory allocation problems in 2.1.12[678]
In-Reply-To: <199811171121.LAA00897@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981117211632.12547C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Jeffrey Hundstad <jeffrey.hundstad@mankato.msus.edu>, Linux MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Nov 1998, Stephen C. Tweedie wrote:
> Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:
> 
> > and the whole system is busy freeing memory. This means that the
> > kswapd-loop has now been migrated into other contexts as well. This,
> > together with the fact that kswapd never blocks on disk access any
> > more,
> 
> Yes it does.  We don't pass GFP_WAIT to swap_out(), but that just
> means that the swapout will be done asynchronously.  We are still
> free to write stuff out to swap, and in fact once we hit the limit
> on outstanding IOs we may well block in the write. 

Whoops, I saw that run_task_queue(&tq_disk) had dissapeared
from it's original position but I couldn't find it in it's
new place... /usr/bin/grep has been a real help now you pointed
it out, thanks to you both :)

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
