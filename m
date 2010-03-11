Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BA19E6B00A9
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 02:42:32 -0500 (EST)
Message-ID: <4B989EE2.30803@redhat.com>
Date: Thu, 11 Mar 2010 09:42:26 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kvm : remove redundant initialization of page->private
References: <1268040782-28561-1-git-send-email-shijie8@gmail.com>	 <1268065219.1254.12.camel@barrios-desktop>  <4B977244.4010603@redhat.com> <1268231482.1254.28.camel@barrios-desktop>
In-Reply-To: <1268231482.1254.28.camel@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Huang Shijie <shijie8@gmail.com>, akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, linux-mm@kvack.org, Jan Kiszka <jan.kiszka@siemens.com>
List-ID: <linux-mm.kvack.org>

On 03/10/2010 04:31 PM, Minchan Kim wrote:
>
> The prep_new_page() in page allocator calls set_page_private(page, 0).
> So we don't need to reinitialize private of page.
>
>    

Applied, thanks.  Please copy the kvm mailing list in the future on kvm 
patches.

> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index 741373e..9851d0e 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -326,7 +326,6 @@ static int mmu_topup_memory_cache_page(struct kvm_mmu_memory_cache *cache,
>   		page = alloc_page(GFP_KERNEL);
>   		if (!page)
>   			return -ENOMEM;
> -		set_page_private(page, 0);
>   		cache->objects[cache->nobjs++] = page_address(page);
>   	}
>   	return 0;
>    

Jan, this is kvm-kmod unfriendly.  kvm_alloc_page()?

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
