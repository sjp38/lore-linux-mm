Received: from toomuch.toronto.redhat.com (toomuch.toronto.redhat.com [172.16.14.22])
	by lacrosse.corp.redhat.com (8.9.3/8.9.3) with ESMTP id WAA11278
	for <linux-mm@kvack.org>; Sun, 8 Jul 2001 22:45:05 -0400
Date: Thu, 5 Jul 2001 19:38:07 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Large PAGE_SIZE
In-Reply-To: <Pine.LNX.4.33.0107050957010.22305-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0107051911130.2904-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: <linux-mm@kvack.org>
ReSent-Message-ID: <Pine.LNX.4.33.0107082243510.30164@toomuch.toronto.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ben LaHaise <bcrl@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Jul 2001, Linus Torvalds wrote:
> 
> Also note that the I/O _would_ happen in PAGE_CACHE_SIZE - you'd never
> break it into smaller chunks. That's the whole point of having a bigger
> PAGE_CACHE_SIZE.

Aha, are you saying that a part of the multipage PAGE_CACHE_SIZE project
is to go through the block layer and driver layer, changing appropriate
"PAGE_SIZE"s to "PAGE_CACHE_SIZE"s (whereas at present PAGE_CACHE_SIZE
is pretty much confined to the FS layer), so that the I/O isn't split?

If so, then yes indeed, the two approaches seem two sides of same coin:
I'd be changing one set of PAGE_SIZEs to VM_PAGE_SIZEs, while Ben would
be changing many of the others to PAGE_CACHE_SIZEs!  We'd differ at the
the user space level, but it might not amount to much (already we're both
filling multiple ptes on one fault).  I couldn't see what was going to
happen to the swap cache, if the anon pages were small but the cache size
large; but maybe swap readahead would dissolve our differences there too.

If not, please clarify.

> I'd really like both of you to think about both of the approaches as the
> same thing, but with different mindsets. Maybe there is something that
> clearly makes one mindset better. And maybe there is some way to just make
> the two be completely equivalent..

Yes, certainly I went about it in the only way I safely could, coming
from a VM background; someone with greater FS or I/O experience might
approach it differently.

It may come down to Ben having 2**N more struct pages than I do:
greater flexibility, but significant waste of kernel virtual.

I want to ponder the points in your mail: I'm a slow thinker and this
isn't intended as a reply, but I wanted to clarify PAGE_CACHE_SIZE I/O.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
