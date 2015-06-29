Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 70EE46B006E
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 11:52:17 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so104271142wiw.0
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 08:52:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id oy8si74258473wjb.145.2015.06.29.08.52.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Jun 2015 08:52:15 -0700 (PDT)
Date: Mon, 29 Jun 2015 17:52:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm:Return proper error code return if call to
 kzalloc_node falis in the function alloc_mem_cgroup_per_zone_info
Message-ID: <20150629155214.GD4612@dhcp22.suse.cz>
References: <1435592813-24499-1-git-send-email-xerofoify@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435592813-24499-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Krause <xerofoify@gmail.com>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 29-06-15 11:46:53, Nicholas Krause wrote:
> This changes us returning the value of one to -ENOMEM when the call
> for allocating memory with the function kzalloc_node fails in order
> to better comply with kernel coding pratices of returning this
> particular error code when memory allocations that are unrecoverable
> occur.

I do not see any point in such a patch. Let me repeat, and hopefully for
the last time, the patch has to make _sense_ and the changelog should
provide a _justification_ for the change. None of this is true for this
patch.

> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>

I am not interested in changes like this in the code I maintain.

> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index acb93c5..4e80811 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4442,7 +4442,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
>  		tmp = -1;
>  	pn = kzalloc_node(sizeof(*pn), GFP_KERNEL, tmp);
>  	if (!pn)
> -		return 1;
> +		return -ENOMEM;
>  
>  	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
>  		mz = &pn->zoneinfo[zone];
> -- 
> 2.1.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
