Date: Wed, 3 Nov 1999 21:24:17 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: Why don't we make mmap MAP_SHARED with /dev/zero possible?
In-Reply-To: <m1bt9bv10u.fsf@flinx.hidden>
Message-ID: <Pine.LNX.4.10.9911032119450.8864-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Christoph Rohland <hans-christoph.rohland@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, fxzhang@chpc.ict.ac.cn, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 3 Nov 1999, Eric W. Biederman wrote:

> Q: Highmem allocation for the page cache.
> 
> Note:  page_cache_alloc currently doesn't take any parameters.
> It should take __GFP_BIGMEM or whatever so we can yes high memory is ok.

it's now an unconditional __GFP_HIGHMEM in my tree. HIGHMEM gfp()
allocation automatically falls back to allocate in lowmem, if highmem
lists are empty.

> Or no.  
> I'm going to put metadata in this page and high memory is not o.k, too
> inconvienint.

hm, i see, this makes sense. permanent mappings are not inconvenient at
all (you can hold a number of them, can sleep inbetween), but maybe we
still want to allocate in low memory in some cases, for performance
reasons. It's not a problem at all and completely legal, as low memory
pages can happen anyway, so everything is completely symmetric. Any 'high
memory enabled code' automatically works with low memory (or exclusive low
memory) as well.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
