Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1A0E86B005C
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 23:03:45 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L33jAX014162
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 12:03:45 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D20145DE52
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 12:03:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CD8E45DE53
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 12:03:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 293701DB8037
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 12:03:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B51941DB803A
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 12:03:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 04/25] Check only once if the zonelist is suitable for the allocation
In-Reply-To: <1240266011-11140-5-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-5-git-send-email-mel@csn.ul.ie>
Message-Id: <20090421120258.F122.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 12:03:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> -restart:
> -	z = zonelist->_zonerefs;  /* the list of zones suitable for gfp_mask */
> -
> +	/* the list of zones suitable for gfp_mask */
> +	z = zonelist->_zonerefs;
>  	if (unlikely(!z->zone)) {
>  		/*
>  		 * Happens if we have an empty zonelist as a result of
> @@ -1497,6 +1496,7 @@ restart:
>  		return NULL;
>  	}
>  
> +restart:
>  	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
>  			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET);
>  	if (page)

looks good.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
