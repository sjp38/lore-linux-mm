Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA32678
	for <linux-mm@kvack.org>; Tue, 22 Dec 1998 17:35:06 -0500
Date: Tue, 22 Dec 1998 23:35:14 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <Pine.LNX.4.03.9812222107211.397-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.96.981222233250.377B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Dec 1998, Rik van Riel wrote:

>- kswapd should make sure that there is enough on the cache
>  (we should keep track of how many 1-count cache pages there
>  are in the system)
>- realtime tasks shouldn't go around allocating huge amounts
>  of memory -- this totally ruins the realtime aspect anyway

What about if there is netscape iconized and the realtime task want to
allocate some memory to mlock it but has to swapout netscape to do that?

>> (and this will avoid also tasks other than kswapd to
>> sleep waiting for slowww SYNC IO). 
>
>Some tasks (really big memory hogs) are better left sleeping
>for I/O because they otherwise completely overpower the rest
>of the system. But that's a slightly different story :)

The point here is that `free` get blocked on I/O because the malicious
process is trashing VM. 

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
