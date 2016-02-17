Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0D44D6B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 04:30:58 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id a4so18757425wme.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 01:30:58 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id v71si39446527wmv.42.2016.02.17.01.30.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 01:30:56 -0800 (PST)
Received: by mail-wm0-f51.google.com with SMTP id b205so146860473wmb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 01:30:56 -0800 (PST)
Date: Wed, 17 Feb 2016 10:30:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: remove unnecessary description about a non-exist gfp
 flag
Message-ID: <20160217093054.GA29196@dhcp22.suse.cz>
References: <56C411A3.6090208@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56C411A3.6090208@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Wed 17-02-16 15:22:27, Satoru Takeuchi wrote:
> Since __GFP_NOACCOUNT is removed by the following commit,
> its description is not necessary.
> 
> commit 20b5c3039863 ("Revert 'gfp: add __GFP_NOACCOUNT'")
> 
> Signed-off-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/gfp.h | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index af1f2b2..7c76a6e 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -101,8 +101,6 @@ struct vm_area_struct;
>   *
>   * __GFP_NOMEMALLOC is used to explicitly forbid access to emergency reserves.
>   *   This takes precedence over the __GFP_MEMALLOC flag if both are set.
> - *
> - * __GFP_NOACCOUNT ignores the accounting for kmemcg limit enforcement.
>   */
>  #define __GFP_ATOMIC	((__force gfp_t)___GFP_ATOMIC)
>  #define __GFP_HIGH	((__force gfp_t)___GFP_HIGH)
> -- 
> 2.5.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
