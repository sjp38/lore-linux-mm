Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4E76E6B0055
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 06:06:44 -0400 (EDT)
Date: Thu, 4 Jun 2009 12:04:36 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch][v2] swap: virtual swap readahead
Message-ID: <20090604100436.GA1602@cmpxchg.org>
References: <20090602223738.GA15475@cmpxchg.org> <20090604104628.99520342.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090604104628.99520342.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 04, 2009 at 10:46:28AM +0900, KAMEZAWA Hiroyuki wrote:

> I wonder (I just wonder..) can we add code like following here ?
> 
>    /* we do _readahead_ here. Then, we don't want to add too much jobs to vm/IO*/
>    if (swp != entry)
> 	gfp_mask &= ~__GFP_WAIT
> > +		page = read_swap_cache_async(swp, gfp_mask, vma, pos);
> 
> too slow ?

Good idea, certainly worth evaluating.  But not in this patch, I don't
want to change _everything_ at once :-)

	Thanks, Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
