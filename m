Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE8DDC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 07:42:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B646A21848
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 07:42:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B646A21848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 515408E0004; Tue, 19 Feb 2019 02:42:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C4098E0002; Tue, 19 Feb 2019 02:42:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B38A8E0004; Tue, 19 Feb 2019 02:42:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D2FC88E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:42:13 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o9so1587039edh.10
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 23:42:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=qEJl9mUubSlT9za5dgpozb7BS1FHoR1awuBUyAElKKA=;
        b=rtSM4BCnSaKnNTUkpsinva5K1cS7LNik3DllNiP/VAo5ed3a4YLUERoi1oSFgRNYn4
         KITZnV9xxl0y09NqlAgkn/K/zC4489cDv3N4AA6g/NvrL9+DZ0MmP7igLzhs8Dik/hL6
         oHbQ2/AWGGe6u+3BXQ96c/Bi8RvqzODXjZdxd9zj/LL/2e69d06uU6yq+whXAyuRYuC4
         e5CV4EbRnyjE4yYyfDt2SLOAGedDc1ZDwKVf9A7rZ4aRVe83hRBlpONM+/Rtpqe/tBIE
         BfHZsAZumWHTxd2HF/58ocw+txYTnqKTA8RV0o9wWwarwW6/ENg20zNRelBpDyDV/hFb
         B8OQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuZnAyhiB6UU3r9uUvdLr/ZsMW/ptRIDQ28VhagvPPMAdgty3teJ
	J3jUSeMLyxq0NCc/tGkIuIAeKwomCMH+Yo/qXzGu16elmOfKQOmdW2wOfkDHUENmrtXmkAtcdqq
	BoPiJkfzx37/15hsmqnr7QBmteu39edwb/7SDfAQJwVz+w94EcLZy+SmizLYKXGdFwQ==
X-Received: by 2002:a17:906:6dd5:: with SMTP id j21mr12171313ejt.13.1550562133404;
        Mon, 18 Feb 2019 23:42:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ6FqWRMxmiO0ooPXxnR5BqhIcMuU9iAsg/0r15Sptls2q1GsroSrExkEL8Ms26IXR0O1/e
X-Received: by 2002:a17:906:6dd5:: with SMTP id j21mr12171268ejt.13.1550562132384;
        Mon, 18 Feb 2019 23:42:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550562132; cv=none;
        d=google.com; s=arc-20160816;
        b=S7/FI41hgbyLplIkjm7xLz7U42tZM4aEqq6wnXfIR5xiSxeGY5m6bH9q2jxxza2Js6
         gd8FkU5Kg7gq0yJdWuQGH8h0euU0A17Ig0H0v8eZbN/yvGV2DiqiybQVvcrt084ic6F5
         sF/HBs5X4VrHwM1MWgEgKnryazWqPxup0wRuiR/IGx6K02brjsfK5k7YVMwoLKdFKJbR
         dDd8xFLYsonXFCVAroecfxrFz2gb7RQ65ImzdPWYjAVDYVLM6fxER6ebAquaIeN3p2yR
         4o9+0nceFcyN4fUcmYJn9/nphR+T7oxB3XaOmrbX2tc4d0ZC/OwtmSIOpWwZqJWEsSHH
         gkLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=qEJl9mUubSlT9za5dgpozb7BS1FHoR1awuBUyAElKKA=;
        b=TTDdmmkYuP9jJYdX4eJ/zg4e49qZhNQDj18lmS/T+EV+cCKNdyMVtTKVal8+awyi95
         sx4af46iJTicF0jgXjr8KxayrP0N4wMWiMxENzfckrdYdzgtNg6CciRjMkzMgNvvj7Hu
         eKXe5kLPeyNdVAEADKOPOIgzd8aOuZvCPPSlyhAgf/f4IOU+GMSi1N3C1IW69TBYoWvA
         zNX2+5vn1ITpcu4eMtHFyN7OurWxSU6p0YdKPADH0JSm1GSN6wwMUOMvrPCFMVGGfd4b
         Wmyo2PWXQOsUNQRxL9WVJKEjFUJ4yxmuUQJw4+uztHhJi48V9yUo2G3k6eknMRK70CCg
         V4oA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v26si1611584eje.296.2019.02.18.23.42.12
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 23:42:12 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3777780D;
	Mon, 18 Feb 2019 23:42:09 -0800 (PST)
Received: from [10.162.40.139] (p8cg001049571a15.blr.arm.com [10.162.40.139])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A00143F720;
	Mon, 18 Feb 2019 23:42:04 -0800 (PST)
Subject: Re: [RFC PATCH 01/31] mm: migrate: Add exchange_pages to exchange two
 lists of pages.
To: Zi Yan <ziy@nvidia.com>, Matthew Wilcox <willy@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Michal Hocko <mhocko@kernel.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, John Hubbard
 <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>,
 Nitin Gupta <nigupta@nvidia.com>, David Nellans <dnellans@nvidia.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
 <20190215220856.29749-2-zi.yan@sent.com>
 <20190217112943.GP12668@bombadil.infradead.org>
 <65A1FFA0-531C-4078-9704-3F44819C3C07@nvidia.com>
 <2630a452-8c53-f109-1748-36b98076c86e@suse.cz>
 <53690FCD-B0BA-4619-8DF1-B9D721EE1208@nvidia.com>
 <20190218175224.GT12668@bombadil.infradead.org>
 <C84D2490-B6C6-4C7C-870F-945E31719728@nvidia.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <1ce6ae99-4865-df62-5f20-cb07ebb95327@arm.com>
Date: Tue, 19 Feb 2019 13:12:07 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <C84D2490-B6C6-4C7C-870F-945E31719728@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/18/2019 11:29 PM, Zi Yan wrote:
> On 18 Feb 2019, at 9:52, Matthew Wilcox wrote:
> 
>> On Mon, Feb 18, 2019 at 09:51:33AM -0800, Zi Yan wrote:
>>> On 18 Feb 2019, at 9:42, Vlastimil Babka wrote:
>>>> On 2/18/19 6:31 PM, Zi Yan wrote:
>>>>> The purpose of proposing exchange_pages() is to avoid allocating any
>>>>> new
>>>>> page,
>>>>> so that we would not trigger any potential page reclaim or memory
>>>>> compaction.
>>>>> Allocating a temporary page defeats the purpose.
>>>>
>>>> Compaction can only happen for order > 0 temporary pages. Even if you
>>>> used
>>>> single order = 0 page to gradually exchange e.g. a THP, it should be
>>>> better than
>>>> u64. Allocating order = 0 should be a non-issue. If it's an issue, then
>>>> the
>>>> system is in a bad state and physically contiguous layout is a secondary
>>>> concern.
>>>
>>> You are right if we only need to allocate one order-0 page. But this also
>>> means
>>> we can only exchange two pages at a time. We need to add a lock to make sure
>>> the temporary page is used exclusively or we need to keep allocating
>>> temporary pages
>>> when multiple exchange_pages() are happening at the same time.
>>
>> You allocate one temporary page per thread that's doing an exchange_page().
> 
> Yeah, you are right. I think at most I need NR_CPU order-0 pages. I will try
> it. Thanks.

But the location of this temp page matters as well because you would like to
saturate the inter node interface. It needs to be either of the nodes where
the source or destination page belongs. Any other node would generate two
internode copy process which is not what you intend here I guess.

