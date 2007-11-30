Date: Thu, 29 Nov 2007 18:45:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix kmem_cache_free performance regression in slab
Message-Id: <20071129184539.ba6342b8.akpm@linux-foundation.org>
In-Reply-To: <20071129190513.GD2584@parisc-linux.org>
References: <20071129190513.GD2584@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Nov 2007 12:05:13 -0700 Matthew Wilcox <matthew@wil.cx> wrote:

> The database performance group have found that half the cycles spent
> in kmem_cache_free are spent in this one call to BUG_ON.  Moving it
> into the CONFIG_SLAB_DEBUG-only function cache_free_debugcheck() is a
> performance win of almost 0.5% on their particular benchmark.
> 
> The call was added as part of commit ddc2e812d592457747c4367fb73edcaa8e1e49ff
> with the comment that "overhead should be minimal".  It may have been
> minimal at the time, but it isn't now.
> 

It is worth noting that the offending commit hit mainline in June 2006.

It takes a very long time for some performance regressions to be
discovered.  By which time it is effectively too late to fix it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
