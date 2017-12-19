Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9AC6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:13:43 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id s41so11363554wrc.22
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:13:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v88si3363874wrb.256.2017.12.19.07.13.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 07:13:42 -0800 (PST)
Date: Tue, 19 Dec 2017 16:13:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
Message-ID: <20171219151341.GC15210@dhcp22.suse.cz>
References: <20171219102213.GA435@jagdpanzerIV>
 <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Cc: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue 19-12-17 13:49:12, Aliaksei Karaliou wrote:
[...]
> @@ -2428,8 +2422,8 @@ struct zs_pool *zs_create_pool(const char *name)
>  	 * Not critical, we still can use the pool
>  	 * and user can trigger compaction manually.
>  	 */
> -	if (zs_register_shrinker(pool) == 0)
> -		pool->shrinker_enabled = true;
> +	(void) zs_register_shrinker(pool);
> +
>  	return pool;

So what will happen if the pool is alive and used without any shrinker?
How do objects get freed?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
