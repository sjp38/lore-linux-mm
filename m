Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2BE506B0047
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 12:12:28 -0500 (EST)
Date: Tue, 9 Mar 2010 11:11:55 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/3] page-allocator: Under memory pressure, wait on
 pressure to relieve instead of congestion
In-Reply-To: <20100309170123.GG4883@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1003091109040.28897@router.home>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie> <1268048904-19397-2-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1003090946180.28897@router.home> <4B966F93.9060207@linux.vnet.ibm.com> <alpine.DEB.2.00.1003091005310.28897@router.home>
 <20100309170123.GG4883@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Mar 2010, Mel Gorman wrote:

> Until it's timeout at least. It's still better than the current
> situation of sleeping on congestion.

Congestion may clear if memory becomes available in other zones.

> The ideal would be waiting on a per-node basis. I'm just not liking having
> to look up the node structure when freeing a patch of pages and making a
> cache line in there unnecessarily hot.

The node structure (pgdat) contains the zone structures. If you know the
type of zone then you can calculate the pgdat address.

> > But then an overallocated node may stall processes. If that node is full
> > of unreclaimable memory then the process may never wake up?
> Processes wake after a timeout.

Ok that limits it but still we may be waiting for no reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
