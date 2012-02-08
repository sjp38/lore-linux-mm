Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 57BD46B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 10:14:36 -0500 (EST)
Date: Wed, 8 Feb 2012 09:14:32 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 02/15] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
In-Reply-To: <20120208144506.GI5938@suse.de>
Message-ID: <alpine.DEB.2.00.1202080907320.30248@router.home>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de> <1328568978-17553-3-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1202071025050.30652@router.home> <20120208144506.GI5938@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 8 Feb 2012, Mel Gorman wrote:

> o struct kmem_cache_cpu could be left alone even though it's a small saving

Its multiplied by the number of caches and by the number of
processors.

> o struct slab also be left alone
> o struct array_cache could be left alone although I would point out that
>   it would make no difference in size as touched is changed to a bool to
>   fit pfmemalloc in

Both of these are performance critical structures in slab.

> o It would still be necessary to do the object pointer tricks in slab.c

These trick are not done for slub. It seems that they are not necessary?

> remain. However, the downside of requiring a page flag is very high. In
> the event we increase the number of page flags - great, I'll use one but
> right now I do not think the use of page flag is justified.

On 64 bit I think there is not much of an issue with another page flag.

Also consider that the slab allocators do not make full use of the other
page flags. We could overload one of the existing flags. I removed
slubs use of them last year. PG_active could be overloaded I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
