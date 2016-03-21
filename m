Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6F46B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 04:17:20 -0400 (EDT)
Received: by mail-wm0-f45.google.com with SMTP id p65so141420701wmp.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 01:17:20 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id w9si6525119wja.96.2016.03.21.01.17.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Mar 2016 01:17:18 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id x188so20101461wmg.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 01:17:18 -0700 (PDT)
Date: Mon, 21 Mar 2016 09:17:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/5] mm: memcontrol: Remove redundant hot plug notifier
 test.
Message-ID: <20160321081717.GA21248@dhcp22.suse.cz>
References: <1458336371-17748-1-git-send-email-rcochran@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458336371-17748-1-git-send-email-rcochran@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Cochran <rcochran@linutronix.de>
Cc: linux-kernel@vger.kernel.org, rt@linutronix.de, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Fri 18-03-16 22:26:07, Richard Cochran wrote:
> The test for ONLINE is redundant because the following test for !DEAD
> already includes the online case.  This patch removes the superfluous
> code.

The code used to do something specific to CPU_ONLINE in the past but now
it really seems to be pointless and maybe even confusing. All we really
care here is when the cpu goes down and we need to drain per-cpu cached
charges.

> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Signed-off-by: Richard Cochran <rcochran@linutronix.de>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks

> ---
>  mm/memcontrol.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d06cae2..993a261 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1916,9 +1916,6 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
>  	int cpu = (unsigned long)hcpu;
>  	struct memcg_stock_pcp *stock;
>  
> -	if (action == CPU_ONLINE)
> -		return NOTIFY_OK;
> -
>  	if (action != CPU_DEAD && action != CPU_DEAD_FROZEN)
>  		return NOTIFY_OK;
>  
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
