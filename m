Date: Sat, 23 Feb 2008 15:27:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 01/18] Define functions for page cache handling
Message-Id: <20080223152716.51cc3875.akpm@linux-foundation.org>
In-Reply-To: <20080216004805.610589231@sgi.com>
References: <20080216004718.047808297@sgi.com>
	<20080216004805.610589231@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2008 16:47:19 -0800 Christoph Lameter <clameter@sgi.com> wrote:

> V2->V3:
> - Use "mapping" instead of "a" as the address space parameter
> 
> We use the macros PAGE_CACHE_SIZE PAGE_CACHE_SHIFT PAGE_CACHE_MASK
> and PAGE_CACHE_ALIGN in various places in the kernel. Many times
> common operations like calculating the offset or the index are coded
> using shifts and adds. This patch provides inline functions to
> get the calculations accomplished without having to explicitly
> shift and add constants.
> 
> All functions take an address_space pointer. The address space pointer
> will be used in the future to eventually support a variable size
> page cache. Information reachable via the mapping may then determine
> page size.
> 
> New function                    Related base page constant
> ====================================================================
> page_cache_shift(a)             PAGE_CACHE_SHIFT
> page_cache_size(a)              PAGE_CACHE_SIZE
> page_cache_mask(a)              PAGE_CACHE_MASK
> page_cache_index(a, pos)        Calculate page number from position
> page_cache_next(addr, pos)      Page number of next page
> page_cache_offset(a, pos)       Calculate offset into a page
> page_cache_pos(a, index, offset)
>                                 Form position based on page number
>                                 and an offset.

These sort-of look OK as cleanups and avoidance of accidents.

But the interfaces which they use (passing and address_space) are quite
pointless unless we implement variable page size per address_space.  And as
the chances of that ever happening seem pretty damn small, these changes
are just obfuscation which make the code harder to read and which
pointlessly churn the codebase.

So I'm inclined to drop these patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
