Subject: Re: Why don't we make mmap MAP_SHARED with /dev/zero possible?
References: <Pine.LNX.4.10.9911031736450.7408-100000@chiara.csoma.elte.hu>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 03 Nov 1999 13:16:33 -0600
Message-ID: <m1bt9bv10u.fsf@flinx.hidden>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Christoph Rohland <hans-christoph.rohland@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, fxzhang@chpc.ict.ac.cn, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

[snip]

Q: Highmem allocation for the page cache.

Note:  page_cache_alloc currently doesn't take any parameters.
It should take __GFP_BIGMEM or whatever so we can yes high memory is ok.
Or no.  
I'm going to put metadata in this page and high memory is not o.k, too inconvienint.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
