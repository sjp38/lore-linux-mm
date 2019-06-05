Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 506CCC28D19
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 21:22:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DCFF2075C
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 21:22:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="YTPX8cvx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DCFF2075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA2506B026C; Wed,  5 Jun 2019 17:22:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A531F6B026D; Wed,  5 Jun 2019 17:22:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 941BF6B026E; Wed,  5 Jun 2019 17:22:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB566B026C
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 17:22:11 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id w31so4543pgk.23
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 14:22:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gwSLJCAdvNTLNlkyY//PKwOh+mq4K72QRa5S83R8fqU=;
        b=uRb5T688hwuQBCItH49P40oV8qFWpKWQX5VFRtqYvnuCC/F69X6DAtln4hzS+o02+I
         +uea8sVwEadQOwXbB8HoOnfcZM3IF/t+iqPDZS/gck3/gwj5QABjdmV63Hz5uDYkCevU
         3wds1iNuqa6ASMsNtEZVYe4h5DWx7u1n9AnUZBwPzzCyn3rFrvzuGH0b3kvRr6hzCzOg
         VKT0G5jdRjp6G12xdl0ES9Fs44nBp3DzL/rorO+2gakicVkwPf8nogMWxBoOxxdyZ6+i
         hh88nCdSPHBL2v8O/LZCz7QhL/LCbDk8ZTgMc5+u8Gd8NpVWmPCINC76iHCKKdqA4xHw
         vZPQ==
X-Gm-Message-State: APjAAAU3ihT3RE2LNG/iCdOJyZnm0bzF0dP/W6wpcWfSGjmOpH9nXEpw
	oadsEcrSS5fjvtzIcCgySxll5d8I5rHJc7TjO0OP3OKBqB3QkQAXJdPoTzOmvhJ14QipHzFwQn/
	6XTwEBuWa0Nmx/kyfYbSMURDZAK/ERDuiUEtVJs6j2OsS3YKksNbEkGUvqaYLZROzLw==
X-Received: by 2002:a17:902:ba82:: with SMTP id k2mr37781653pls.323.1559769731019;
        Wed, 05 Jun 2019 14:22:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAqRmS0T7+VdP24wPKo5FTU0wfuXoL6OFY+xJ9jgKkb4ig84TjZifpc/BZj+moKOTYjGB1
X-Received: by 2002:a17:902:ba82:: with SMTP id k2mr37781606pls.323.1559769730276;
        Wed, 05 Jun 2019 14:22:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559769730; cv=none;
        d=google.com; s=arc-20160816;
        b=JEHs9r12BkXzgkLdvEajd3shO0rEU8XuoQAiPFURBr84UHnm2KppCqAVO9BEK68e1f
         yxokvHmgV7PwU0g9rBVjR0sm6mBrTj6br/66gAqHgOnZDz8EfZfPkyEfg0HU6PCIQ3tU
         GSCLam15TmHlUnnkFu1QU08l/L/BTaMwy3ONFYCSkQ4zg9r6QrkldAD4yUiJyxEkUSDe
         XqXSSFrHxBKD+u9iwhP55v7YlS8t2MxfW4lyLBDFOjW/mry2mVE+yT1yEZ6ai7WmFEEw
         OGa1sci37y7Lnsos0ElnJOa1o0JD5UlKfUrOoAJy38SjAKs7R+owWERV8k4eFJIodNGt
         HQmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gwSLJCAdvNTLNlkyY//PKwOh+mq4K72QRa5S83R8fqU=;
        b=InUsvAtkJPGb1q+BaIEFFXuGqV2pSXkX51jo4KsENNoUZ/gWjLvl7i28J0qHMoP0Kk
         mXN7ca9rkyL93N0ki7yiRAFQOsmN3eD/Gfk1Rheh8bslWiitG+4Sc2o6XIKXU46dufZ1
         pPJI4XZy+n54zqLUpD40L384doe5yhjLOHqiAbnKYWCaRoqaYJWH5HDcevA+YTfRGO84
         6fP58D9UPtAl8h4CEHYXDXtmifXwfz7NNpdl1lj/Pcw4HjD6Qv1ULD3qxsN1xuadKdJT
         nOLsgjcVhi3+WF7RegWlubuPM/vcn//yhXCOLW1VLCQiEccxXFzntqHDkpJx4a5OTNg3
         KPww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YTPX8cvx;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s201si18343pgs.522.2019.06.05.14.22.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 14:22:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YTPX8cvx;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C0D082075B;
	Wed,  5 Jun 2019 21:22:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559769729;
	bh=luabeSBI+NDeNNs1bPDzPXdc1KFEqX8vdPe4qbBqNw4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=YTPX8cvxxCwoAex7vw0g8JtLmES94g7PgiPnJqkHt+xe1ONHDWZQSrXJ0FrCk8JrB
	 ClmBf9NGKwpyxdLDZUg2It7G8FXCiHmxhwgASh6NXp9Ta8kOt2xt5cTpTObU4Nyc04
	 aB1mUL1Kw6LQuqVep2fbOKyNKktXJB+HYgP0zcJw=
Date: Wed, 5 Jun 2019 14:22:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds
 <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm/large system hash: use vmalloc for size >
 MAX_ORDER when !hashdist
Message-Id: <20190605142209.eb30cd883551a5bd81b09f00@linux-foundation.org>
In-Reply-To: <20190605144814.29319-1-npiggin@gmail.com>
References: <20190605144814.29319-1-npiggin@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu,  6 Jun 2019 00:48:13 +1000 Nicholas Piggin <npiggin@gmail.com> wrote:

> The kernel currently clamps large system hashes to MAX_ORDER when
> hashdist is not set, which is rather arbitrary.
> 
> vmalloc space is limited on 32-bit machines, but this shouldn't
> result in much more used because of small physical memory limiting
> system hash sizes.
> 
> Include "vmalloc" or "linear" in the kernel log message.
> 
> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> ---
> 
> This is a better solution than the previous one for the case of !NUMA
> systems running on CONFIG_NUMA kernels, we can clear the default
> hashdist early and have everything allocated out of the linear map.
> 
> The hugepage vmap series I will post later, but it's quite
> independent from this improvement.
> 
> ...
>
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7966,6 +7966,7 @@ void *__init alloc_large_system_hash(const char *tablename,
>  	unsigned long log2qty, size;
>  	void *table = NULL;
>  	gfp_t gfp_flags;
> +	bool virt;
>  
>  	/* allow the kernel cmdline to have a say */
>  	if (!numentries) {
> @@ -8022,6 +8023,7 @@ void *__init alloc_large_system_hash(const char *tablename,
>  
>  	gfp_flags = (flags & HASH_ZERO) ? GFP_ATOMIC | __GFP_ZERO : GFP_ATOMIC;
>  	do {
> +		virt = false;
>  		size = bucketsize << log2qty;
>  		if (flags & HASH_EARLY) {
>  			if (flags & HASH_ZERO)
> @@ -8029,26 +8031,26 @@ void *__init alloc_large_system_hash(const char *tablename,
>  			else
>  				table = memblock_alloc_raw(size,
>  							   SMP_CACHE_BYTES);
> -		} else if (hashdist) {
> +		} else if (get_order(size) >= MAX_ORDER || hashdist) {
>  			table = __vmalloc(size, gfp_flags, PAGE_KERNEL);
> +			virt = true;
>  		} else {
>  			/*
>  			 * If bucketsize is not a power-of-two, we may free
>  			 * some pages at the end of hash table which
>  			 * alloc_pages_exact() automatically does
>  			 */
> -			if (get_order(size) < MAX_ORDER) {
> -				table = alloc_pages_exact(size, gfp_flags);
> -				kmemleak_alloc(table, size, 1, gfp_flags);
> -			}
> +			table = alloc_pages_exact(size, gfp_flags);
> +			kmemleak_alloc(table, size, 1, gfp_flags);
>  		}
>  	} while (!table && size > PAGE_SIZE && --log2qty);
>  
>  	if (!table)
>  		panic("Failed to allocate %s hash table\n", tablename);
>  
> -	pr_info("%s hash table entries: %ld (order: %d, %lu bytes)\n",
> -		tablename, 1UL << log2qty, ilog2(size) - PAGE_SHIFT, size);
> +	pr_info("%s hash table entries: %ld (order: %d, %lu bytes, %s)\n",
> +		tablename, 1UL << log2qty, ilog2(size) - PAGE_SHIFT, size,
> +		virt ? "vmalloc" : "linear");

Could remove `bool virt' and use is_vmalloc_addr() in the printk?

