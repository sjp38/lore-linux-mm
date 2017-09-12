Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7A96B0033
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 11:07:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i131so2401938wma.1
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 08:07:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o43si9355755wrb.207.2017.09.12.08.07.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Sep 2017 08:07:39 -0700 (PDT)
Date: Tue, 12 Sep 2017 17:07:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] mm/memblock.c: using uninitialized value idx in
 memblock_add_range()
Message-ID: <20170912150737.envdkppnpx5xskfy@dhcp22.suse.cz>
References: <1504908933-31667-1-git-send-email-gurugio@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: !
Content-Disposition: inline
In-Reply-To: <1504908933-31667-1-git-send-email-gurugio@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gurugio@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Gioh Kim <gurugio@hanmail.net>, Gioh Kim <gi-oh.kim@profitbricks.com>

On Sat 09-09-17 00:15:33, gurugio@gmail.com wrote:
> From: Gioh Kim <gurugio@hanmail.net>
> 
> In memblock_add_range(), idx variable is a local value
> but I cannot find initialization of idx value.
> I checked idx value on my Qemu emulator. It was zero.
> Is there any hidden initialization code?

Yes for_each_memblock_type. Ugly as hell! Something to clean up I guess.
Just make the index explicit argument of the macro.

> 
> Signed-off-by: Gioh Kim <gi-oh.kim@profitbricks.com>
> ---
>  mm/memblock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 7b8a5db..23374bc 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -515,7 +515,7 @@ int __init_memblock memblock_add_range(struct memblock_type *type,
>  	bool insert = false;
>  	phys_addr_t obase = base;
>  	phys_addr_t end = base + memblock_cap_size(base, &size);
> -	int idx, nr_new;
> +	int idx = 0, nr_new;
>  	struct memblock_region *rgn;
>  
>  	if (!size)
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
