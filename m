Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA17072
	for <linux-mm@kvack.org>; Wed, 26 May 1999 13:44:43 -0400
Date: Wed, 26 May 1999 10:44:02 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] cache large files in the page cache
In-Reply-To: <19990526094407.J527@mff.cuni.cz>
Message-ID: <Pine.LNX.3.95.990526104127.14018K-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jakub Jelinek <jj@sunsite.ms.mff.cuni.cz>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 26 May 1999, Jakub Jelinek wrote:
> 
> I have minor suggestion to the patch. Instead of using vm_index <<
> PAGE_SHIFT and page->key << PAGE_CACHE_SHIFT shifts either choose different
> constant names for this shifting (VM_INDEX_SHIFT and PAGE_KEY_SHIFT) or hide
> these shifts by some pretty macros (you'll need two for each for both
> directions in that case - if you go the macro way, maybe it would be a good
> idea to make vm_index and key type some structure with a single member like
> mm_segment_t for more strict typechecking).

Indeed. An dI would suggest that the shift be limited to at most 9 anyway:
right now I applied the part that disallows non-page-aligned offsets, but
I think that we may in the future allow anonymous mappings again at finer
granularity (somebody made a really good argument about wine for this).

Thinking that the VM mapping shift has to be the same as the page shift is
not necessarily the right thing. With just 9 bits of shift, you still get
large files - 41 bits of files on a 32-bit architecture, and by the time
you want more you _really_ can say that you had better upgrade your CPU. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
