Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA08215
	for <linux-mm@kvack.org>; Mon, 2 Mar 1998 20:44:43 -0500
Date: Mon, 2 Mar 1998 17:44:23 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: new kswapd logic
In-Reply-To: <Pine.LNX.3.91.980303005103.6201A-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980302174213.20458K-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Tue, 3 Mar 1998, Rik van Riel wrote:
> 
> with my new free_memory_available() patch, it
> should be possible to put in my kswapd logic
> patch again.

Actually, I really think that the _correct_ fix is to make kswapd be a
very low-priority process that works in the background, rather than be a
very high-priority process that works in the foreground. 

Then we'd have some _really_ low watermark that occasionally makes it a
high-priority process, but the point is that right now the whole problem
is brought around not so much because we're low on memory, but due to
simple stupidity with kswapd hogging the whole machine even though it
shouldn't..

			Linus
