Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E3B9C6B0047
	for <linux-mm@kvack.org>; Thu, 23 Sep 2010 07:44:48 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8NBPsJK010942
	for <linux-mm@kvack.org>; Thu, 23 Sep 2010 07:25:54 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8NBikCI1691798
	for <linux-mm@kvack.org>; Thu, 23 Sep 2010 07:44:46 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8NBikJA026697
	for <linux-mm@kvack.org>; Thu, 23 Sep 2010 07:44:46 -0400
Date: Thu, 23 Sep 2010 17:14:42 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad for
 file/email/web servers
Message-ID: <20100923114442.GK3952@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1284349152.15254.1394658481@webmail.messagingengine.com>
 <20100916184240.3BC9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100916184240.3BC9.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: robm@fastmail.fm, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2010-09-16 19:01:32]:

> +			if (!(zone_reclaim_mode & RECLAIM_CACHE) &&
> +			    (gfp_mask & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK) {
> +				inc_zone_state(zone, NR_ZONE_CACHE_AVOID);
> +				goto try_next_zone;
> +			}
> +

Interesting approach, so for page cache related applications we expect
RECLAIM_CACHE to be set and hence zone_reclaim to occur. I have
another variation, a new gfp flag called __GFP_FREE_CACHE. You can
find the patches at

http://lwn.net/Articles/391293/
http://article.gmane.org/gmane.linux.kernel.mm/49155

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
