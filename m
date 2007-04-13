Date: Fri, 13 Apr 2007 21:08:15 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: madvise avoid exclusive mmap_sem
In-Reply-To: <20070413115719.2bdf5705.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704132101300.14508@blonde.wat.veritas.com>
References: <20070412005638.GA25469@wotan.suse.de>
 <20070413115719.2bdf5705.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Apr 2007, Andrew Morton wrote:
> On Thu, 12 Apr 2007 02:56:38 +0200
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > Avoid down_write of the mmap_sem in madvise when we can help it.
> 
> Are we sure that running zap_page_range() under down_read() is safe?
> For hugepage regions too?

madvise_dontneed just says -EINVAL on a VM_HUGETLB vma, so I didn't
check the hugepage case further, it doesn't reach the zap_page_range.

We can indeed be sure that running zap_page_range on a normal vma
is safe under down_read (as opposed to the down_write there before),
because file truncation runs it without taking mmap_sem at all.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
