Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id BC4E16B0037
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 04:13:01 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id w61so2252553wes.14
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 01:13:00 -0800 (PST)
Received: from mail-ea0-x233.google.com (mail-ea0-x233.google.com [2a00:1450:4013:c01::233])
        by mx.google.com with ESMTPS id d4si3438099wix.78.2013.11.28.01.13.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 Nov 2013 01:13:00 -0800 (PST)
Received: by mail-ea0-f179.google.com with SMTP id r15so5478835ead.24
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 01:13:00 -0800 (PST)
Date: Thu, 28 Nov 2013 10:12:55 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [merged]
 mm-memcg-handle-non-error-oom-situations-more-gracefully.patch removed from
 -mm tree
Message-ID: <20131128091255.GD2761@dhcp22.suse.cz>
References: <526028bd.k5qPj2+MDOK1o6ii%akpm@linux-foundation.org>
 <alpine.DEB.2.02.1311271453270.13682@chino.kir.corp.google.com>
 <20131127233353.GH3556@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131127233353.GH3556@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, azurit@pobox.sk, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 27-11-13 18:33:53, Johannes Weiner wrote:
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 13b9d0f..5f9e467 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2675,7 +2675,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  		goto bypass;
>  
>  	if (unlikely(task_in_memcg_oom(current)))
> -		goto bypass;
> +		goto nomem;
>  
>  	/*
>  	 * We always charge the cgroup the mm_struct belongs to.

Yes, I think we really want this. Plan to send a patch? The first charge
failure due to OOM shouldn't be papered over by a later attempt if we
didn't get through mem_cgroup_oom_synchronize yet.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
