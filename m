Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE1656B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 05:16:29 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 30so1003027wrw.6
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 02:16:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w11si15998281wra.89.2018.02.21.02.16.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Feb 2018 02:16:28 -0800 (PST)
Date: Wed, 21 Feb 2018 11:16:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_poison: Make early_page_poison_param __init
Message-ID: <20180221101626.GA14384@dhcp22.suse.cz>
References: <20180117034757.27024-1-douly.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180117034757.27024-1-douly.fnst@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dou Liyang <douly.fnst@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org

On Wed 17-01-18 11:47:57, Dou Liyang wrote:
> The early_param() is only called during kernel initialization, So Linux
> marks the function of it with __init macro to save memory.
> 
> But it forgot to mark the early_page_poison_param(). So, Make it __init
> as well.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Philippe Ombredanne <pombredanne@nexb.com>
> Cc: Kate Stewart <kstewart@linuxfoundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: linux-mm@kvack.org
> Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_poison.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_poison.c b/mm/page_poison.c
> index e83fd44867de..aa2b3d34e8ea 100644
> --- a/mm/page_poison.c
> +++ b/mm/page_poison.c
> @@ -9,7 +9,7 @@
>  
>  static bool want_page_poisoning __read_mostly;
>  
> -static int early_page_poison_param(char *buf)
> +static int __init early_page_poison_param(char *buf)
>  {
>  	if (!buf)
>  		return -EINVAL;
> -- 
> 2.14.3
> 
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
