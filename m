Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA08393
	for <linux-mm@kvack.org>; Thu, 26 Feb 1998 13:40:22 -0500
Date: Thu, 26 Feb 1998 10:39:41 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: kswapd logic improvement
In-Reply-To: <Pine.LNX.3.91.980226172956.1153A-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980226103551.18363C-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: linux-mm <linux-mm@kvack.org>, "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
List-ID: <linux-mm.kvack.org>



On Thu, 26 Feb 1998, Rik van Riel wrote:
> 
> here's another short patch for 2.1.88. Basically
> it improves the kswapd logic. Currently kswapd
> will give up when it fails three times in a row,
> even when it hasn't any memory yet.

Look at the pre-89's on ftp.kernel.org - I changed kswapd around quite a
bit, because I want the machine to remain up when you get lots of atomic
get_free_page() calls that would otherwise not even have woken up kswapd
depending on how "min_pages_free" was set up and what the fragmentation
was. 

I'm not saying that the pre-89 is any better, but it is sufficiently
different that I'd like to hear comments about it. I suspect it really
needs tweaking kswapd, for example - it might result in bad latency right
now because kswapd is so high-priority and if it isn't able to unfragment
easily it might run for a while.. 

Could you send patches relative to that (including your other patch, I'd
be happier to know that you've tested that patch against my current kernel
too),

		Linus
