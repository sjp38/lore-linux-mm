Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id DAA10690
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 03:05:30 -0500
Subject: Re: [PATCH] MM fix & improvement
References: <Pine.LNX.3.95.990108235255.4363A-100000@penguin.transmeta.com>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 09 Jan 1999 09:05:16 +0100
In-Reply-To: Linus Torvalds's message of "Fri, 8 Jan 1999 23:53:38 -0800 (PST)"
Message-ID: <87g19k50sj.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> writes:

> On 9 Jan 1999, Zlatko Calusic wrote:
> >
> > OK, here it goes. Patch is unbelievably small, and improvement is
> > BIG.
> 
> Looks good. Especially the fact that once again performance got a lot
> better by _removing_ some silly heuristics that didn't actually work.
> 

Yes, that's the thing that I like with changes, too.
Let's remove anything that can be removed. :)

I'm just looking into buffer reference issue you mentioned.

I already noticed that part of code that was dealing with buffer
reference in shrink_mmap() disappeared some time ago. But I didn't
have a slightest clue that fs/buffer.c survived such mass deletia, as
one I just found in there. :)

I'll implement simple buffer->page reference functionality, benchmark
it and let you know what I've found.

At this point, I think it will improve things, but let's wait and see.

Regards,
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
