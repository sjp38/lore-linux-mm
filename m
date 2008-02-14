Received: by wr-out-0506.google.com with SMTP id 60so518796wri.8
        for <linux-mm@kvack.org>; Thu, 14 Feb 2008 00:56:13 -0800 (PST)
Message-ID: <84144f020802140056i6706f135s77473534e0b6fc0b@mail.gmail.com>
Date: Thu, 14 Feb 2008 10:56:12 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 2/5] slub: Fallback to kmalloc_large for failing higher order allocs
In-Reply-To: <20080214040313.616551392@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080214040245.915842795@sgi.com>
	 <20080214040313.616551392@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Sorry for the duplicate. My email client started trimming cc's...]

On Thu, Feb 14, 2008 at 6:02 AM, Christoph Lameter <clameter@sgi.com> wrote:
> Slub already has two ways of allocating an object. One is via its own
>  logic and the other is via the call to kmalloc_large to hand of object
>  allocation to the page allocator. kmalloc_large is typically used
>  for objects >= PAGE_SIZE.
>
>  We can use that handoff to avoid failing if a higher order kmalloc slab
>  allocation cannot be satisfied by the page allocator. If we reach the
>  out of memory path then simply try a kmalloc_large(). kfree() can
>  already handle the case of an object that was allocated via the page
>  allocator and so this will work just fine (apart from object
>  accounting...).

Sorry, I didn't follow the discussion close enough. Why are we doing
this? Is it fixing some real bug I am not aware of?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
