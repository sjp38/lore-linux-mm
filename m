Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 260B28E0014
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 03:24:37 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f17so2406291edm.20
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 00:24:37 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i25-v6si1522959ejz.8.2018.12.14.00.24.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 00:24:35 -0800 (PST)
Date: Fri, 14 Dec 2018 09:24:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: remove unused page state adjustment macro
Message-ID: <20181214082433.GJ1286@dhcp22.suse.cz>
References: <20181214063211.2290-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214063211.2290-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

On Fri 14-12-18 14:32:11, Wei Yang wrote:
> These four macro are not used anymore.
> 
> Just remove them.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/vmstat.h | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index f25cef84b41d..2db8d60981fe 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -239,11 +239,6 @@ extern unsigned long node_page_state(struct pglist_data *pgdat,
>  #define node_page_state(node, item) global_node_page_state(item)
>  #endif /* CONFIG_NUMA */
>  
> -#define add_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, __d)
> -#define sub_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, -(__d))
> -#define add_node_page_state(__p, __i, __d) mod_node_page_state(__p, __i, __d)
> -#define sub_node_page_state(__p, __i, __d) mod_node_page_state(__p, __i, -(__d))
> -
>  #ifdef CONFIG_SMP
>  void __mod_zone_page_state(struct zone *, enum zone_stat_item item, long);
>  void __inc_zone_page_state(struct page *, enum zone_stat_item);
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
