Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7E9496B01F8
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 22:48:57 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3G2mrHj026997
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 16 Apr 2010 11:48:54 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A5FBB45DE52
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 11:48:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D00A45DE4D
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 11:48:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 59E8E1DB8037
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 11:48:53 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A2E081DB803C
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 11:48:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 04/10] vmscan: Remove useless loop at end of do_try_to_free_pages
In-Reply-To: <1271352103-2280-5-git-send-email-mel@csn.ul.ie>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie> <1271352103-2280-5-git-send-email-mel@csn.ul.ie>
Message-Id: <20100416114814.279B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 16 Apr 2010 11:48:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> With the patch "vmscan: kill prev_priority completely", the loop at the
> end of do_try_to_free_pages() is now doing nothing. Delete it.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Obviously. thanks correct me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> ---
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 76c2b03..838ac8b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1806,11 +1806,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		ret = sc->nr_reclaimed;
>  
>  out:
> -	if (scanning_global_lru(sc))
> -		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> -			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
> -				continue;
> -
>  	delayacct_freepages_end();
>  
>  	return ret;
> -- 
> 1.6.5
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
