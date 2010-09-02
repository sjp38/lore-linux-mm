Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D6A686B004A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 02:55:16 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o826tCwL030429
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 2 Sep 2010 15:55:13 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 41DE945DE51
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 15:55:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EE3445DE4E
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 15:55:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 035951DB803A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 15:55:12 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B8F441DB8038
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 15:55:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]vmscan: trival: delete dead code
In-Reply-To: <20100902055438.GA14705@sli10-conroe.sh.intel.com>
References: <20100902055438.GA14705@sli10-conroe.sh.intel.com>
Message-Id: <20100902155406.D077.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  2 Sep 2010 15:55:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> delete dead code.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c391c32..993ab4c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1914,16 +1914,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  	}
>  
>  out:
> -	/*
> -	 * Now that we've scanned all the zones at this priority level, note
> -	 * that level within the zone so that the next thread which performs
> -	 * scanning of this zone will immediately start out at this priority
> -	 * level.  This affects only the decision whether or not to bring
> -	 * mapped pages onto the inactive list.
> -	 */
> -	if (priority < 0)
> -		priority = 0;
> -
>  	delayacct_freepages_end();
>  	put_mems_allowed();

thank you.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
