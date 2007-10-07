Date: Mon, 8 Oct 2007 00:05:29 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 1/7] swapin_readahead: excise NUMA bogosity
Message-ID: <20071007220529.GA11816@bingen.suse.de>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com> <Pine.LNX.4.64.0710062136070.16223@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0710062136070.16223@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Oct 06, 2007 at 09:38:52PM +0100, Hugh Dickins wrote:
> For three years swapin_readahead has been cluttered with fanciful
> CONFIG_NUMA code, advancing addr, and stepping on to the next vma
> at the boundary, to line up the mempolicy for each page allocation.

Ok. I guess i was naive when I wrote that and didn't consider
how badly swap fragments.  It's ok to remove. I remember you complaining
about it some time ago, but somehow it never got changed.

In theory it could be fixed by migrating the page later,
but that would be somewhat more involved.

I suspect the real fix for this mess would be probably to never
swap in smaller than 1-2MB blocks of continuous memory and then don't 
do any readahead. That would likely fix the swap problems that were
discussed at KS too.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
