Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 370A86B68BD
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 06:09:47 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n45so13126883qta.5
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 03:09:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 17si1213294qtt.40.2018.12.03.03.09.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 03:09:46 -0800 (PST)
Subject: Re: [PATCH v2] memblock: Anonotate memblock_is_reserved() with
 __init_memblock.
References: <BLUPR13MB02893411BF12EACB61888E80DFAE0@BLUPR13MB0289.namprd13.prod.outlook.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <a585d9c2-e14b-4e55-49cb-e0d0eeeecdcb@redhat.com>
Date: Mon, 3 Dec 2018 12:09:43 +0100
MIME-Version: 1.0
In-Reply-To: <BLUPR13MB02893411BF12EACB61888E80DFAE0@BLUPR13MB0289.namprd13.prod.outlook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yueyi Li <liyueyi@live.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 03.12.18 05:00, Yueyi Li wrote:
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
> 
> Signed-off-by: liyueyi <liyueyi@live.com>
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
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
