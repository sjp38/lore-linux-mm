Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA19088
	for <linux-mm@kvack.org>; Sun, 29 Nov 1998 20:12:48 -0500
Date: Mon, 30 Nov 1998 21:20:24 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
In-Reply-To: <871zmldxkd.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.96.981130211102.498J-100000@dragon.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Benjamin Redelings I <bredelin@ucsd.edu>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 30 Nov 1998, Zlatko Calusic wrote:

>One other idea I had, was to replace (code at the very beginning of

Hey guy, this idea is mine from ages! ;-)

>do_try_to_free_page()):
>
>	if (buffer_over_borrow() || pgcache_over_borrow())
>		shrink_mmap(i, gfp_mask);
>
>with:
>
>	if (buffer_over_borrow() || pgcache_over_borrow())
>		state = 0;

This should be the thing that fixed the problem fine for people (or at
least arca-39 fixed it ;). Now I have perfect reports of the arca-39 mm
from the guys that sent the mm bug report to linux-kernel. I guess the
only interesting thing in my patch for this issue is my change you
mentioned above (and that I am using from a lot of time, and since I
started hacking the mm myself I never had mm problems anymore btw ;). With
the patch above Stephen' s patch is not needed, I don' t know if it can be
still helpful though (since I have not read it in details yet). 

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
