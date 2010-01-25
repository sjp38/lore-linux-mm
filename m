Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3936B0047
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 03:33:14 -0500 (EST)
Date: Mon, 25 Jan 2010 19:33:09 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2] xfs: use scalable vmap API
Message-ID: <20100125083309.GF19664@laptop>
References: <20081021082542.GA6974@wotan.suse.de>
 <20081021082735.GB6974@wotan.suse.de>
 <20081021120932.GB13348@infradead.org>
 <20081022093018.GD4359@wotan.suse.de>
 <20100119121505.GA9428@infradead.org>
 <20100125075445.GD19664@laptop>
 <20100125081750.GA20012@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100125081750.GA20012@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 25, 2010 at 03:17:50AM -0500, Christoph Hellwig wrote:
> On Mon, Jan 25, 2010 at 06:54:45PM +1100, Nick Piggin wrote:
> > Is this on a 32-bit system with small vmalloc area?
> 
> Yes.

OK, I would say it could easily be just due to fragmentation then.


> > When the vmap allocation fails, it would be good to basically see the
> > alloc_map and dirty_map for each of the vmap_blocks. This is going to be
> > a lot of information. Basically for all blocks with
> > free+dirty == VMAP_BBMAP_BITS are ones that could be released and you
> > could try the alloc again.
> 
> Any easy way to get them?  Sorry, not uptodate on your new vmalloc
> implementation anymore.

Let me try writing a few (tested) patches here first that I can send you.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
