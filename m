Subject: Re: [PATCH] [6/13] Core maskable allocator 
From: corbet@lwn.net (Jonathan Corbet)
In-reply-to: Your message of "Fri, 07 Mar 2008 10:07:16 +0100."
             <20080307090716.9D3E91B419C@basil.firstfloor.org>
Date: Tue, 11 Mar 2008 09:34:53 -0600
Message-ID: <26256.1205249693@vena.lwn.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Andi,

As I dig through this patch, I find it mostly makes sense; seems like it
could be a good idea.  I did have one little API question...

> +struct page *
> +alloc_pages_mask(gfp_t gfp, unsigned size, u64 mask)
> +{
> +	unsigned long max_pfn = mask >> PAGE_SHIFT;

The "mask" parameter isn't really a mask - it's an upper bound on the
address of the allocated memory.  Might it be better to call it
"max_addr" or "limit" or "ceiling" or some such so callers understand
for sure how it's interpreted?  The use of the term "mask" throughout
the interface could maybe create a certain amount of confusion.

Thanks,

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
