Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4FD6B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 05:25:34 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so5523312wib.11
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 02:25:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uw4si26543911wjc.48.2014.06.24.02.25.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 02:25:21 -0700 (PDT)
Date: Tue, 24 Jun 2014 11:25:11 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Documentation: remove remove_from_page_cache note
Message-ID: <20140624092511.GC15337@dhcp22.suse.cz>
References: <1403601462-32167-1-git-send-email-lilei@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403601462-32167-1-git-send-email-lilei@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lei Li <lilei@linux.vnet.ibm.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 24-06-14 17:17:42, Lei Li wrote:
> Remove this note as remove_from_page_cache has been renamed to
> delete_from_page_cache since Commit 702cfbf9 ("mm: goodbye
> remove_from_page_cache()"), and it doesn't serve any useful
> purpose.
> 
> Signed-off-by: Lei Li <lilei@linux.vnet.ibm.com>

I am not sure how up-to-date the file is but this small clean up will
not hurt.

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  Documentation/cgroups/memcg_test.txt | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
> index 8870b02..67c11a3 100644
> --- a/Documentation/cgroups/memcg_test.txt
> +++ b/Documentation/cgroups/memcg_test.txt
> @@ -82,8 +82,6 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
>  	- add_to_page_cache_locked().
>  
>  	The logic is very clear. (About migration, see below)
> -	Note: __remove_from_page_cache() is called by remove_from_page_cache()
> -	and __remove_mapping().
>  
>  6. Shmem(tmpfs) Page Cache
>  	The best way to understand shmem's page state transition is to read
> -- 
> 1.8.5.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
