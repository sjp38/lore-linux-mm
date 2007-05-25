Date: Fri, 25 May 2007 06:54:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/6] Compound Page Enhancements
In-Reply-To: <20070524230032.554be39e.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705250642350.5199@schroedinger.engr.sgi.com>
References: <20070525051716.030494061@sgi.com> <20070524230032.554be39e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Andrew Morton wrote:

> Well I've read that, and I've read the patches and I still don't see what
> the point in all this is.

A. vmstat can handle compound pages. No need to determine the size
   of a compound page to update VM statistics.

B. PageCompound is not useful in the long run. The processing of compound
   pages in the VM requires the knowledge if this is a head or tail page. That a 
   page is part of a compound page is not that useful knowlege.

C. Provide some more support for higher order page handling issues that
   Mel and I encounter.

D. Compound pages may be useful to handle higher order blocks on the 
   freelists if they can be handled efficiently. If we use the same 
   format for the freelist as for compound pages elsewhere then we will 
   have a common set of function to determine sizes etc etc.

E. Expands usefulness of get_page_unless_zero to compound pages. This
   is necessary to allow the moving of slabs and the moving of higher
   order pages for memory defragmentation.
 
F. Lays groundwork for large blocksize support.

> And looking back on it, I don't see the point in that PG_head_tail_mask
> hack either.  We could have done
> 
> static inline int page_tail(struct page *page)
> {
> 	return PageCompound(page) && (page->first_page != page);
> }
> 
> Confused.  Don't know where this is all headed.

To a better nicer looking VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
