Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B9F1C28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 07:33:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26AEA2650B
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 07:33:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26AEA2650B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79B326B0269; Fri, 31 May 2019 03:33:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74C316B026F; Fri, 31 May 2019 03:33:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 63AF36B0276; Fri, 31 May 2019 03:33:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14F1E6B0269
	for <linux-mm@kvack.org>; Fri, 31 May 2019 03:33:40 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x16so12647561edm.16
        for <linux-mm@kvack.org>; Fri, 31 May 2019 00:33:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=AHN0N7iMOljEqBbYSsAXzbg1fhBzisGEeWdKdQIYGnw=;
        b=EO5GvG9BTpsUaDfyPVhnysFBvMKbbbJMAq8KiubKbM0gvZ6Hzs3wQsXnKl1FpG+zNY
         YC/n0OoGhd4Dw2ZOOYjJKeuTL/V5bHk/GMavyGPEpf3t6kA0ERxecwCiRcpKU0wQ4l1T
         j2QiUQj781ENdMe0KSWcwrmtWXSjmBU0+x6OsMN4OPHTTnue8xAgWkG6YoXb9/s9UcyI
         fcZgFkig3zcHjgTx3duAH7iVk9r8buHkdezjPkZlYf8prGsMyZiQ/D61jCY1KiD4FmEk
         nSYUL7cjuzpcT93Xku3onaxaMt0JRU2HLxO8MHLkVIHuR7JQPpX/3XeUpMziB/G7hbpf
         25Hw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVl2kE8xvKdksFU0wfdYC7coYy+zslZIqhZJ8rnIDTJGHE0Ac4N
	ALpbwGZWdJtXq1CDLo4RwTnKnK3eXW2f1MZd0wcgvMZr87amK32TPB86eaDdFmzVPEdmHsRnUVw
	M3gJ57mGAanui0glOuLP/pb1H04TkeUPk70w96+0nzpL/ieSYlp1NJyRnpofILYwWmw==
X-Received: by 2002:a50:cb45:: with SMTP id h5mr9827041edi.12.1559288019556;
        Fri, 31 May 2019 00:33:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6qMMf5OtXKJKOEcvmE5tGyktI4V4yxMLyPNR9+qtdepHRia2sQuAnObFNfHvSuzKw8wyT
X-Received: by 2002:a50:cb45:: with SMTP id h5mr9826951edi.12.1559288018589;
        Fri, 31 May 2019 00:33:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559288018; cv=none;
        d=google.com; s=arc-20160816;
        b=jUTPgRuz9D0dA1qo3/6JrxHL6vJW8DfFK/jxu26ZYu8I6AQxN7p8FCj1rVtbutYk3y
         V9CuyVEokHNGLvUkfxq6Rmxmsg7UVyByUvRUYe93cAk2OsP5w3b79Fu9wFvONCQ8YLM4
         xISYYlv72FLYeiJSEULjk5sVKp+cUrsVXTFpSWv5THNe/WQA2gFkQG0/3tZwtGJuLXOF
         Me4RqPJfC5S5ScJJ19ApfVZ0hzq53IYl11uKOSoVmywVYF9Nx58GhymC5lmkUNyAwbgb
         h4PKXnnUtxTrU3faFKX6p17o3tcyDANh8b5k48Q9AI0MODoFbyzmMp6GqoiA3N8iO6X3
         LcCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=AHN0N7iMOljEqBbYSsAXzbg1fhBzisGEeWdKdQIYGnw=;
        b=jLFkMa/FFM2MWFBDRqwa+VteWPJMAUuI3F9FJMbUI1m15Hy9wdElqWcePXgwcIYmAy
         6sFPSFzs8/4Ql4KyQ+A+UcMbMYLJ2FkRlsh6b3crYbsis3m8ISVmocYAUthzW6TQpsox
         vkTLZWSMElKooWSkOzm5PWtHsJwTEeZe++CKuCaRs69ms4tY1HpAHyIOwSjzUScltvLX
         dPC9m7Vt2saGnlvf/JvF/LQQFlVjufM3odXbSr5FIlBcQjYyp1AGuyhs5Rm0jfm95sHZ
         FinQmbbHUnywO9iH8m2G/MnYwWenZ4r1hr2WeZm4u4ILCvOlYxDRVlLw5vKHt3iBjvYl
         FPJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w12si3434564edt.193.2019.05.31.00.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 00:33:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9F973AE0E;
	Fri, 31 May 2019 07:33:37 +0000 (UTC)
Subject: Re: [PATCH v10 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko
 <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, keith.busch@intel.com
References: <154899811208.3165233.17623209031065121886.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154899811738.3165233.12325692939590944259.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <cddd43de-62f6-6a91-83aa-da02ff17254d@suse.cz>
Date: Fri, 31 May 2019 09:33:36 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <154899811738.3165233.12325692939590944259.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/1/19 6:15 AM, Dan Williams wrote:
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1714,6 +1714,29 @@ config SLAB_FREELIST_HARDENED
>  	  sacrifies to harden the kernel slab allocator against common
>  	  freelist exploit methods.
>  
> +config SHUFFLE_PAGE_ALLOCATOR
> +	bool "Page allocator randomization"
> +	default SLAB_FREELIST_RANDOM && ACPI_NUMA
> +	help
> +	  Randomization of the page allocator improves the average
> +	  utilization of a direct-mapped memory-side-cache. See section
> +	  5.2.27 Heterogeneous Memory Attribute Table (HMAT) in the ACPI
> +	  6.2a specification for an example of how a platform advertises
> +	  the presence of a memory-side-cache. There are also incidental
> +	  security benefits as it reduces the predictability of page
> +	  allocations to compliment SLAB_FREELIST_RANDOM, but the
> +	  default granularity of shuffling on 4MB (MAX_ORDER) pages is
> +	  selected based on cache utilization benefits.
> +
> +	  While the randomization improves cache utilization it may
> +	  negatively impact workloads on platforms without a cache. For
> +	  this reason, by default, the randomization is enabled only
> +	  after runtime detection of a direct-mapped memory-side-cache.
> +	  Otherwise, the randomization may be force enabled with the
> +	  'page_alloc.shuffle' kernel command line parameter.
> +
> +	  Say Y if unsure.

It says "Say Y if unsure", yet if I run make oldconfig, the default is
N. Does that make sense?

> Page allocator randomization (SHUFFLE_PAGE_ALLOCATOR) [N/y/?] (NEW)

