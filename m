Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA30622
	for <linux-mm@kvack.org>; Tue, 22 Dec 1998 11:27:59 -0500
Date: Tue, 22 Dec 1998 08:26:39 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <Pine.LNX.3.96.981222162525.8801A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.95.981222082256.8438C-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>



On Tue, 22 Dec 1998, Andrea Arcangeli wrote:
>
> On 22 Dec 1998, Eric W. Biederman wrote:
> 
> >My suggestion (again) would be to not call shrink_mmap in the swapper
> >(unless we are endangering atomic allocations).  And to never call
> >swap_out in the memory allocator (just wake up kswapd).
> 
> Ah, I just had your _same_ _exactly_ idea yesterday but there' s a good
> reason I nor proposed/tried it. The point are Real time tasks. kswapd is
> not realtime and a realtime task must be able to swapout a little by
> itself in try_to_free_pages() when there's nothing to free on the cache
> anymore. 

There's another one: if you never call shrink_mmap() in the swapper, the
swapper at least currently won't ever really know when it should finish.

> Linus's pre-4 seems to work well here though...

I'm still trying to integrate some of the stuff from Stephen in there: the
pre-4 contained some re-writes to shrink_mmap() to make Stephens
PG_referenced stuff cleaner, but it didn't yet take it into account for
"count", for example. The aim certainly is to have something clean that
essentially does what Stephen was trying to do. 

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
