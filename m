Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B36F4C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:32:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79D32222B2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:32:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79D32222B2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A0CC8E0002; Wed, 13 Feb 2019 09:32:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44DB48E0001; Wed, 13 Feb 2019 09:32:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 365DD8E0002; Wed, 13 Feb 2019 09:32:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF08B8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:32:02 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id p52so1062008eda.18
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:32:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=8thNn5EfuxKMLdeorsfdk3C0LS7LMekDdHKYDhSQPQY=;
        b=hqIBjxRw02Hu5kYcsLTiCzXkR/1hUb7YjVbPzgL4lbqYpruz+0d/9fn14t8NyGmpj3
         ydC1LJKz60ULbwL5cEVYXvnBQV3kH29dnlB1fBRZM+7JKpa2uWdKG9eNT06CxiPHoiTz
         H5L/SRFDbaRqgRpAxuhzAZ0m1PFmGTHmEobejvFdcTLPTBWMeGMyAPzAb5ono7PpZTua
         WE7H16DSWX5Qjb+ko9nQBUFI8lbgozg6FkwP2MFoFO5iecGBvVTkaOZHT7jejzty8cHO
         Zoh2jomiOWJ5aJhI4t8cM7XIVgmbOF3qXqvaq6eZ25NM/tSBA0dfwBbM/YVOG+APQ6dk
         uZPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAubAU/4xBjCcCP+gMTWifO/QGf629gmo1owa/DrLJj0fWJXzhxjs
	2AfszWH9CicE+WqxCPiR+aYcj9YqEEtG65KxKNDfN7AxTQQlei1n22Kxv5I2cgzpZr7M30EgySa
	m1VUHMxd3ec1ekYUl/UO6sK7LfKCGZD/qGLEd79ynY9fCbdGFk7Fni8ZoynpkN/QQ3A==
X-Received: by 2002:a50:cf41:: with SMTP id d1mr648212edk.242.1550068322390;
        Wed, 13 Feb 2019 06:32:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY/fEvUmf6Lx6MAqJvvsMOFdiOK0fsiu2R/ESSzY4Xdd8CJHh/n33Z7OqRLGWFGMrMsA+AF
X-Received: by 2002:a50:cf41:: with SMTP id d1mr648164edk.242.1550068321578;
        Wed, 13 Feb 2019 06:32:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550068321; cv=none;
        d=google.com; s=arc-20160816;
        b=xKN45yblCLFL6OSOAoaoHhXDo60NxNy7CkrRDkeWJfB5cvuyPC/V/xlgZbAIxmyKs1
         Y9OkCMp+Khglw2lEv1k1Q9C8VwGOxjgpuUiDufOBpxEZ4hB/895FfKHG51EqZDXSeUhI
         nMvVMhL8xAdwVxMFb4aCTBMauPHaBLs/dozN0fihMexN7w8xwSvmokOm9gNqV1iuz3IY
         cp2aFJOgXdFCze38E/nUVbD+k6Y1rNDfRW0ekYoFFhhb2gfkVHTxXbgVdZmdsvxoyQ47
         pcKBfFbClDZEsjI87oSBLCc0HK6XcUBtBMU/JIxeCEvVNMYzana/CTLGAdtObFm+9ApU
         Qn/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=8thNn5EfuxKMLdeorsfdk3C0LS7LMekDdHKYDhSQPQY=;
        b=OlqupQFlyoltm8vwTLdwRndh2XPd834ksxMKgQsn2JXRpIrUIPspAaPDKcQvF8ZDIh
         u1WqIX6a6s5zrioTK0p5asd4dC498Wclk/744mvaLcpmuPrOv5Of/mWLTDJbjir303Ms
         XlomGZ4NafUX0IaH8T3iHK7A04qiawv1A1rheJfenA+jSVSEVaMUWXrBk4/OvyVAQaYT
         kOF4CFvmwggsovAHhYYSHJ3CEMj3NZfE/f3Pm1KeMUMj5sddFCKj87aRfiPZr4PmB0ey
         rKp3gh4xT1ra4KFd7XhE7Z/XbOXpCiwZhFP7Lzpn9e60wV51NI64hcf8IZCZxHEOM0fc
         eBFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z7si760728edh.60.2019.02.13.06.32.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 06:32:01 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EDC5AAF27;
	Wed, 13 Feb 2019 14:32:00 +0000 (UTC)
Subject: Re: [PATCH] mm, page_alloc: Fix a division by zero error when
 boosting watermarks v2
To: Mel Gorman <mgorman@techsingularity.net>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Yury Norov <yury.norov@gmail.com>, Andrea Arcangeli
 <aarcange@redhat.com>, David Rientjes <rientjes@google.com>,
 Michal Hocko <mhocko@kernel.org>, Will Deacon <will.deacon@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
References: <20190213131923.GQ9565@techsingularity.net>
 <20190213143012.GT9565@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7c0d323f-cad8-205b-5a8a-60da180a4ed0@suse.cz>
Date: Wed, 13 Feb 2019 15:31:59 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190213143012.GT9565@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/13/19 3:30 PM, Mel Gorman wrote:
> Yury Norov reported that an arm64 KVM instance could not boot since after
> v5.0-rc1 and could addressed by reverting the patches
> 
> 1c30844d2dfe272d58c ("mm: reclaim small amounts of memory when an external
> 73444bc4d8f92e46a20 ("mm, page_alloc: do not wake kswapd with zone lock held")
> 
> The problem is that a division by zero error is possible if boosting
> occurs very early in boot if the system has very little memory. This
> patch avoids the division by zero error.
> 
> Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")
> Reported-and-tested-by: Yury Norov <yury.norov@gmail.com>
> Tested-by: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks, sorry for the noise before.

> ---
>  mm/page_alloc.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d295c9bc01a8..bb1c7d843ebf 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2170,6 +2170,18 @@ static inline void boost_watermark(struct zone *zone)
>  
>  	max_boost = mult_frac(zone->_watermark[WMARK_HIGH],
>  			watermark_boost_factor, 10000);
> +
> +	/*
> +	 * high watermark may be uninitialised if fragmentation occurs
> +	 * very early in boot so do not boost. We do not fall
> +	 * through and boost by pageblock_nr_pages as failing
> +	 * allocations that early means that reclaim is not going
> +	 * to help and it may even be impossible to reclaim the
> +	 * boosted watermark resulting in a hang.
> +	 */
> +	if (!max_boost)
> +		return;
> +
>  	max_boost = max(pageblock_nr_pages, max_boost);
>  
>  	zone->watermark_boost = min(zone->watermark_boost + pageblock_nr_pages,
> 

