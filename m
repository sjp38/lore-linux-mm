Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A379C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:15:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11921222B5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:15:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11921222B5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76C098E0002; Wed, 13 Feb 2019 09:15:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71AC58E0001; Wed, 13 Feb 2019 09:15:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 608FE8E0002; Wed, 13 Feb 2019 09:15:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 062258E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:15:22 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c18so1036246edt.23
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:15:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bDvAwIjr4uJJzDNhLm7t4YVkcLnEIwIPiH9BcV6debM=;
        b=AvwbALtWG2hKNWgKBe8DzgIXEQAG8GHAyoJoqpM+EmfVfGYoznWAvH32mG9KJHiGwT
         xVObuCbDxYDa0CxhPMsQtHs6rzdAmZbx/smK8kMcy9Rk/1g5YnkJE4BSB3wAkARr81XV
         qLHy5cim3CMtBguqFCzSVUucKoyzA/ZMcL0mqdCRElnCRHzyHpdhrW8QVIEXwooT2CS0
         E4+LVsabsCCyhHx8m124KevM1hcj4sbAIr6V6F16kPkOZYWKMKXz5Guhl4P7TBYFar/N
         Vip5+eVFlGsDqe4Et8LKC0JDN3dW1NwLjh3rDfjt/s4mnpVxFe1JmshnuIc2F3Zr/fVd
         UEfg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: AHQUAuYN/tVPZHSovvUnhdWMqBvab+32bSRZPkaS2/caO2UEyqDugGTN
	cerNhdzHp4IrKYNCA/5RV/ld+bx+0MPpixtpc6nbs2QLBpvr1Dpa4wIEm53asgZO/HzDYzjEqsR
	g6GNlwhA9XRDBcO9JM/m0ZPrNMRyUeKy5qHYVWte0NRq+ONWQc3hvyRdj+V0R+GiqMw==
X-Received: by 2002:a17:906:3049:: with SMTP id d9mr534114ejd.19.1550067321517;
        Wed, 13 Feb 2019 06:15:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZJTsT5+ihwlWuL113U0i8NajDM1GWnBe1fM9wCBhZjJvB1SA+kg/8vE4MT4FpkG2rZa5gz
X-Received: by 2002:a17:906:3049:: with SMTP id d9mr534066ejd.19.1550067320674;
        Wed, 13 Feb 2019 06:15:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550067320; cv=none;
        d=google.com; s=arc-20160816;
        b=kw3OX/nalbc3Q1mMr6Z3hXdLsqYeRjhiImCXCvUqYu8x0zYxqKq/9gSnHR0gWSc2fn
         dD6aqi9uoW6zjdKpSM+ErD9rRFzFwuYpE7UecAVKwpb0uaJPuRCYU+Q5ZPZdPh2YnEZT
         lxGfOG7e+mP6nH9Ra1rP8o+tNcc4P3NzBEM+ChjUSkTb5CKdtw0ksbt2yoREgCKdlkMW
         osn/lqkRyTml7+nNSvyUBclsO/mXm4L9lZRVxTKTjmD7fV+WS4tCVMv6E54eSkonJCaM
         2er1WF4ESo1J9UfS/e6qF5pBCwdzPBagzmVhEyQH00buAkqGgpMP3ssmUNEYuhurk80r
         u46A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bDvAwIjr4uJJzDNhLm7t4YVkcLnEIwIPiH9BcV6debM=;
        b=zDfJUMPkrsEYJd+TYSy5QcaAR2oIHhNqqSFRIOes4aKkMcDhSSxNRsoHna7b7yyFUy
         QPXJpKgszOAtaqRw/Wm3SjAsUtUDHpIX4qP7XwTsfirKflgUOV5vW3DU3GxkinY2ghvO
         22q+QVBv1G3rCQ6Hva1ZJRkO2eVDc4LoPzLsBm/ceaJ1QCIsWDJZ7fACE/CsxI4ZEhi1
         k+QkkDGqtF05+2BWp8k/QwgEipEurLunLj8ivyq+8lioIpwqoji4WudZaI3HqW7vrNur
         YLDGZOctMft/mrNVsnPZ+d2mW5XGGhvGWGB7dzZSRaZcN6FSkd0ATEl8bxCo0N/LPepX
         G5VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id f4si1353743ejb.76.2019.02.13.06.15.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 06:15:20 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) client-ip=46.22.139.17;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 299041C167C
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:15:20 +0000 (GMT)
Received: (qmail 20426 invoked from network); 13 Feb 2019 14:15:20 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 13 Feb 2019 14:15:20 -0000
Date: Wed, 13 Feb 2019 14:15:18 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Yury Norov <yury.norov@gmail.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	David Rientjes <rientjes@google.com>,
	Michal Hocko <mhocko@kernel.org>, Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] mm, page_alloc: Fix a division by zero error when
 boosting watermarks
Message-ID: <20190213141518.GS9565@techsingularity.net>
References: <20190213131923.GQ9565@techsingularity.net>
 <295be99c-d09a-5572-fa49-2673a62c295b@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <295be99c-d09a-5572-fa49-2673a62c295b@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 02:42:36PM +0100, Vlastimil Babka wrote:
> On 2/13/19 2:19 PM, Mel Gorman wrote:
> > Yury Norov reported that an arm64 KVM instance could not boot since after
> > v5.0-rc1 and could addressed by reverting the patches
> > 
> > 1c30844d2dfe272d58c ("mm: reclaim small amounts of memory when an external
> > 73444bc4d8f92e46a20 ("mm, page_alloc: do not wake kswapd with zone lock held")
> > 
> > The problem is that a division by zero error is possible if boosting occurs
> > either very early in boot or if the high watermark is very small. This
> > patch checks for the conditions and avoids boosting in those cases.
> 
> Hmm is it really a division by zero? The following line sets max_boost to
> pageblock_nr_pages if it's zero. And where would the division happen anyway?
> 
> So I wonder what's going on, your patch should AFAICS only take effect when
> zone->_watermark[WMARK_HIGH] is 0 or 1 to begin with, otherwise max_boost is at
> least 2?
> 

The issue can occur if pageblock_nr_pages is also zero or not yet
initialised. It means the changelog is misleading because it  has to
trigger very early in boot as happened with Yury.

> Also upon closer look, I think that (prior to the patch), boost_watermark()
> could be reduced (thanks to the max+min capping) to
> 
> zone->watermark_boost = pageblock_nr_pages
> 

I don't think it's worth being fancy about it if we're hitting
fragmentation issues that early in boot.

-- 
Mel Gorman
SUSE Labs

