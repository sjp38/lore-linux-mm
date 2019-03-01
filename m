Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DABEC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 20:51:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB68920848
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 20:51:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB68920848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 793378E0003; Fri,  1 Mar 2019 15:51:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 743738E0001; Fri,  1 Mar 2019 15:51:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E4FA8E0003; Fri,  1 Mar 2019 15:51:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D31B8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 15:51:47 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 134so19777098pfx.21
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 12:51:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mrER8c8NiLzcF3FwUo6repW/Fe/s25NFekUOLGF+0ts=;
        b=Vt5AT3qnn0DpoBVN9SIlAdq89uxaKVDzV3Giw8Agr8AWtna0Y85gmXzrfNtNMc9Lfq
         /kW95yYhnCMDEnjHMXBZIf5Ljse8dXYNY3e3EH9Azp5pCjmW6L40Ll3csP7TQ6CwS7mC
         N/PZtqRrcnvvy7mVPssJ9oxVBJO7RvMfa3uzz6S6vFWa0PhWfyPfNtudozTPaG0ezDKT
         g0SulFKOQ4hIGSDXPNccfgiNsbp+ekueppcJujuti00HehOpNr35pYcMmN9mGSPnYelD
         W6b5+V/g5HuIL8/CtsXa+MDPvOHxcVhRh4ygCq2dPi9YtLtP8XFcc4DhVPyrqxHG5HiK
         vsYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWq3ZwW8zhEay2Z1NzPXsRMxpaTBSEF6Ipnz2USPcMb9MzvdcTj
	rA26YWaCc3kaCoB4EugEph+Z8ISh7Dzh69cTJB98RloZ4OHcaEcCPoA9z0/Blk4BZy6aO9lutie
	5mSLaefMuZAsVoh5NAiADXyzvkw1BrDANzn0Z7zAHx390DtVYlimX6Crt7xwKoXK4jg==
X-Received: by 2002:a17:902:2e03:: with SMTP id q3mr7693060plb.330.1551473506764;
        Fri, 01 Mar 2019 12:51:46 -0800 (PST)
X-Google-Smtp-Source: APXvYqzJHCKsf0Q/X3jvtg+gjFZm+JCC7l44ivhQlmVfWxth3MZT1M3pmvObXCC0EwYE9/rhy0BP
X-Received: by 2002:a17:902:2e03:: with SMTP id q3mr7692975plb.330.1551473505766;
        Fri, 01 Mar 2019 12:51:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551473505; cv=none;
        d=google.com; s=arc-20160816;
        b=AXBoi4l+S6c8TE1pvTKeT6yQCL5NSAW2xc7/zjrfFyu5P/L5ETf2SvRarLnkpRneKU
         fBHObU0uZBpcwwcPus0IaPWDTk2ce4TIPFme3w3SAVjScdt5lnFYO9vzG8BCm3dWy61o
         BuJZi7aNK8ZlVPPNewvIxvC/XrH9Br8b5QP0+EbJOCqXtjcKsJxKotWVnjBWgKGGXRFr
         lN9tOFyQLWotfcUtekWVNH3zP4XDOerb7IUJ2+36DBAw5t4QV0keAVVCQt2buTnXOG1C
         Scc5GpFN5wFdoTPWg2mOOt3fMNLtysDAzrvbnqoBosU/7+Z+4cpS7RgIq6ovXhTM8O9u
         Eatw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=mrER8c8NiLzcF3FwUo6repW/Fe/s25NFekUOLGF+0ts=;
        b=jyLtuMvtOJW/r4+yF7RBXr4ruhwHCYrdwrk+wLnpg0lrCT+0AFiICyfopiLhz2y1o/
         +HUfaBTMXMO6uUsp40/Y3Xd0OfbQtOijD+a07HEBq5JlSODFcLHgvM6S9dP7hEuaXwmN
         odDHMKn6F23yJpAdi7Dvo/yg4frQ7rBafW2/Pf9CO7JoTR5CordXAhaYVOLgc7Mcfvem
         uAQGwSHai9V1YtibEySRSvzQRI2bAOP0z3vBLZzn0hTWecn4mJI0o+1XRdm3n7Mzxg3F
         81s/t/VaYnr2vQinpO+ICI4vMbVoIMHD4rN110FomoFmAYrcE2NsP4Hv1Ov14xuggEs3
         TZOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m10si11788418pgk.386.2019.03.01.12.51.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 12:51:45 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 0E8EAD719;
	Fri,  1 Mar 2019 20:51:45 +0000 (UTC)
Date: Fri, 1 Mar 2019 12:51:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Qian Cai <cai@lca.pw>
Cc: mhocko@kernel.org, benh@kernel.crashing.org, paulus@samba.org,
 mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Arun
 KS <arunks@codeaurora.org>
Subject: Re: [PATCH v2] mm/hotplug: fix an imbalance with DEBUG_PAGEALLOC
Message-Id: <20190301125144.1f4ce76a8e7bcd2688181f48@linux-foundation.org>
In-Reply-To: <20190301201950.96637-1-cai@lca.pw>
References: <20190301201950.96637-1-cai@lca.pw>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri,  1 Mar 2019 15:19:50 -0500 Qian Cai <cai@lca.pw> wrote:

> When onlining a memory block with DEBUG_PAGEALLOC, it unmaps the pages
> in the block from kernel, However, it does not map those pages while
> offlining at the beginning. As the result, it triggers a panic below
> while onlining on ppc64le as it checks if the pages are mapped before
> unmapping. However, the imbalance exists for all arches where
> double-unmappings could happen. Therefore, let kernel map those pages in
> generic_online_page() before they have being freed into the page
> allocator for the first time where it will set the page count to one.
> 
> On the other hand, it works fine during the boot, because at least for
> IBM POWER8, it does,
> 
> early_setup
>   early_init_mmu
>     harsh__early_init_mmu
>       htab_initialize [1]
>         htab_bolt_mapping [2]
> 
> where it effectively map all memblock regions just like
> kernel_map_linear_page(), so later mem_init() -> memblock_free_all()
> will unmap them just fine without any imbalance. On other arches without
> this imbalance checking, it still unmap them once at the most.
> 
> [1]
> for_each_memblock(memory, reg) {
>         base = (unsigned long)__va(reg->base);
>         size = reg->size;
> 
>         DBG("creating mapping for region: %lx..%lx (prot: %lx)\n",
>                 base, size, prot);
> 
>         BUG_ON(htab_bolt_mapping(base, base + size, __pa(base),
>                 prot, mmu_linear_psize, mmu_kernel_ssize));
>         }
> 
> [2] linear_map_hash_slots[paddr >> PAGE_SHIFT] = ret | 0x80;
> 
> kernel BUG at arch/powerpc/mm/hash_utils_64.c:1815!
>
> ...
>
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -660,6 +660,7 @@ static void generic_online_page(struct page *page)
>  {
>  	__online_page_set_limits(page);
>  	__online_page_increment_counters(page);
> +	kernel_map_pages(page, 1, 1);
>  	__online_page_free(page);
>  }

This code was changed a lot by Arun's "mm/page_alloc.c: memory hotplug:
free pages as higher order".

I don't think hotplug+DEBUG_PAGEALLOC is important enough to disrupt
memory_hotplug-free-pages-as-higher-order.patch, which took a long time
to sort out.  So could you please take a look at linux-next, determine
whether the problem is still there and propose a suitable patch?

Thanks.

