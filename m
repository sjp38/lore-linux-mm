Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 052A56B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 02:12:46 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c73so6946249pfb.7
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 23:12:45 -0800 (PST)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id m6si5425752pgn.163.2017.01.17.23.12.43
        for <linux-mm@kvack.org>;
        Tue, 17 Jan 2017 23:12:45 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170117221610.22505-1-vbabka@suse.cz> <20170117221610.22505-5-vbabka@suse.cz>
In-Reply-To: <20170117221610.22505-5-vbabka@suse.cz>
Subject: Re: [RFC 4/4] mm, page_alloc: fix premature OOM when racing with cpuset mems update
Date: Wed, 18 Jan 2017 15:12:27 +0800
Message-ID: <036e01d2715a$3a227de0$ae6779a0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vlastimil Babka' <vbabka@suse.cz>, 'Mel Gorman' <mgorman@techsingularity.net>, 'Ganapatrao Kulkarni' <gpkulkarni@gmail.com>
Cc: 'Michal Hocko' <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


On Wednesday, January 18, 2017 6:16 AM Vlastimil Babka wrote: 
> 
> @@ -3802,13 +3811,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	 * Also recalculate the starting point for the zonelist iterator or
>  	 * we could end up iterating over non-eligible zones endlessly.
>  	 */
Is the newly added comment still needed?

> -	if (unlikely(ac.nodemask != nodemask)) {
> -no_zone:
> +	if (unlikely(ac.nodemask != nodemask))
>  		ac.nodemask = nodemask;
> -		ac.preferred_zoneref = first_zones_zonelist(ac.zonelist,
> -						ac.high_zoneidx, ac.nodemask);
> -		/* If we have NULL preferred zone, slowpath wll handle that */
> -	}
> 
>  	page = __alloc_pages_slowpath(alloc_mask, order, &ac);
> 
> --
> 2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
