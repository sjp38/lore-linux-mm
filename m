Date: Sat, 6 Oct 2007 18:43:04 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 1/7] swapin_readahead: excise NUMA bogosity
Message-ID: <20071006184304.0561e77e@bree.surriel.com>
In-Reply-To: <Pine.LNX.4.64.0710062136070.16223@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0710062136070.16223@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Oct 2007 21:38:52 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:

> For three years swapin_readahead has been cluttered with fanciful
> CONFIG_NUMA code, advancing addr, and stepping on to the next vma
> at the boundary, to line up the mempolicy for each page allocation.
> 
> It _might_ be a good idea to allocate swap more according to vma
> layout; but the fact is, that's not how we do it at all,

Indeed, it looks as if the swapin_readahead() that is upstream
at the moment was rewritten by somebody who never understood
what the original code did.

Lets rip that junk out.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
