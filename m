Received: by wx-out-0506.google.com with SMTP id h31so288672wxd.11
        for <linux-mm@kvack.org>; Thu, 14 Feb 2008 00:55:01 -0800 (PST)
Message-ID: <84144f020802140055v62b89602p66aebeb65ab85c35@mail.gmail.com>
Date: Thu, 14 Feb 2008 10:55:00 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 5/5] slub: Large allocs for other slab sizes that do not fit in order 0
In-Reply-To: <20080214040314.388752493@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080214040245.915842795@sgi.com>
	 <20080214040314.388752493@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Sorry for the duplicate. My email client started trimming cc's...]

On Thu, Feb 14, 2008 at 6:02 AM, Christoph Lameter <clameter@sgi.com> wrote:
> Expand the scheme used for kmalloc-2048 and kmalloc-4096 to all slab
>  caches. That means that kmem_cache_free() must now be able to handle
>  a fallback object that was allocated from the page allocator. This is
>  touching the fastpath costing us 1/2 % of performance (pretty small
>  so within variance). Kind of hacky though.

Looks good but are there any numbers that indicate this is an overall win?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
