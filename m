Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4782C6B0374
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 07:46:20 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 77so12029273wrb.11
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 04:46:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 19si3946357wmn.71.2017.06.23.04.46.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 04:46:19 -0700 (PDT)
Date: Fri, 23 Jun 2017 13:46:17 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: Remove ancient/ambiguous comment
Message-ID: <20170623114617.GO5308@dhcp22.suse.cz>
References: <1498217717-20945-1-git-send-email-nborisov@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1498217717-20945-1-git-send-email-nborisov@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <nborisov@suse.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, linux-mm@kvack.org

On Fri 23-06-17 14:35:17, Nikolay Borisov wrote:
> Currently pg_data_t is just a struct which describes a NUMA node memory 
> layout. Let's keep the comment simple and remove ambiguity.

Yes this comment just doesn't make any sense. I would even enhance the
comment and note that on UMA machines there is only a single pg_data_t
that describes the whole memory.

> 
> Signed-off-by: Nikolay Borisov <nborisov@suse.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mmzone.h | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index ef6a13b7bd3e..c870c65fb945 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -587,10 +587,6 @@ extern struct page *mem_map;
>  #endif
>  
>  /*
> - * The pg_data_t structure is used in machines with CONFIG_DISCONTIGMEM
> - * (mostly NUMA machines?) to denote a higher-level memory zone than the
> - * zone denotes.
> - *
>   * On NUMA machines, each NUMA node would have a pg_data_t to describe
>   * it's memory layout.
>   *
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
