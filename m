Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA04580
	for <linux-mm@kvack.org>; Mon, 16 Nov 1998 13:41:14 -0500
Date: Mon, 16 Nov 1998 15:27:28 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: useless report -- perhaps memory allocation problems in 2.1.12[678]
In-Reply-To: <199811131746.LAA23512@mail.mankato.msus.edu>
Message-ID: <Pine.LNX.3.96.981116152322.20349E-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jeffrey Hundstad <jeffrey.hundstad@mankato.msus.edu>
Cc: Linux MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Nov 1998, Jeffrey Hundstad wrote:

> When I was recompiling gimp, with tkRat, and Netscape running it felt
> like the machine was running out of ram. (I've got 128m of ram 128m of

> happens on 2.1.125.  Something has changed for the worse, but it does
> FEEL peppier at the keyboard ;-)

In 2.1.127+ the freeing of memory is done in the context of
programs themselves too and the whole system is busy freeing
memory. This means that the kswapd-loop has now been migrated
into other contexts as well. This, together with the fact that
kswapd never blocks on disk access any more, has caused serious
trouble when a system runs out of memory.

I guess this means I'll have to update and clean my out
of memory killer patch really soon now... :(

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
