Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 55BC06B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 07:45:07 -0500 (EST)
Received: by wmww144 with SMTP id w144so94619638wmw.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:45:06 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id j21si18907691wmj.77.2015.11.23.04.45.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 04:45:06 -0800 (PST)
Received: by wmvv187 with SMTP id v187so158941481wmv.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:45:05 -0800 (PST)
Date: Mon, 23 Nov 2015 13:45:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: fix up sparse warning in gfpflags_allow_blocking
Message-ID: <20151123124503.GJ21050@dhcp22.suse.cz>
References: <1448281409-13132-1-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448281409-13132-1-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 23-11-15 07:23:29, Jeff Layton wrote:
> sparse says:
> 
>     include/linux/gfp.h:274:26: warning: incorrect type in return expression (different base types)
>     include/linux/gfp.h:274:26:    expected bool
>     include/linux/gfp.h:274:26:    got restricted gfp_t
> 
> Add a comparison to zero to have it return bool.
> 
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  include/linux/gfp.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> [v2: use a compare instead of forced cast, as suggested by Michal]
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 6523109e136d..b76c92073b1b 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -271,7 +271,7 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
>  
>  static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
>  {
> -	return gfp_flags & __GFP_DIRECT_RECLAIM;
> +	return (gfp_flags & __GFP_DIRECT_RECLAIM) != 0;
>  }
>  
>  #ifdef CONFIG_HIGHMEM
> -- 
> 2.4.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
