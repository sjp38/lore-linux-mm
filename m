Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 1CE186B004D
	for <linux-mm@kvack.org>; Sun, 13 May 2012 21:54:51 -0400 (EDT)
Message-ID: <4FB06604.5060608@kernel.org>
Date: Mon, 14 May 2012 10:55:16 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] zsmalloc: zsmalloc: align cache line size
References: <1336027242-372-4-git-send-email-minchan@kernel.org> <4FA28EFD.5070002@vflare.org> <4FA33E89.6080206@kernel.org> <alpine.LFD.2.02.1205071038090.2851@tux.localdomain> <4FA7C2BC.2090400@vflare.org> <4FA87837.3050208@kernel.org> <731b6638-8c8c-4381-a00f-4ecd5a0e91ae@default> <4FA9C127.5020908@kernel.org> <d8fb8c73-0fd4-47c6-a9bb-ba3573569d63@default> <4FAC5C87.3060504@kernel.org> <20120511190643.GB3785@phenom.dumpdata.com>
In-Reply-To: <20120511190643.GB3785@phenom.dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/12/2012 04:06 AM, Konrad Rzeszutek Wilk wrote:

>>>> 1. zs_handle zs_malloc(size_t size, gfp_t flags) - share a pool by many subsystem(like kmalloc)
>>>> 2. zs_handle zs_malloc_pool(struct zs_pool *pool, size_t size) - use own pool(like kmem_cache_alloc)
>>>>
>>>> Any thoughts?
>>>
>>> I don't have any objections to adding this kind of
>>> capability to zsmalloc.  But since we are just speculating
>>> that this capability would be used by some future
>>> kernel subsystem, isn't it normal kernel protocol for
>>> this new capability NOT to be added until that future
>>> kernel subsystem creates a need for it.
>>
>>
>> Now zram makes pool per block device and a embedded system may use zram
>> for several block device, ex) swap device, several compressed tmpfs
>> In such case, share pool is better than private pool because embedded system
>> don't mount/umount frequently on such directories since booting.
>>
>>>
>>> As I said in reply to the other thread, there is missing
>>> functionality in zsmalloc that is making it difficult for
>>> it to be used by zcache.  It would be good if Seth
>>> and Nitin (and any other kernel developers) would work
>>
>>
>> So, if you guys post TODO list, it helps fix the direction.
>>
>>> on those issues before adding capabilities for non-existent
>>> future users of zsmalloc.
>>
>>
>> I think it's not urgent than zs_handle mess.
> 
> I am having a hard time parsing that. Are you saying that
> this is not as important as the zs_handle fixup? I think
> that is what you meant, but what to make sure.


Yes. I think zs_hande fixup is top priority for me than any other stuff I pointed out.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
