Received: by wa-out-1112.google.com with SMTP id m33so2403497wag
        for <linux-mm@kvack.org>; Mon, 18 Jun 2007 13:11:59 -0700 (PDT)
Message-ID: <84144f020706181311u2bb10658i3869f7aeb8e29f8e@mail.gmail.com>
Date: Mon, 18 Jun 2007 23:11:59 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 04/26] Slab allocators: Support __GFP_ZERO in all allocators.
In-Reply-To: <20070618095914.332369986@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070618095838.238615343@sgi.com>
	 <20070618095914.332369986@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "clameter@sgi.com" <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On 6/18/07, clameter@sgi.com <clameter@sgi.com> wrote:
> A kernel convention for many allocators is that if __GFP_ZERO is passed to
> an allocator then the allocated memory should be zeroed.
>
> This is currently not supported by the slab allocators. The inconsistency
> makes it difficult to implement in derived allocators such as in the uncached
> allocator and the pool allocators.

[snip]

> So add the necessary logic to all slab allocators to support __GFP_ZERO.

Looks good to me.

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
