Date: Tue, 15 Apr 2008 02:02:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Smarter retry of costly-order allocations
Message-Id: <20080415020220.0a6998e2.akpm@linux-foundation.org>
In-Reply-To: <20080415085154.GA20316@csn.ul.ie>
References: <20080411233500.GA19078@us.ibm.com>
	<20080411233553.GB19078@us.ibm.com>
	<20080415085154.GA20316@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, clameter@sgi.com, apw@shadowen.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Apr 2008 09:51:55 +0100 Mel Gorman <mel@csn.ul.ie> wrote:

> On (11/04/08 16:35), Nishanth Aravamudan didst pronounce:
> > Because of page order checks in __alloc_pages(), hugepage (and similarly
> > large order) allocations will not retry unless explicitly marked
> > __GFP_REPEAT. However, the current retry logic is nearly an infinite
> > loop (or until reclaim does no progress whatsoever). For these costly
> > allocations, that seems like overkill and could potentially never
> > terminate.
> > 
> > Modify try_to_free_pages() to indicate how many pages were reclaimed.
> > Use that information in __alloc_pages() to eventually fail a large
> > __GFP_REPEAT allocation when we've reclaimed an order of pages equal to
> > or greater than the allocation's order. This relies on lumpy reclaim
> > functioning as advertised. Due to fragmentation, lumpy reclaim may not
> > be able to free up the order needed in one invocation, so multiple
> > iterations may be requred. In other words, the more fragmented memory
> > is, the more retry attempts __GFP_REPEAT will make (particularly for
> > higher order allocations).
> > 
> > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> Changelog is a lot clearer now. Thanks.
> 
> Tested-by: Mel Gorman <mel@csn.ul.ie>

Tested in what way though?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
