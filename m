Return-Path: <SRS0=NdlI=QR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27945C282C4
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 00:57:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBE0021773
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 00:57:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBE0021773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 750078E00B9; Sat,  9 Feb 2019 19:57:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FE768E00B5; Sat,  9 Feb 2019 19:57:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C76A8E00B9; Sat,  9 Feb 2019 19:57:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A4F58E00B5
	for <linux-mm@kvack.org>; Sat,  9 Feb 2019 19:57:36 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id z126so7758331qka.10
        for <linux-mm@kvack.org>; Sat, 09 Feb 2019 16:57:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=ET3v7BkipoqurcPSEZ9fdMwwDelU4jHvk4N7Q+tBmSg=;
        b=O6iE18escwwkxOAnTJ+niDQRMalC77/np95CMnySS6zJowIE4zCrIW3+uLh3ND0Ti0
         sEdC856+YN+jmZG3tuZjORd2VRLFeFwX9CIkK9eGdG2cagMt5/YwhRUTiFE6/UkP0LzZ
         8BAvFyVjUFQT9RmeIoSpM/EGF/ONUSeHro3QxCmfqy2NeELBY/GWtxQgvvTrnciY5KU6
         IgAlIEjrKWgaoJwQbjyU77BdKxCY0yrUYUeHzBMr8pPwauO7Wi3t+5kfHEynSAdcwpHN
         g73OsepUWQqmdQnvjnlxj2PFUWkfQxBmNOOTKf5v3mgrv1MGBz9KubbXHy5jP/IVSLT0
         WAsA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubzGWFT+bkcfe3paMPa5zy+vzHAPHZCCcPsg3u33kZWmO0CpBqP
	Y0EAVRYb4ulHDUg/pLOyEsNi5nT6XERJ9lydq84cQRfHzZi3QeF+zBiZsOWnMqVWiUrLQo4rsSk
	4wnrpb0kb1iWZcVDQewTv5jKvXuQOvb7CtORpkJqbtSCt+1SbWLYxPRAUgi3m8jBsAqXSn6w4u6
	zozsQyKzZct5aanIGkbFNeOfsUePHnT0KcSHnPogT0lL1I4j6KgoD6iBA5eKaH6jz89yCWHC5cw
	TuOZMa6HqqAhQgT8VWRC+Ssk+S/A6ypi/XgSwVV2NTRNEbCa8077vWr4AvJ4LXyR0QzwBbAiOr9
	b9IqS+vT9HnNF7QjIeTjPvUN7J2CbPGJJ89nHQb9WAYUARO4SILXYcPYfoSkWppfL4paVVqYPCg
	B
X-Received: by 2002:a0c:f805:: with SMTP id r5mr22165784qvn.130.1549760255906;
        Sat, 09 Feb 2019 16:57:35 -0800 (PST)
X-Received: by 2002:a0c:f805:: with SMTP id r5mr22165773qvn.130.1549760255294;
        Sat, 09 Feb 2019 16:57:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549760255; cv=none;
        d=google.com; s=arc-20160816;
        b=Q463yWkFOB35ttGg4zk5vpQyECc0e68nyeLtxK9G43Q9fhfLKCqwdYoWTlQEVM4h8j
         O1uobc+T0rSYNl6w2nwnifg8YojTUk62cSyYq8AXIlH/nKRed0LLfzAvu11L6jCeTM1L
         py1P64lTnrkemkWZJ8K03KbNF2rQ2j0sdCYWoIstqfgPsSdihmEENrwMwDtCw+ukl+sT
         Fx490RTATGo5RX2lvYHKquul/3EMksRxoZC4yozHisVRswlV03RSbs2DU3m+tBdLrzeM
         0fRpioMmjycaPVNkZvAhlq42W0UcConazq8P+yunRlNXgpF7T7yz8oQZdRLgUkGtLOb/
         Fp0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=ET3v7BkipoqurcPSEZ9fdMwwDelU4jHvk4N7Q+tBmSg=;
        b=upaDCF/7T68kiHbaxmXF3R8HhVdPIey4gddkq7O0YyXYFP0ZeHNwjVGNjuyEIO7lLi
         Gss8ryWY9OOMjuVw75yEy5z+0aphONpHsnnjCM42zAH0RlQHiplUQmf/TfLqbdAeoE2G
         9Pi93GGs69JgiKIxRiEPLN7C9st1z1g+/0kg+sstnjdDFWUM5cYF5MCAxWHAQMG4efvp
         1SRKm1kARggmxjCU3QFQcHeL0MoFRF+2SIMYfI/UmtbhAxqJWE5aIrM2l7WyEp4mpZNK
         R1EBEFktMyDMAVAQsL4Eu8FS1YgAI4YtC0aX6k6jJFQTdokg2l/qLDYlBh9yhkfiFv8N
         6J7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a9sor7476683qtj.40.2019.02.09.16.57.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 09 Feb 2019 16:57:35 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: AHgI3IYfkc4tIvkXaGcFfDKXmmojMImhaOMR67w5y3mRuKgGyMlk4RMGWKLPxS0JodnKw57cMfa/3w==
X-Received: by 2002:ac8:2211:: with SMTP id o17mr22572959qto.170.1549760255044;
        Sat, 09 Feb 2019 16:57:35 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id b66sm8011335qkf.64.2019.02.09.16.57.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 09 Feb 2019 16:57:34 -0800 (PST)
Date: Sat, 9 Feb 2019 19:57:31 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com,
	x86@kernel.org, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	pbonzini@redhat.com, tglx@linutronix.de, akpm@linux-foundation.org
Subject: Re: [RFC PATCH 4/4] mm: Add merge page notifier
Message-ID: <20190209195325-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181558.12095.83484.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190204181558.12095.83484.stgit@localhost.localdomain>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2019 at 10:15:58AM -0800, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> Because the implementation was limiting itself to only providing hints on
> pages huge TLB order sized or larger we introduced the possibility for free
> pages to slip past us because they are freed as something less then
> huge TLB in size and aggregated with buddies later.
> 
> To address that I am adding a new call arch_merge_page which is called
> after __free_one_page has merged a pair of pages to create a higher order
> page. By doing this I am able to fill the gap and provide full coverage for
> all of the pages huge TLB order or larger.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Looks like this will be helpful whenever active free page
hints are added. So I think it's a good idea to
add a hook.

However, could you split adding the hook to a separate
patch from the KVM hypercall based implementation?

Then e.g. Nilal's patches could reuse it too.



> ---
>  arch/x86/include/asm/page.h |   12 ++++++++++++
>  arch/x86/kernel/kvm.c       |   28 ++++++++++++++++++++++++++++
>  include/linux/gfp.h         |    4 ++++
>  mm/page_alloc.c             |    2 ++
>  4 files changed, 46 insertions(+)
> 
> diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
> index 4487ad7a3385..9540a97c9997 100644
> --- a/arch/x86/include/asm/page.h
> +++ b/arch/x86/include/asm/page.h
> @@ -29,6 +29,18 @@ static inline void arch_free_page(struct page *page, unsigned int order)
>  	if (static_branch_unlikely(&pv_free_page_hint_enabled))
>  		__arch_free_page(page, order);
>  }
> +
> +struct zone;
> +
> +#define HAVE_ARCH_MERGE_PAGE
> +void __arch_merge_page(struct zone *zone, struct page *page,
> +		       unsigned int order);
> +static inline void arch_merge_page(struct zone *zone, struct page *page,
> +				   unsigned int order)
> +{
> +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
> +		__arch_merge_page(zone, page, order);
> +}
>  #endif
>  
>  #include <linux/range.h>
> diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
> index 09c91641c36c..957bb4f427bb 100644
> --- a/arch/x86/kernel/kvm.c
> +++ b/arch/x86/kernel/kvm.c
> @@ -785,6 +785,34 @@ void __arch_free_page(struct page *page, unsigned int order)
>  		       PAGE_SIZE << order);
>  }
>  
> +void __arch_merge_page(struct zone *zone, struct page *page,
> +		       unsigned int order)
> +{
> +	/*
> +	 * The merging logic has merged a set of buddies up to the
> +	 * KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER. Since that is the case, take
> +	 * advantage of this moment to notify the hypervisor of the free
> +	 * memory.
> +	 */
> +	if (order != KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
> +		return;
> +
> +	/*
> +	 * Drop zone lock while processing the hypercall. This
> +	 * should be safe as the page has not yet been added
> +	 * to the buddy list as of yet and all the pages that
> +	 * were merged have had their buddy/guard flags cleared
> +	 * and their order reset to 0.
> +	 */
> +	spin_unlock(&zone->lock);
> +
> +	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
> +		       PAGE_SIZE << order);
> +
> +	/* reacquire lock and resume freeing memory */
> +	spin_lock(&zone->lock);
> +}
> +
>  #ifdef CONFIG_PARAVIRT_SPINLOCKS
>  
>  /* Kick a cpu by its apicid. Used to wake up a halted vcpu */
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index fdab7de7490d..4746d5560193 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -459,6 +459,10 @@ static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
>  #ifndef HAVE_ARCH_FREE_PAGE
>  static inline void arch_free_page(struct page *page, int order) { }
>  #endif
> +#ifndef HAVE_ARCH_MERGE_PAGE
> +static inline void
> +arch_merge_page(struct zone *zone, struct page *page, int order) { }
> +#endif
>  #ifndef HAVE_ARCH_ALLOC_PAGE
>  static inline void arch_alloc_page(struct page *page, int order) { }
>  #endif
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c954f8c1fbc4..7a1309b0b7c5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -913,6 +913,8 @@ static inline void __free_one_page(struct page *page,
>  		page = page + (combined_pfn - pfn);
>  		pfn = combined_pfn;
>  		order++;
> +
> +		arch_merge_page(zone, page, order);
>  	}
>  	if (max_order < MAX_ORDER) {
>  		/* If we are here, it means order is >= pageblock_order.

