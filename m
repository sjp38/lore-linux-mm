Date: Fri, 5 Jul 2002 21:45:25 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: vm lock contention reduction
In-Reply-To: <Pine.LNX.4.44.0207051727300.1052-100000@home.transmeta.com>
Message-ID: <Pine.LNX.4.44L.0207052142570.8346-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrew Morton <akpm@zip.com.au>, William Lee Irwin III <wli@holomorphy.com>, Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jul 2002, Linus Torvalds wrote:
> On Fri, 5 Jul 2002, Rik van Riel wrote:
> >
> > But it is, mmap() and anonymous memory don't trigger writeback.
>
> I don't think we can fix that, without going back to the approach of
> marking any writable memory as read-only and counting it at page-fault
> time.

I don't think we have to fix it, as long as the
shrink_caches/page_launder function is well
balanced and throttling is done intelligently.

> Wasn't it you who did that test-patch originally?

I don't remember who did it, so I suspect it wasn't me.
Could it be Ben ?

> There might be some way to avoid the page fault badness (the large page
> stuff will do this automatically, for example), which might make the
> "let's keep track of dirty mappings explicitly" approach acceptable
> again.

That's another approach, I guess it'll be worth looking
into both (and searching the web for what other people
have done before us with both ;))

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
