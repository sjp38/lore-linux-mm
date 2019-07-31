Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4E90C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:11:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C83F20C01
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:11:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="JWwb9h/L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C83F20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 194118E0006; Wed, 31 Jul 2019 12:11:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 145258E0001; Wed, 31 Jul 2019 12:11:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F27A68E0006; Wed, 31 Jul 2019 12:11:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC7148E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 12:11:09 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d190so43491661pfa.0
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:11:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=G8M0Rf3LhXvIa9WeNE6MatJYWdlqbfF/uCQQ1z9oEpM=;
        b=G+6nI3RUAAgDLbtrhiuEVBslkFUH9w1pdYJC7uhh8SJdnhJXKtupWevgk9prejgG1Y
         OBMidkiWCMLfm6/ifBLk0q+eKXdI0MbvCmi5rsXKVKaGMhVEWm1Ps3tist+mvi7BOK9K
         USGcKTErK0EEZPubn/zbwTO/GyAXjo/NzKE8SjQ7YhfA2DpUEojaxRosXNPjdlP+6Ox8
         XHZwroi3M8PCVq+WjitjMX6OkyviU8rUoSV2E7j0IZ9QjTL1V/MxskgcJA+022ouk167
         ZyBd6lHqmrFximGMNwiyBuqG5d+pDuNHzluyRfTbNvNwwkOuaFxPTKVLl+s3qmJHIcEP
         9HkA==
X-Gm-Message-State: APjAAAWGQ6vVbS5UhQqgTfZNcRMZ7p3h0wtgI9sKRAvfIebkUZLA4qCM
	Lhnw1pB7m3fh6dRl3N/Hin4iz+4dNQrWUuKDjYONRgfxdXwdeaE0K1S82fM4CAlS857oNrMZWGm
	UwdadVApdC5Ca+U2O19vCOEN0KV5qVgTAiGV8cY8Ob99Dn4lzovPCVKOO7S8DxpIkdw==
X-Received: by 2002:a63:10a:: with SMTP id 10mr30817122pgb.281.1564589469360;
        Wed, 31 Jul 2019 09:11:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywxqiUYMXhnA1sAiovSMhzfPkgVj2pwXjGI4fLaFn30vPLM7kpiwsPAHzHKkgNK+kKtjGi
X-Received: by 2002:a63:10a:: with SMTP id 10mr30817071pgb.281.1564589468609;
        Wed, 31 Jul 2019 09:11:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564589468; cv=none;
        d=google.com; s=arc-20160816;
        b=oFn93OD6pAHfH33eMlXCHiPuASwtEqaZ+TvToR/6OGw6AiVwXBWq7E1JCPqKOCQENL
         hgBOUffGfv33QDtP2T0eu8lkPTK9GYh+R7uFWA3KaDvpVn6ZLuZY8/9WSYZOmpur0K4q
         QY1AMxQfTO+4foZGnOu5G94DzNJd1H/joSv0xyaOssBdzkmZjCPeZRAzBe0D05TfsVqH
         uBXh65Z4++Cr9Nh/841lCXHQym2vmsx4qc3ykYB8wvzEDaRk04wkOwm0tuASIoEEAYc7
         2+jZo7PNs+yI6XateeTheoG/3s7eKe2LTKAltBVgtf28nnkW3afLjPz1Bt5e00ncjYHm
         wsgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=G8M0Rf3LhXvIa9WeNE6MatJYWdlqbfF/uCQQ1z9oEpM=;
        b=fpwHEzSVSl0ysCP8a9o1wjA4RaGIwXA1rxhKWreHg8TJI+4P4boMLhfJY7FIv3p2v7
         vN9E5Q74Mc7u6I2xsOhzwzpuWZMh9HSAaKzzEJw49UOFWYVL3sI0mUbVPbQpu5+/ZNfV
         vUF6u/qNmt4ZFK57Otd2jh2JUgzo9RyiPaRl+KZwfJAHj28josBSdBof/SdgKZ/x+klq
         AmvYP4cPhA0MVSEmRToX4y5PBX+o2Cw7aeXuK6WXJic1Tzuw5Jzmw+laL52etVjUsNMh
         o/EjLVYYKm/zhKyNaGBKp1j9/ddy/2AxQ/ydy1JL3gi6vyyRDeNbrIFphpgm9boslWnx
         xp8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="JWwb9h/L";
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v1si28623278plb.381.2019.07.31.09.11.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 09:11:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="JWwb9h/L";
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from willie-the-truck (236.31.169.217.in-addr.arpa [217.169.31.236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 11533206A3;
	Wed, 31 Jul 2019 16:11:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564589468;
	bh=wMw/vfv7591v5B2lTvWN47RNjbkh0FPCOeS3UTprHLk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=JWwb9h/LpO93Nj+dCkoUS/EpGOhXEKuyHtRHXJC6igJNZAwfQn0IYkY7GipJK9fRJ
	 XReuRfvbRYRviqtwDUSADC6rOMJeYCvzl9f5WmQnPcH5pZvZXdZE4wp3fSsmA+9VBr
	 U+kZr3/F/RT8+HUjng0iS0Bm/HZsFhsyWU9sfaag=
Date: Wed, 31 Jul 2019 17:11:04 +0100
From: Will Deacon <will@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Mark Rutland <mark.rutland@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [RFC 2/2] arm64/mm: Enable device memory allocation and free for
 vmemmap mapping
Message-ID: <20190731161103.kqv3v2xlq4vnyjhp@willie-the-truck>
References: <1561697083-7329-1-git-send-email-anshuman.khandual@arm.com>
 <1561697083-7329-3-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561697083-7329-3-git-send-email-anshuman.khandual@arm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 10:14:43AM +0530, Anshuman Khandual wrote:
> This enables vmemmap_populate() and vmemmap_free() functions to incorporate
> struct vmem_altmap based device memory allocation and free requests. With
> this device memory with specific atlmap configuration can be hot plugged
> and hot removed as ZONE_DEVICE memory on arm64 platforms.
> 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>  arch/arm64/mm/mmu.c | 57 ++++++++++++++++++++++++++++++++++-------------------
>  1 file changed, 37 insertions(+), 20 deletions(-)
> 
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index 39e18d1..8867bbd 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -735,15 +735,26 @@ int kern_addr_valid(unsigned long addr)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> -static void free_hotplug_page_range(struct page *page, size_t size)
> +static void free_hotplug_page_range(struct page *page, size_t size,
> +				    struct vmem_altmap *altmap)
>  {
> -	WARN_ON(!page || PageReserved(page));
> -	free_pages((unsigned long)page_address(page), get_order(size));
> +	if (altmap) {
> +		/*
> +		 * vmemmap_populate() creates vmemmap mapping either at pte
> +		 * or pmd level. Unmapping request at any other level would
> +		 * be a problem.
> +		 */
> +		WARN_ON((size != PAGE_SIZE) && (size != PMD_SIZE));
> +		vmem_altmap_free(altmap, size >> PAGE_SHIFT);
> +	} else {
> +		WARN_ON(!page || PageReserved(page));
> +		free_pages((unsigned long)page_address(page), get_order(size));
> +	}
>  }
>  
>  static void free_hotplug_pgtable_page(struct page *page)
>  {
> -	free_hotplug_page_range(page, PAGE_SIZE);
> +	free_hotplug_page_range(page, PAGE_SIZE, NULL);
>  }
>  
>  static void free_pte_table(pmd_t *pmdp, unsigned long addr)
> @@ -807,7 +818,8 @@ static void free_pud_table(pgd_t *pgdp, unsigned long addr)
>  }
>  
>  static void unmap_hotplug_pte_range(pmd_t *pmdp, unsigned long addr,
> -				    unsigned long end, bool sparse_vmap)
> +				    unsigned long end, bool sparse_vmap,
> +				    struct vmem_altmap *altmap)

Do you still need the sparse_vmap parameter, or can you just pass a NULL
altmap pointer when sparse_vmap is false?

Will

