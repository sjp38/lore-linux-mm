Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC8B6B000A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:10:13 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g9-v6so2533095wrq.7
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 00:10:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k1-v6sor2131944wmd.62.2018.06.28.00.10.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Jun 2018 00:10:12 -0700 (PDT)
Subject: Re: [PATCH] kvm, mm: account shadow page tables to kmemcg
References: <20180627181349.149778-1-shakeelb@google.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <ea54cd69-a04e-f514-58f1-49afa1c5cb75@redhat.com>
Date: Thu, 28 Jun 2018 09:10:07 +0200
MIME-Version: 1.0
In-Reply-To: <20180627181349.149778-1-shakeelb@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Peter Feiner <pfeiner@google.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, stable <stable@vger.kernel.org>

On 27/06/2018 20:13, Shakeel Butt wrote:
> The size of kvm's shadow page tables corresponds to the size of the
> guest virtual machines on the system. Large VMs can spend a significant
> amount of memory as shadow page tables which can not be left as system
> memory overhead. So, account shadow page tables to the kmemcg.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
>  arch/x86/kvm/mmu.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index d594690d8b95..c79a398300f5 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -890,7 +890,7 @@ static int mmu_topup_memory_cache_page(struct kvm_mmu_memory_cache *cache,
>  	if (cache->nobjs >= min)
>  		return 0;
>  	while (cache->nobjs < ARRAY_SIZE(cache->objects)) {
> -		page = (void *)__get_free_page(GFP_KERNEL);
> +		page = (void *)__get_free_page(GFP_KERNEL|__GFP_ACCOUNT);
>  		if (!page)
>  			return -ENOMEM;
>  		cache->objects[cache->nobjs++] = page;
> 

Queued, with

Cc: stable@vger.kernel.org

Thanks,

Paolo
