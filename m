Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6E1746B01E3
	for <linux-mm@kvack.org>; Wed, 12 May 2010 23:25:43 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4D3PegS032543
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 13 May 2010 12:25:40 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 716CD45DE60
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:25:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 529DE45DE4D
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:25:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 395561DB8037
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:25:40 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E63CAE08005
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:25:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 3/5] vmscan: remove all_unreclaimable scan control
In-Reply-To: <20100430224316.056084208@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org> <20100430224316.056084208@cmpxchg.org>
Message-Id: <20100513120536.215B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 13 May 2010 12:25:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> @@ -1789,7 +1787,7 @@ static unsigned long do_try_to_free_page
>  		sc->nr_scanned = 0;
>  		if (!priority)
>  			disable_swap_token();
> -		shrink_zones(priority, zonelist, sc);
> +		ret = shrink_zones(priority, zonelist, sc);

Please use more good name instead 'ret' ;)

otherwise looks good.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
