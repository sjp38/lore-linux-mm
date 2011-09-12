Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DE6066B020E
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 05:34:39 -0400 (EDT)
Date: Mon, 12 Sep 2011 10:34:34 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/10] mm: Add support for a filesystem to control swap
 files
Message-ID: <20110912093058.GA3207@suse.de>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
 <1315566054-17209-4-git-send-email-mgorman@suse.de>
 <20110909130007.GA11810@infradead.org>
 <20110909131550.GV14369@suse.de>
 <20110909133611.GB8155@infradead.org>
 <1315818285.26517.18.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1315818285.26517.18.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Hellwig <hch@infradead.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>

On Mon, Sep 12, 2011 at 11:04:45AM +0200, Peter Zijlstra wrote:
> On Fri, 2011-09-09 at 09:36 -0400, Christoph Hellwig wrote:
> > The equivalent of ->direct_IO should be used for both reads and writes.
> 
> So the difference between DIO and swapIO is that swapIO needs the block
> map pinned in memory.. So at the very least you'll need those
> swap_{activate,deactivate} aops. The read/write-page thingies could
> indeed be shared with DIO.
> 

I'm travelling at the moment so it'll be later in the week when I investigate
properly but I agree swap_[de|a]ctivate are still necessary. NFS does not
need to pin a block map but it's still necessary for calling xs_set_memalloc.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
