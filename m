Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA15022
	for <linux-mm@kvack.org>; Thu, 9 Jul 1998 17:18:30 -0400
Date: Thu, 9 Jul 1998 21:55:57 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: everyone who has VM problems/messages (writable swappage or crash or lockup)
In-Reply-To: <Pine.GSO.3.96.980709162723.29328B-100000@valerie.inf.elte.hu>
Message-ID: <Pine.LNX.3.96.980709215250.28236H-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: MOLNAR Ingo <mingo@valerie.inf.elte.hu>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Jul 1998, MOLNAR Ingo wrote:

> [actually i saw problems because we still do not handle the 'out of swap'
> case very gracefully, but thats another issue. Also, the ramdisk test does
> not (yet) fully simulate a real disk.]

Part of the code to handle that is on my homepage,
but as I haven't worked out how to decide when to
start this code I haven't made a patch yet...

If you are interested, could you please look into
it? (my time is now completely consumed by reviewing
the zone allocator's design, a week camp with our
Scouts group and finetuning the VM system for 2.2)

If anyone else is reading this, could you please
think about how this task is accomplished and work
something out together? (I'll be away from sunday
12th until saterday the 19th)

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
