Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA13026
	for <linux-mm@kvack.org>; Tue, 17 Nov 1998 18:14:58 -0500
Date: Tue, 17 Nov 1998 15:14:10 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: useless report -- perhaps memory allocation problems in 2.1.12[678]
In-Reply-To: <Pine.LNX.3.96.981117211632.12547C-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.981117151133.1077O-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Jeffrey Hundstad <jeffrey.hundstad@mankato.msus.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Tue, 17 Nov 1998, Rik van Riel wrote:
> 
> Whoops, I saw that run_task_queue(&tq_disk) had dissapeared
> from it's original position but I couldn't find it in it's
> new place... /usr/bin/grep has been a real help now you pointed
> it out, thanks to you both :)

I think it should be in the original position (inside the kswapd loop), I
think removing it was probably a mistake. I prefer Stephens test there
rather than in page_io (setting "wait" in page_io.c has more ramifications
than just getting the IO started, I'm not sure we really actually want to
wait on the page). 

Hmm.. I could go either way on this. Arguments from all sides?

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
