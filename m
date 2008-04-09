Date: Tue, 8 Apr 2008 19:47:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 0/6] compcache: Compressed Caching
Message-Id: <20080408194740.1219e8b8.akpm@linux-foundation.org>
In-Reply-To: <200803210129.59299.nitingupta910@gmail.com>
References: <200803210129.59299.nitingupta910@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nitingupta910@gmail.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Mar 2008 01:29:58 +0530 Nitin Gupta <nitingupta910@gmail.com> wrote:

> Subject: [RFC][PATCH 0/6] compcache: Compressed Caching

Didn't get many C's, did it?

Be sure to cc linux-kernel on the next version.

> Hi All,
> 
> This implements a RAM based block device which acts as swap disk.
> Pages swapped to this disk are compressed and stored in memory itself.
> This allows more applications to fit in given amount of memory. This is
> especially useful for embedded devices, OLPC and small desktops
> (aka virtual machines).
> 
> Project home: http://code.google.com/p/compcache/
> 
> It consists of following components:
> - compcache.ko: Creates RAM based block device
> - tlsf.ko: Two Level Segregate Fit (TLSF) allocator
> - LZO de/compressor: (Already in mainline)
> 
> Project home contains some performance numbers for TLSF and LZO.
> For general desktop use, this is giving *significant* performance gain
> under memory pressure. For now, it has been tested only on x86.

The values of "*significant*" should be exhaustively documented in the
patch changelogs. That is 100%-the-entire-whole-point of the patchset!
Omitting that information tends to reduce the number of C's.

Please feed all diffs through scripts/checkpatch.pl, contemplate the
result.

kmap_atomic() is (much) preferred over kmap().

flush_dcache_page() is needed after the CPU modifies pagecache or anon page
by hand (generally linked to kmap[_atomic]()).

The changelogs should include *complete* justification for the introduction
of a new allocator.  What problem is it solving, what are the possible
solutions to that problem, why this one was chosen, etc.  It's a fairly big
deal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
