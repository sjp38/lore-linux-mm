Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA08263
	for <linux-mm@kvack.org>; Mon, 2 Mar 1998 20:51:09 -0500
Date: Tue, 3 Mar 1998 02:50:43 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: new kswapd logic
In-Reply-To: <Pine.LNX.3.95.980302174213.20458K-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.91.980303024609.9042A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Mar 1998, Linus Torvalds wrote:
> On Tue, 3 Mar 1998, Rik van Riel wrote:
> > 
> > with my new free_memory_available() patch, it
> > should be possible to put in my kswapd logic
> > patch again.
> 
> Actually, I really think that the _correct_ fix is to make kswapd be a
> very low-priority process that works in the background, rather than be a
> very high-priority process that works in the foreground. 

There's no problem with kswapd being high-priority...
It just shouldn't run for very long periods. We should:
- limit the amount of pages it can try to free
- make sure that it tries more and more as memory becomes
  more and more scarce
- make sure that kswapd doesn't hog resources when it isn't
  neccesary

The first two issues are solved with my patch (have any
of you guys tried it?) and the last one is only partly
adressed.

I will be studying this 'problem' RSN... Maybe kswapd
should limit itself to x% of CPU by keeping it's CPU
statistics around?
(ie. don't use more than 5% CPU over the last 30 seconds,
if memory is still absurdly low, and there's free swap,
just page out _everything_. If there's no free swap and
the page cache is minimal, we need to kill some program)

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
