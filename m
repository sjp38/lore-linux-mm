Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07D72C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:09:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D525214DA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:09:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mtYhMFKY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D525214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4EBD8E0115; Mon, 11 Feb 2019 21:09:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD7828E0111; Mon, 11 Feb 2019 21:09:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9E478E0115; Mon, 11 Feb 2019 21:09:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8EBB88E0111
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 21:09:13 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id r24so1127933otk.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:09:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9gby31Y9nQwePnCKbAnDDhMuH/ThtuvEb3hcICvgCro=;
        b=ae/j+YWgbce4V73xfktOJRx94kVOl3STPaSZc06W69/EgX9VLvIm7dPDv/92j+6T2S
         IqjuNQXzmHNpqir7RdOSX1so10uOO28+gLaxLYXFtjCvQvCMr9BDNpY+KnmAsf431EGJ
         kMeiDWVXoK+Ha+ZA2kURRBusaDgxit0XY9GW9rKv7Xkz18chBWait9BSEgyXnoa8NP1g
         PHHcpyMXJ4+Sd13Kg35eGl7gVGGv0lVut4jfNy1sn2ICUDokIMkm2seGLp8L1HQc4nFq
         x6Jf/CQfbveJhmo7cDhDs/++aBhfeFEvoDK4VbY78xjto0/MvtQzcx53Z7vC9TX1WHJt
         rdAw==
X-Gm-Message-State: AHQUAuZAAeQZnJgRa9wCjv/7bEwvEM9NaxkiLk6x2B032KoNRQ+zFTHj
	ztqpKug3itBAtnwxF9pridlxMmiNgBHepDhkwgCBMVQhCPNTFHQo+KyLJ14rNSmUtJM6YK2AIe6
	8kUfLnLU/e+uunExn+C9JR3bpf2MiF8NnzGpTp8bAGez5f2XkyDulbqBGISNZoZTRZSCWJPYSKg
	mA1VKFYZTv4E+IEHkDdjUjZ/zYOALrDzn6bkxs9/7WJMnRaEtfYTlrhWCxY/8d9HBYUDCcl9z4L
	vAdLpxwqpV7AaT5143MDdeaSRyVkw1hyQ8xZm4LWdJw7KuBFI/T3Le0qFZLNpANZJvn8EOgONLh
	Awz8RXhkcxxtyxkHSYuJ6PPhB/1PLvlb3ZcFwGaKJwfG/of+C6e9rIVoA6UtbXBcMeapBV0/GFH
	5
X-Received: by 2002:a9d:730c:: with SMTP id e12mr1260249otk.144.1549937353118;
        Mon, 11 Feb 2019 18:09:13 -0800 (PST)
X-Received: by 2002:a9d:730c:: with SMTP id e12mr1260189otk.144.1549937352187;
        Mon, 11 Feb 2019 18:09:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549937352; cv=none;
        d=google.com; s=arc-20160816;
        b=uLk0VLYFarH1HpE6mgJ8OP0fPOApckzqOiv1tJ6qePgKOy98J9gyL7eK4yhOIs8ujz
         oJ/rBNbxo0lm70WsD69uhh/b6XBS0z2EuDgOXQBCXnoCTb++mSmuP5a//7IFM0vSH0Kb
         bOB9zjbnEgYMBBMtN6zK5OgsWLkxhFEbNecXlOwwW65qU1kBFtF2kXoAtD72JeVXeJ41
         t33fFIqYAbBPM+1WT2Gd85xp/W7qJ+X4LNjU6Aa52J22VzvoI+d6twum9OuEVolWABty
         IWOLw6HWUCPQ4mGOx9zO8oSTdD3zmRzmUO4EN1n6e+CDjWbwRIXgmPqlbgmuunkOnuXM
         8SvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=9gby31Y9nQwePnCKbAnDDhMuH/ThtuvEb3hcICvgCro=;
        b=EeHIqpgqHXhoAlYwbUpj40xxbFVzlYCtUv/Uqk4ENMB85Y8SJB74CDO9GttLeHCdOK
         pXNpbo5N7kgStgfC1bVFmPhDJxJajMVendfStGPnliooUQcYbRnK6JtWJ85/q3StsGSy
         MWlhXq5wF8qeqbw+/JO2iF6mj9XrlUlBz9WJs3POmw7HH2YGnVFOAc3btL4pM1QHPaM9
         Nk2TdNfFrhfJPG/vJNzY9nz74q2eOFxS9v4tyh5u/CUEKupU6lXu6CTxVGHEZk6UYlGZ
         MfHSDuVYsfGtuPKj2MEbmDHCK0uZI7K1PxizqjgTZHcdds8tF4p8SMcFKnRP46NdZ5KH
         TTHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mtYhMFKY;
       spf=pass (google.com: domain of aaron.lwe@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=aaron.lwe@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 33sor7397676otn.46.2019.02.11.18.09.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 18:09:12 -0800 (PST)
Received-SPF: pass (google.com: domain of aaron.lwe@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mtYhMFKY;
       spf=pass (google.com: domain of aaron.lwe@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=aaron.lwe@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=9gby31Y9nQwePnCKbAnDDhMuH/ThtuvEb3hcICvgCro=;
        b=mtYhMFKY5+lv9r+fRxghYzQkZYd68Ol+At28XurU4utm5cG11drx+VCqhCHP5o7JiS
         ufp63/vvTy46g+yeu6tfrq7wsLsHxqw5TJCqrwOMjP7fqg9+xX90otGCYCIu3Qhbq5l3
         0dGvbH5+o0Y6EC3xax8k2g7r1TfdaTm7e4AMSdvgjxWOat+VQB6uz7s7C/RY5xZoDApY
         +sZ/zK5psh3CV5GfEyPa+E1sLC7CPyh0DP8Y58fNsRV+F4/E/9gNJizdaZugl+6wiPgK
         iSW5DI9xu1FTS9czwiDFeqYeNL3ZVg2SXftUCPPyOfJvaLo+GD+H2kHh0mDx1GhCPLwF
         X0cg==
X-Google-Smtp-Source: AHgI3IYhEwsJtYH2cYOR/W/6R4O2dRuBmHn+0njx2PCLd3gc0mcrCAwWxGivoyRF4IWi0XOgdcehOg==
X-Received: by 2002:a9d:d4b:: with SMTP id 69mr1227723oti.334.1549937351704;
        Mon, 11 Feb 2019 18:09:11 -0800 (PST)
Received: from [10.15.232.23] ([205.204.117.39])
        by smtp.gmail.com with ESMTPSA id 11sm3923730oth.35.2019.02.11.18.09.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 18:09:10 -0800 (PST)
Subject: Re: [RFC PATCH 4/4] mm: Add merge page notifier
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, x86@kernel.org, mingo@redhat.com, bp@alien8.de,
 hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181558.12095.83484.stgit@localhost.localdomain>
 <5e6d22b2-0f14-43eb-846b-a940e629c02b@gmail.com>
 <a5b698b0f85667dba9b949dcb6e65a0d806669de.camel@linux.intel.com>
From: Aaron Lu <aaron.lwe@gmail.com>
Message-ID: <ead37c94-4703-170f-0ff4-1bb171556775@gmail.com>
Date: Tue, 12 Feb 2019 10:09:04 +0800
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <a5b698b0f85667dba9b949dcb6e65a0d806669de.camel@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/2/11 23:58, Alexander Duyck wrote:
> On Mon, 2019-02-11 at 14:40 +0800, Aaron Lu wrote:
>> On 2019/2/5 2:15, Alexander Duyck wrote:
>>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>>
>>> Because the implementation was limiting itself to only providing hints on
>>> pages huge TLB order sized or larger we introduced the possibility for free
>>> pages to slip past us because they are freed as something less then
>>> huge TLB in size and aggregated with buddies later.
>>>
>>> To address that I am adding a new call arch_merge_page which is called
>>> after __free_one_page has merged a pair of pages to create a higher order
>>> page. By doing this I am able to fill the gap and provide full coverage for
>>> all of the pages huge TLB order or larger.
>>>
>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>> ---
>>>  arch/x86/include/asm/page.h |   12 ++++++++++++
>>>  arch/x86/kernel/kvm.c       |   28 ++++++++++++++++++++++++++++
>>>  include/linux/gfp.h         |    4 ++++
>>>  mm/page_alloc.c             |    2 ++
>>>  4 files changed, 46 insertions(+)
>>>
>>> diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
>>> index 4487ad7a3385..9540a97c9997 100644
>>> --- a/arch/x86/include/asm/page.h
>>> +++ b/arch/x86/include/asm/page.h
>>> @@ -29,6 +29,18 @@ static inline void arch_free_page(struct page *page, unsigned int order)
>>>  	if (static_branch_unlikely(&pv_free_page_hint_enabled))
>>>  		__arch_free_page(page, order);
>>>  }
>>> +
>>> +struct zone;
>>> +
>>> +#define HAVE_ARCH_MERGE_PAGE
>>> +void __arch_merge_page(struct zone *zone, struct page *page,
>>> +		       unsigned int order);
>>> +static inline void arch_merge_page(struct zone *zone, struct page *page,
>>> +				   unsigned int order)
>>> +{
>>> +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
>>> +		__arch_merge_page(zone, page, order);
>>> +}
>>>  #endif
>>>  
>>>  #include <linux/range.h>
>>> diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
>>> index 09c91641c36c..957bb4f427bb 100644
>>> --- a/arch/x86/kernel/kvm.c
>>> +++ b/arch/x86/kernel/kvm.c
>>> @@ -785,6 +785,34 @@ void __arch_free_page(struct page *page, unsigned int order)
>>>  		       PAGE_SIZE << order);
>>>  }
>>>  
>>> +void __arch_merge_page(struct zone *zone, struct page *page,
>>> +		       unsigned int order)
>>> +{
>>> +	/*
>>> +	 * The merging logic has merged a set of buddies up to the
>>> +	 * KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER. Since that is the case, take
>>> +	 * advantage of this moment to notify the hypervisor of the free
>>> +	 * memory.
>>> +	 */
>>> +	if (order != KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
>>> +		return;
>>> +
>>> +	/*
>>> +	 * Drop zone lock while processing the hypercall. This
>>> +	 * should be safe as the page has not yet been added
>>> +	 * to the buddy list as of yet and all the pages that
>>> +	 * were merged have had their buddy/guard flags cleared
>>> +	 * and their order reset to 0.
>>> +	 */
>>> +	spin_unlock(&zone->lock);
>>> +
>>> +	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
>>> +		       PAGE_SIZE << order);
>>> +
>>> +	/* reacquire lock and resume freeing memory */
>>> +	spin_lock(&zone->lock);
>>> +}
>>> +
>>>  #ifdef CONFIG_PARAVIRT_SPINLOCKS
>>>  
>>>  /* Kick a cpu by its apicid. Used to wake up a halted vcpu */
>>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>>> index fdab7de7490d..4746d5560193 100644
>>> --- a/include/linux/gfp.h
>>> +++ b/include/linux/gfp.h
>>> @@ -459,6 +459,10 @@ static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
>>>  #ifndef HAVE_ARCH_FREE_PAGE
>>>  static inline void arch_free_page(struct page *page, int order) { }
>>>  #endif
>>> +#ifndef HAVE_ARCH_MERGE_PAGE
>>> +static inline void
>>> +arch_merge_page(struct zone *zone, struct page *page, int order) { }
>>> +#endif
>>>  #ifndef HAVE_ARCH_ALLOC_PAGE
>>>  static inline void arch_alloc_page(struct page *page, int order) { }
>>>  #endif
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index c954f8c1fbc4..7a1309b0b7c5 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -913,6 +913,8 @@ static inline void __free_one_page(struct page *page,
>>>  		page = page + (combined_pfn - pfn);
>>>  		pfn = combined_pfn;
>>>  		order++;
>>> +
>>> +		arch_merge_page(zone, page, order);
>>
>> Not a proper place AFAICS.
>>
>> Assume we have an order-8 page being sent here for merge and its order-8
>> buddy is also free, then order++ became 9 and arch_merge_page() will do
>> the hint to host on this page as an order-9 page, no problem so far.
>> Then the next round, assume the now order-9 page's buddy is also free,
>> order++ will become 10 and arch_merge_page() will again hint to host on
>> this page as an order-10 page. The first hint to host became redundant.
> 
> Actually the problem is even worse the other way around. My concern was
> pages being incrementally freed.
> 
> With this setup I can catch when we have crossed the threshold from
> order 8 to 9, and specifically for that case provide the hint. This
> allows me to ignore orders above and below 9.

OK, I see, you are now only hinting for pages with order 9, not above.

> If I move the hint to the spot after the merging I have no way of
> telling if I have hinted the page as a lower order or not. As such I
> will hint if it is merged up to orders 9 or greater. So for example if
> it merges up to order 9 and stops there then done_merging will report
> an order 9 page, then if another page is freed and merged with this up
> to order 10 you would be hinting on order 10. By placing the function
> here I can guarantee that no more than 1 hint is provided per 2MB page.

So what's the downside of hinting the page as order-10 after merge
compared to as order-9 before the merge? I can see the same physical
range can be hinted multiple times, but the total hint number is the
same: both are 2 - in your current implementation, we hint twice for
each of the 2 order-9 pages; alternatively, we can provide hint for one
order-9 page and the merged order-10 page. I think the cost of
hypercalls are the same? Is it that we want to ease the host side
madvise(DONTNEED) since we can avoid operating the same range multiple
times?

The reason I asked is, if we can move the arch_merge_page() after
done_merging tag, we can theoretically make fewer function calls on free
path for the guest. Maybe not a big deal, I don't know...

>> I think the proper place is after the done_merging tag.
>>
>> BTW, with arch_merge_page() at the proper place, I don't think patch3/4
>> is necessary - any freed page will go through merge anyway, we won't
>> lose any hint opportunity. Or do I miss anything?
> 
> You can refer to my comment above. What I want to avoid is us hinting a
> page multiple times if we aren't using MAX_ORDER - 1 as the limit. What

Yeah that's a good point. But is this going to happen?

> I am avoiding by placing this where I did is us doing a hint on orders
> greater than our target hint order. So with this way I only perform one
> hint per 2MB page, otherwise I would be performing multiple hints per
> 2MB page as every order above that would also trigger hints.
> 

