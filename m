Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CC6A46B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 11:09:52 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CBA9A82C58E
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 11:26:10 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id K42WB8PAemC4 for <linux-mm@kvack.org>;
	Mon, 15 Jun 2009 11:26:10 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B96D882C2F6
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 11:26:10 -0400 (EDT)
Date: Mon, 15 Jun 2009 11:01:41 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 0/3] Fix malloc() stall in zone_reclaim() and bring
 behaviour more in line with expectations V3
In-Reply-To: <20090615105651.GD23198@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0906151057270.23995@gentwo.org>
References: <20090611163006.e985639f.akpm@linux-foundation.org> <20090612110424.GD14498@csn.ul.ie> <20090615163018.B43A.A69D9226@jp.fujitsu.com> <20090615105651.GD23198@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, fengguang.wu@intel.com, linuxram@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Jun 2009, Mel Gorman wrote:

> > May I ask your worry?
> >
>
> Simply that I believe the intention of PF_SWAPWRITE here was to allow
> zone_reclaim() to aggressively reclaim memory if the reclaim_mode allowed
> it as it was a statement that off-node accesses are really not desired.

Right.

> Ok. I am not fully convinced but I'll not block it either if believe it's
> necessary. My current understanding is that this patch only makes a difference
> if the server is IO congested in which case the system is struggling anyway
> and an off-node access is going to be relatively small penalty overall.
> Conceivably, having PF_SWAPWRITE set makes things worse in that situation
> and the patch makes some sense.

We could drop support for RECLAIM_SWAP if that simplifies things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
