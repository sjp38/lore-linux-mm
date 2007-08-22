Date: Wed, 22 Aug 2007 18:54:24 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 8/9] pagemap: use page walker pte_hole() helper
Message-ID: <20070822235424.GQ30556@waste.org>
References: <20070822231804.1132556D@kernel> <20070822231813.B52D1961@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070822231813.B52D1961@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 22, 2007 at 04:18:13PM -0700, Dave Hansen wrote:
> 
> I tried to do this a bit more incrementally, but it ended
> up just looking like an even worse mess.  So, this does
> a a couple of different things.
> 
> 1. use page walker pte_hole() helper, which
> 2. gets rid of the "next" value in "struct pagemapread"
> 3. allow 1-3 byte reads from pagemap.  This at least
>    ensures that we don't write over user memory if they
>    ask us for 1 bytes and we tried to write 4.
> 4. Instead of trying to calculate what ranges of pages
>    we are going to walk, simply start walking them,
>    then return PAGEMAP_END_OF_BUFFER at the end of the
>    buffer, error out, and stop walking.
> 5. enforce that reads must be algined to PM_ENTRY_BYTES
> 
> Note that, despite these functional additions, and some
> nice new comments, this patch still removes more code
> than it adds.
> 
> Signed-off-by: Dave Hansen <haveblue@us.ibm.com>

> +	if (pm->count >= PM_ENTRY_BYTES)
> +		__put_user(pfn pm->out);

I suppose I should have mentioned this typo when I spotted it
yesterday.. Will fix it on my end.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
