Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7556B6845
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 04:09:42 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e29so6257702ede.19
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 01:09:42 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x23si1272065edq.366.2018.12.03.01.09.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 01:09:41 -0800 (PST)
Date: Mon, 3 Dec 2018 10:09:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] memblock: Anonotate memblock_is_reserved() with
 __init_memblock.
Message-ID: <20181203090939.GI31738@dhcp22.suse.cz>
References: <BLUPR13MB02893411BF12EACB61888E80DFAE0@BLUPR13MB0289.namprd13.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BLUPR13MB02893411BF12EACB61888E80DFAE0@BLUPR13MB0289.namprd13.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yueyi Li <liyueyi@live.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon 03-12-18 04:00:08, Yueyi Li wrote:
> Found warning:
> 
> WARNING: EXPORT symbol "gsi_write_channel_scratch" [vmlinux] version generation failed, symbol will not be versioned.
> WARNING: vmlinux.o(.text+0x1e0a0): Section mismatch in reference from the function valid_phys_addr_range() to the function .init.text:memblock_is_reserved()
> The function valid_phys_addr_range() references
> the function __init memblock_is_reserved().
> This is often because valid_phys_addr_range lacks a __init
> annotation or the annotation of memblock_is_reserved is wrong.
> 
> Use __init_memblock instead of __init.

Yes, it really doesn't make much sense to stand this out of all other
helpers.

> Signed-off-by: liyueyi <liyueyi@live.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> 
>  Changes v2: correct typo in 'warning'.
> 
>  mm/memblock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 9a2d5ae..81ae63c 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1727,7 +1727,7 @@ static int __init_memblock memblock_search(struct memblock_type *type, phys_addr
>  	return -1;
>  }
>  
> -bool __init memblock_is_reserved(phys_addr_t addr)
> +bool __init_memblock memblock_is_reserved(phys_addr_t addr)
>  {
>  	return memblock_search(&memblock.reserved, addr) != -1;
>  }
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs
