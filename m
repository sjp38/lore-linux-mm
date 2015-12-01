Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 850186B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 03:33:18 -0500 (EST)
Received: by wmww144 with SMTP id w144so162452207wmw.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 00:33:18 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id k14si34708455wmh.48.2015.12.01.00.33.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 00:33:17 -0800 (PST)
Received: by wmec201 with SMTP id c201so193451529wme.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 00:33:16 -0800 (PST)
Date: Tue, 1 Dec 2015 09:33:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] MAINTAINERS: make Vladimir co-maintainer of the memory
 controller
Message-ID: <20151201083314.GA4567@dhcp22.suse.cz>
References: <1448908170-2990-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448908170-2990-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 30-11-15 13:29:30, Johannes Weiner wrote:
> Vladimir architected and authored much of the current state of the
> memcg's slab memory accounting and tracking. Make sure he gets CC'd
> on bug reports ;-)
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  MAINTAINERS | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index ea17512..f97f17f 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -2973,6 +2973,7 @@ F:	kernel/cpuset.c
>  CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)
>  M:	Johannes Weiner <hannes@cmpxchg.org>
>  M:	Michal Hocko <mhocko@kernel.org>
> +M:	Vladimir Davydov <vdavydov@virtuozzo.com>
>  L:	cgroups@vger.kernel.org
>  L:	linux-mm@kvack.org
>  S:	Maintained
> -- 
> 2.6.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
