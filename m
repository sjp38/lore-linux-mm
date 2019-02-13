Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D69E3C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:42:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9401D218D3
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:42:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9401D218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D9198E0004; Wed, 13 Feb 2019 08:42:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 388BE8E0001; Wed, 13 Feb 2019 08:42:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 251C98E0004; Wed, 13 Feb 2019 08:42:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C3E708E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:42:38 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m11so1048531edq.3
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:42:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=pBoWwbhiE0nlNpzDhANiOMoopgDoc0V/NBkvTtexFyE=;
        b=hy82orsb2HtWeqJNTU6y81iTFw91Ecpp/wg8txmTv6f2iJlJ0BWy9O0280B53jayeX
         EZeKhL0ab01hwPREDXfTp/kMF1PINlGY3Mi0t7VybHJ7b24u/rvCWgUvo6pdLn4VjUSQ
         KHXCPLxs/YlJLIlke3eGnkZm0mHoK6bLlcmjS3vCpQOm7dr3T1HRXaB8jR8yAAntcgG1
         QRFebAWGvu+H7qeTcZL5qnuUaXmDf01Tn6uJFzl6vZ23MYrZDJ6GLHDfsCgYAhvJ5Bsh
         +M1ZbZyKsruZKytLHzjSAac68SX4Z3c4Sgu7BMRzcjyGST4vJLEdYKGLlD6HQfXomq9u
         sGiA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuYQxp4IQEeIEfgM5ZXyeliVT+RbySH3NJa9ns6cDMyCPhX1B5lJ
	1bUiD8f0PWXpf2+oZ0SySKxYpbhN6J4ElIFYqgzY3ug+Wz5RqEN82VXrS0/JXuCSswe/LlK+Kdv
	D1PnU3qwgeykRPzRbVu0ndB7u88xpD0Zbyz8seom2EOv780Y+9kmMOg5XtLUCbPcLow==
X-Received: by 2002:a50:e10f:: with SMTP id h15mr420250edl.99.1550065358360;
        Wed, 13 Feb 2019 05:42:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbEycvXB75PVEXHN5JmlZ9OLsOTIpyrJwMtXB9usqeY6TypYEU9LEPBWw/zZYoEjaTQMQX7
X-Received: by 2002:a50:e10f:: with SMTP id h15mr420203edl.99.1550065357541;
        Wed, 13 Feb 2019 05:42:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550065357; cv=none;
        d=google.com; s=arc-20160816;
        b=Zl2aNfiJWqBtdpwSdr0iGAAcq4EdUe/qu86qDt9dfdHLvd5nKPrCQjCNlZZC3UrBv7
         bu1TTr2/50OfKJiHzq52IwhPPhcLIoN+uMfJ5K3bujGHGjkU06vf9iNfhvk3OmBCYl8Y
         NhCF2DvamaxhU7pyyhb8zrHrgyChDM8rtetNA0z+AmGCpgQ7DkKpDATOxM6VfoeJuub1
         VVB2SH49DMR/Fcshm6/WQrBrGDfz+D/UjchYwehVXM4o0TIeiw+MLYbq2UO2QDtLNAeH
         hlcC7NH7xPHJnHyreM4Rk1hEaX1cH8BsSKpbk6KbC2bysrLzekoc6TLXh1mDvATQ/BBI
         4ZjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=pBoWwbhiE0nlNpzDhANiOMoopgDoc0V/NBkvTtexFyE=;
        b=Lq3k0baojcLNBadPYk3UFqFltaxYObWHiCiFItloJYz7tj/zuLGg0W4kKlOLLXGx2+
         pJGcP9fxrVen1eM+Uk1gBa3oYivTL/cfFDPzXSrqn05o7/rK+KocS9fHW6wM+GbjXocF
         j/T3bI2Wtn25EGJkGRTLoJFlLe6gtA4fjub7LN+MeFD6F5Be3C9Nwxrb5SZy4+fqKxX7
         JPIyMlmh7Ia68ZuU5FXBqQeiqD1g2PE06vVxfYwpfkzxgsHRk9T6rtPtVYDKVPRQGasw
         8QBp2R8q4naoj8C4WmVkgO4vjO+WIiEywHxUFUgTuzHhejO/Ud9mO/sCwHMj/dnMsX9Z
         kyeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t12si4684250edj.120.2019.02.13.05.42.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 05:42:37 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F33BAAEBC;
	Wed, 13 Feb 2019 13:42:36 +0000 (UTC)
Subject: Re: [PATCH] mm, page_alloc: Fix a division by zero error when
 boosting watermarks
To: Mel Gorman <mgorman@techsingularity.net>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Yury Norov <yury.norov@gmail.com>, Andrea Arcangeli
 <aarcange@redhat.com>, David Rientjes <rientjes@google.com>,
 Michal Hocko <mhocko@kernel.org>, Will Deacon <will.deacon@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
References: <20190213131923.GQ9565@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <295be99c-d09a-5572-fa49-2673a62c295b@suse.cz>
Date: Wed, 13 Feb 2019 14:42:36 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190213131923.GQ9565@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/13/19 2:19 PM, Mel Gorman wrote:
> Yury Norov reported that an arm64 KVM instance could not boot since after
> v5.0-rc1 and could addressed by reverting the patches
> 
> 1c30844d2dfe272d58c ("mm: reclaim small amounts of memory when an external
> 73444bc4d8f92e46a20 ("mm, page_alloc: do not wake kswapd with zone lock held")
> 
> The problem is that a division by zero error is possible if boosting occurs
> either very early in boot or if the high watermark is very small. This
> patch checks for the conditions and avoids boosting in those cases.

Hmm is it really a division by zero? The following line sets max_boost to
pageblock_nr_pages if it's zero. And where would the division happen anyway?

So I wonder what's going on, your patch should AFAICS only take effect when
zone->_watermark[WMARK_HIGH] is 0 or 1 to begin with, otherwise max_boost is at
least 2?

Also upon closer look, I think that (prior to the patch), boost_watermark()
could be reduced (thanks to the max+min capping) to

zone->watermark_boost = pageblock_nr_pages

?

> 
> Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")
> Reported-and-tested-by: Yury Norov <yury.norov@gmail.com>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/page_alloc.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d295c9bc01a8..ae7e4ba5b9f5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2170,6 +2170,11 @@ static inline void boost_watermark(struct zone *zone)
>  
>  	max_boost = mult_frac(zone->_watermark[WMARK_HIGH],
>  			watermark_boost_factor, 10000);
> +
> +	/* high watermark be be uninitialised or very small */
> +	if (!max_boost)
> +		return;
> +
>  	max_boost = max(pageblock_nr_pages, max_boost);
>  
>  	zone->watermark_boost = min(zone->watermark_boost + pageblock_nr_pages,
> 

