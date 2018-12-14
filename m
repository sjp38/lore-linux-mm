Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 120778E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 10:23:29 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id s19so5028223qke.20
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 07:23:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 36si1074167qta.249.2018.12.14.07.23.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 07:23:28 -0800 (PST)
Subject: Re: [PATCH] mm: remove unused page state adjustment macro
References: <20181214063211.2290-1-richard.weiyang@gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <82520445-373a-be36-684d-d3b802f23d8b@redhat.com>
Date: Fri, 14 Dec 2018 16:23:25 +0100
MIME-Version: 1.0
In-Reply-To: <20181214063211.2290-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com

On 14.12.18 07:32, Wei Yang wrote:
> These four macro are not used anymore.
> 
> Just remove them.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
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
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
