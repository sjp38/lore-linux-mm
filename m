Received: by wa-out-1112.google.com with SMTP id m33so1776728wag.8
        for <linux-mm@kvack.org>; Tue, 08 Apr 2008 22:02:06 -0700 (PDT)
Message-ID: <4cefeab80804082202ub29fad6m2bb2337cbea6ed97@mail.gmail.com>
Date: Wed, 9 Apr 2008 10:32:06 +0530
From: "Nitin Gupta" <nitingupta910@gmail.com>
Subject: Re: [RFC][PATCH 0/6] compcache: Compressed Caching
In-Reply-To: <20080408194740.1219e8b8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200803210129.59299.nitingupta910@gmail.com>
	 <20080408194740.1219e8b8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 9, 2008 at 8:17 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 21 Mar 2008 01:29:58 +0530 Nitin Gupta <nitingupta910@gmail.com> wrote:
>
>  > Subject: [RFC][PATCH 0/6] compcache: Compressed Caching
>
>  Didn't get many C's, did it?
>
>  Be sure to cc linux-kernel on the next version.
>
>

I have already posted it again on linux-kernel with link to
performance figures for allocator (TLSF vs SLUB):

see: http://lkml.org/lkml/2008/4/8/69


>  > Project home contains some performance numbers for TLSF and LZO.
>  > For general desktop use, this is giving *significant* performance gain
>  > under memory pressure. For now, it has been tested only on x86.
>
>  The values of "*significant*" should be exhaustively documented in the
>  patch changelogs. That is 100%-the-entire-whole-point of the patchset!
>  Omitting that information tends to reduce the number of C's.
>

I will also post performance numbers for compcache.
Desktop seems so much more responsive with this. I need to see how I
can quantify this.


>  Please feed all diffs through scripts/checkpatch.pl, contemplate the
>  result.
>
>  kmap_atomic() is (much) preferred over kmap().
>

We are doing compression and alloc (can sleep) between kmap/kunmap.
So, I used kmap() instead of kmap_atomic().



>  flush_dcache_page() is needed after the CPU modifies pagecache or anon page
>  by hand (generally linked to kmap[_atomic]()).
>

ok. I will add this.


>  The changelogs should include *complete* justification for the introduction
>  of a new allocator.  What problem is it solving, what are the possible
>  solutions to that problem, why this one was chosen, etc.  It's a fairly big
>  deal.
>

TLSF comparison with SLUB can be found here:

http://code.google.com/p/compcache/wiki/AllocatorsComparison


Thanks for review.

Regards,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
