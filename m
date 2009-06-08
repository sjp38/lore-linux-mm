Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2840F6B004F
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 09:20:15 -0400 (EDT)
Date: Mon, 8 Jun 2009 15:38:57 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] Reintroduce zone_reclaim_interval for when
	zone_reclaim() scans and fails to avoid CPU spinning at 100% on NUMA
Message-ID: <20090608143857.GG15070@csn.ul.ie>
References: <1244466090-10711-1-git-send-email-mel@csn.ul.ie> <1244466090-10711-2-git-send-email-mel@csn.ul.ie> <4A2D129D.3020309@redhat.com> <20090608135433.GD15070@csn.ul.ie> <alpine.DEB.1.10.0906081033060.21954@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0906081033060.21954@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 08, 2009 at 10:33:41AM -0400, Christoph Lameter wrote:
> On Mon, 8 Jun 2009, Mel Gorman wrote:
> 
> > Yes, they're on separate LRU lists but they are not the only pages on those
> > lists. The tmpfs pages are mixed in together with anonymous pages so we
> > cannot use NR_*_ANON.
> 
> The tmpfs pages are unreclaimable and therefore should not be on the anon
> lru.
> 

tmpfs pages can be swap-backed so can be reclaimable. Regardless of what
list they are on, we still need to know how many of them there are if
this patch is to be avoided.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
