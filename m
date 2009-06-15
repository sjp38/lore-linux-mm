Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 645686B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 11:25:27 -0400 (EDT)
Date: Mon, 15 Jun 2009 16:25:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/3] Fix malloc() stall in zone_reclaim() and bring
	behaviour more in line with expectations V3
Message-ID: <20090615152543.GF23198@csn.ul.ie>
References: <20090611163006.e985639f.akpm@linux-foundation.org> <20090612110424.GD14498@csn.ul.ie> <20090615163018.B43A.A69D9226@jp.fujitsu.com> <20090615105651.GD23198@csn.ul.ie> <alpine.DEB.1.10.0906151057270.23995@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0906151057270.23995@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, fengguang.wu@intel.com, linuxram@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 11:01:41AM -0400, Christoph Lameter wrote:
> On Mon, 15 Jun 2009, Mel Gorman wrote:
> 
> > > May I ask your worry?
> > >
> >
> > Simply that I believe the intention of PF_SWAPWRITE here was to allow
> > zone_reclaim() to aggressively reclaim memory if the reclaim_mode allowed
> > it as it was a statement that off-node accesses are really not desired.
> 
> Right.
> 
> > Ok. I am not fully convinced but I'll not block it either if believe it's
> > necessary. My current understanding is that this patch only makes a difference
> > if the server is IO congested in which case the system is struggling anyway
> > and an off-node access is going to be relatively small penalty overall.
> > Conceivably, having PF_SWAPWRITE set makes things worse in that situation
> > and the patch makes some sense.
> 
> We could drop support for RECLAIM_SWAP if that simplifies things.
> 

I don't think that is necessary. While I expect it's very rarely used, I
imagine a situation where it would be desirable on a system that had large
amounts of tmpfs pages but where it wasn't critical they remain in-memory.

Removing PF_SWAPWRITE would make it less aggressive and if you were
happy with that, then that would be good enough for me.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
