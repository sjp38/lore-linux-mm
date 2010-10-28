Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC3C6B00AC
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 21:17:48 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o9S1Hk2M001378
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 18:17:46 -0700
Received: from ywa6 (ywa6.prod.google.com [10.192.1.6])
	by kpbe14.cbf.corp.google.com with ESMTP id o9S1HixX011687
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 18:17:45 -0700
Received: by ywa6 with SMTP id 6so958547ywa.12
        for <linux-mm@kvack.org>; Wed, 27 Oct 2010 18:17:44 -0700 (PDT)
Date: Wed, 27 Oct 2010 18:17:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm, mem-hotplug: recalculate lowmem_reserve when
 memory hotplug occur
In-Reply-To: <20101026221017.B7DF.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1010271815430.32477@chino.kir.corp.google.com>
References: <20101026221017.B7DF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Oct 2010, KOSAKI Motohiro wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b48dea2..14ee899 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5002,7 +5002,7 @@ static void __init setup_per_zone_inactive_ratio(void)
>   * 8192MB:	11584k
>   * 16384MB:	16384k
>   */
> -static int __init init_per_zone_wmark_min(void)
> +int __meminit init_per_zone_wmark_min(void)
>  {
>  	unsigned long lowmem_kbytes;
>  

setup_per_zone_inactive_ratio() should be moved from __init to __meminit, 
right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
