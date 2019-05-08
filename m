Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC0F5C46470
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 23:15:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 845992173B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 23:15:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 845992173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 216266B0007; Wed,  8 May 2019 19:15:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EBB36B0008; Wed,  8 May 2019 19:15:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B5A66B000A; Wed,  8 May 2019 19:15:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AFAE96B0007
	for <linux-mm@kvack.org>; Wed,  8 May 2019 19:15:53 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id 18so125647eds.5
        for <linux-mm@kvack.org>; Wed, 08 May 2019 16:15:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Xz/HxjxQhpyBlaLyGOeCXufofjcQYStu7sDauDbFE+U=;
        b=UeQgsHZahPZESq3FDBeqEMaeAPHiALmsR8IxQUxtlv59KtGDZJ/n5GD6j0sRuZ8LIF
         M3MqQ9Hd4eklBVU9UvafGcpo5LfAz3urUvTV2y2UQlJSlQQe4GJpr8ZQfokTPzzy+LAA
         p2rTqMUjwN7NJzwUF65y2UjAT4La9I7Bw4Hs48yl8bnXybOs5i98JRCUYyQ5WMiuDigD
         WUeYESn9QIoLv1O1u79S+epk3PNYmnRKJY5HYaF8MVod0XekqjdkgDZ8uRA5jwf6JtwK
         gUmpCfxnzJzlBWxeEcki4jsfAdDhbqSaIO3WL7UTfbS03elb+pkizqnMkTAya9AEswLc
         U5RQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXtPhhih5YkXpr2jRO4um9vWmjtRV35BVf97r3j3YDTMVIeb//G
	kJ3MqMx937II+CMtxzaBBEanBpUdhvc//dYPNyoAOKKLKT+ynebBYXFNJjyswa92Rl378/xnBRF
	e+HNrsF5weeTFrMtIiqryXFq9kej2yTQRzKZDDc5JW2OtjVwynutFi1Pc10pFelMnWA==
X-Received: by 2002:a50:b68b:: with SMTP id d11mr427554ede.42.1557357353310;
        Wed, 08 May 2019 16:15:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyZKNyZS+UafYr6+4E9UcBKBdt6vqHmj+SnlWbWPNh3lTY/H2TgXlaYdt12kVH0EVA/sHb
X-Received: by 2002:a50:b68b:: with SMTP id d11mr427490ede.42.1557357352390;
        Wed, 08 May 2019 16:15:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557357352; cv=none;
        d=google.com; s=arc-20160816;
        b=yLrqquaVZmjgcrK0Fbgg6+Toe/JAITzHmQJdQ9EyHZnQvUOnF+woKiEJyZwNzn2352
         Z78IGRtdX77h2ZqOn5vZXZD/CW45tnPHIuubbJ1FT22pwuiZWwmEsKBdmvLN9wGfR+UM
         JcOb7DE5CQ00bcr9gfRhZPX3C0TP/ycz/UE0Kx+gMqdW/+MfvPay4ZnyHNvhgsOX5hv6
         xcaB4hpDxWIXTSU0jdnJmvjdIniKOyQrRz8Fsf6wCy7R9A4wPGGQqStDRg4IxHZZajNU
         AP876CpFTk4slS4rrv8r4nJ+i5pJuDr+7fRKexP17ZOx8Deil92KtVLh+wunfnG6UNjo
         jSmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=Xz/HxjxQhpyBlaLyGOeCXufofjcQYStu7sDauDbFE+U=;
        b=VqQAZP0GyqRlb0LTqaG8kCcs88totWeKpzxgjKMMnIySiphqic887XIGIB8QHzbwy7
         4wgunZOIccLPUTIzyR9o1LKx0Ep2Phf3KIbBIMPdrlHS7TN801Tv/9d0LJx+ROVZ0bus
         Sq1sET0UpBddGC8RHjIcEn+tlBaSP3NMKdWB7ctBUKd/TynG15XsR+iW69LoAcrpOLqV
         BM56H7BFj6F4Lm4xYhbt43pz82popfxwRJ5BCUCrbcRXGRKDgnXQ4+oxC7do/JIuicEX
         gDvIL2ymhppoBgLJ+S63rvRAqXFn5JsON8ChBdRtfbOxhi+km0e9a1k0VrOt/Iu2DVaA
         P15A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 37si206329edz.124.2019.05.08.16.15.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 16:15:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7B7EAAF0C;
	Wed,  8 May 2019 23:15:51 +0000 (UTC)
Message-ID: <1557357332.3028.42.camel@suse.de>
Subject: Re: [PATCH v8 09/12] mm/sparsemem: Support sub-section hotplug
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Logan
 Gunthorpe <logang@deltatee.com>, Pavel Tatashin
 <pasha.tatashin@soleen.com>,  linux-nvdimm@lists.01.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Thu, 09 May 2019 01:15:32 +0200
In-Reply-To: <155718601407.130019.14248061058774128227.stgit@dwillia2-desk3.amr.corp.intel.com>
References: 
	<155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <155718601407.130019.14248061058774128227.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-05-06 at 16:40 -0700, Dan Williams wrote:
> @@ -741,49 +895,31 @@ int __meminit sparse_add_section(int nid,
> unsigned long start_pfn,
>  		unsigned long nr_pages, struct vmem_altmap *altmap)
>  {
>  	unsigned long section_nr = pfn_to_section_nr(start_pfn);
> -	struct mem_section_usage *usage;
>  	struct mem_section *ms;
>  	struct page *memmap;
>  	int ret;

I already pointed this out in v7, but:

>  
> -	/*
> -	 * no locking for this, because it does its own
> -	 * plus, it does a kmalloc
> -	 */
>  	ret = sparse_index_init(section_nr, nid);
>  	if (ret < 0 && ret != -EEXIST)
>  		return ret;

sparse_index_init() only returns either -ENOMEM or 0, so the above can
be:

	if (ret < 0) or if (ret)

> -	ret = 0;
> -	memmap = populate_section_memmap(start_pfn,
> PAGES_PER_SECTION, nid,
> -			altmap);
> -	if (!memmap)
> -		return -ENOMEM;
> -	usage = kzalloc(mem_section_usage_size(), GFP_KERNEL);
> -	if (!usage) {
> -		depopulate_section_memmap(start_pfn,
> PAGES_PER_SECTION, altmap);
> -		return -ENOMEM;
> -	}
>  
> -	ms = __pfn_to_section(start_pfn);
> -	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
> -		ret = -EEXIST;
> -		goto out;
> -	}
> +	memmap = section_activate(nid, start_pfn, nr_pages, altmap);
> +	if (IS_ERR(memmap))
> +		return PTR_ERR(memmap);
> +	ret = 0;

If we got here, sparse_index_init must have returned 0, so ret already
contains 0.
We can remove the assignment.

>  
>  	/*
>  	 * Poison uninitialized struct pages in order to catch
> invalid flags
>  	 * combinations.
>  	 */
> -	page_init_poison(memmap, sizeof(struct page) *
> PAGES_PER_SECTION);
> +	page_init_poison(pfn_to_page(start_pfn), sizeof(struct page)
> * nr_pages);
>  
> +	ms = __pfn_to_section(start_pfn);
>  	section_mark_present(ms);
> -	sparse_init_one_section(ms, section_nr, memmap, usage);
> +	sparse_init_one_section(ms, section_nr, memmap, ms->usage);
>  
> -out:
> -	if (ret < 0) {
> -		kfree(usage);
> -		depopulate_section_memmap(start_pfn,
> PAGES_PER_SECTION, altmap);
> -	}
> +	if (ret < 0)
> +		section_deactivate(start_pfn, nr_pages, nid,
> altmap);

AFAICS, ret is only set by the return code from sparse_index_init, so
we cannot really get to this code being ret different than 0.
So we can remove the above two lines.

I will start reviewing the patches that lack review from this version
soon.

-- 
Oscar Salvador
SUSE L3

