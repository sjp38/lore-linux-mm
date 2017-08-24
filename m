Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4488428085D
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 08:21:15 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 99so628739wrl.6
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 05:21:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 72si3356562wms.11.2017.08.24.05.21.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 05:21:09 -0700 (PDT)
Subject: Re: [PATCH v1 1/1] mm: Reversed logic in memblock_discard
References: <1503511441-95478-1-git-send-email-pasha.tatashin@oracle.com>
 <1503511441-95478-2-git-send-email-pasha.tatashin@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <398b8217-4d67-4a9d-26c3-872dbd575dce@suse.cz>
Date: Thu, 24 Aug 2017 14:21:07 +0200
MIME-Version: 1.0
In-Reply-To: <1503511441-95478-2-git-send-email-pasha.tatashin@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, terraluna977@gmail.com, stable <stable@vger.kernel.org>

+CC stable

On 08/23/2017 08:04 PM, Pavel Tatashin wrote:
> In recently introduced memblock_discard() there is a reversed logic bug.
> Memory is freed of static array instead of dynamically allocated one.
> 
> Fixes: 3010f876500f ("mm: discard memblock data later")

That patch was CC'd stable. So this one should be too. Looks like it the
original patch wasn't yet included in a stable release, so we can avoid
breakage.

> Reported-and-tested-by: Woody Suwalski <terraluna977@gmail.com>
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> ---
>  mm/memblock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index bf14aea6ab70..91205780e6b1 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -299,7 +299,7 @@ void __init memblock_discard(void)
>  		__memblock_free_late(addr, size);
>  	}
>  
> -	if (memblock.memory.regions == memblock_memory_init_regions) {
> +	if (memblock.memory.regions != memblock_memory_init_regions) {
>  		addr = __pa(memblock.memory.regions);
>  		size = PAGE_ALIGN(sizeof(struct memblock_region) *
>  				  memblock.memory.max);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
