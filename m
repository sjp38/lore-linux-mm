Date: Sat, 11 Dec 2004 00:44:38 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: page fault scalability patch V12 [0/7]: Overview and performance
    tests
In-Reply-To: <20041210161835.5b0b0828.akpm@osdl.org>
Message-ID: <Pine.LNX.4.44.0412110036330.807-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: clameter@sgi.com, torvalds@osdl.org, benh@kernel.crashing.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Dec 2004, Andrew Morton wrote:
> Hugh Dickins <hugh@veritas.com> wrote:
> > But why is do_anonymous_page adding anything to lru_cache_add_active,
> > when its other callers leave it at that?  What's special about the
> > do_anonymous_page case?
> 
> do_swap_page() is effectively doing the same as do_anonymous_page(). 
> do_wp_page() and do_no_page() appear to be errant.

Demur.  do_swap_page has to mark_page_accessed because the page from
the swap cache is already on the LRU, and for who knows how long.
The others (and count in fs/exec.c's install_arg_page) are dealing
with a freshly allocated page they are putting onto the active LRU.

My inclination would be simply to remove the mark_page_accessed
from do_anonymous_page; but I have no numbers to back that hunch.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
