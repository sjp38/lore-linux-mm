Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFD1B6B0008
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 16:56:53 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id w23so10023902pgv.17
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 13:56:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i12-v6sor7096631plk.60.2018.03.26.13.56.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Mar 2018 13:56:52 -0700 (PDT)
Date: Mon, 26 Mar 2018 13:56:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm/sparse: pass the __highest_present_section_nr +
 1 to alloc_func()
In-Reply-To: <20180326081956.75275-1-richard.weiyang@gmail.com>
Message-ID: <alpine.DEB.2.20.1803261356380.251389@chino.kir.corp.google.com>
References: <20180326081956.75275-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: dave.hansen@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org

On Mon, 26 Mar 2018, Wei Yang wrote:

> In 'commit c4e1be9ec113 ("mm, sparsemem: break out of loops early")',
> __highest_present_section_nr is introduced to reduce the loop counts for
> present section. This is also helpful for usemap and memmap allocation.
> 
> This patch uses __highest_present_section_nr + 1 to optimize the loop.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  mm/sparse.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 7af5e7a92528..505050346249 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -561,7 +561,7 @@ static void __init alloc_usemap_and_memmap(void (*alloc_func)
>  		map_count = 1;
>  	}
>  	/* ok, last chunk */
> -	alloc_func(data, pnum_begin, NR_MEM_SECTIONS,
> +	alloc_func(data, pnum_begin, __highest_present_section_nr+1,
>  						map_count, nodeid_begin);
>  }
>  

What happens if s/NR_MEM_SECTIONS/pnum/?
