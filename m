Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D80306B000A
	for <linux-mm@kvack.org>; Thu,  3 May 2018 15:33:22 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id d4-v6so12835264wrn.15
        for <linux-mm@kvack.org>; Thu, 03 May 2018 12:33:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h1-v6si9088900ede.397.2018.05.03.12.33.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 May 2018 12:33:21 -0700 (PDT)
Date: Thu, 3 May 2018 21:33:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: mark memcg1_events static const
Message-ID: <20180503193319.GK4535@dhcp22.suse.cz>
References: <20180503192940.94971-1-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180503192940.94971-1-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-05-18 12:29:40, Greg Thelen wrote:
> Mark memcg1_events static: it's only used by memcontrol.c.
> And mark it const: it's not modified.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2bd3df3d101a..c9c7e5ea0e2f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3083,7 +3083,7 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
>  #endif /* CONFIG_NUMA */
>  
>  /* Universal VM events cgroup1 shows, original sort order */
> -unsigned int memcg1_events[] = {
> +static const unsigned int memcg1_events[] = {
>  	PGPGIN,
>  	PGPGOUT,
>  	PGFAULT,
> -- 
> 2.17.0.441.gb46fe60e1d-goog

-- 
Michal Hocko
SUSE Labs
