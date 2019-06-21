Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C555C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:20:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5AE220679
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:20:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5AE220679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84D3A8E0005; Fri, 21 Jun 2019 10:20:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FD878E0001; Fri, 21 Jun 2019 10:20:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EDD28E0005; Fri, 21 Jun 2019 10:20:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 203398E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 10:20:53 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n49so9383409edd.15
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 07:20:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IhUv8kOzmd5g1pqwwhiqADXNfS0X3pC2GAimunNacSQ=;
        b=WcE1HuOdyZTZyejVwtIjhvpNEZE2h6Q6j46J28ggIFQwGpxxsz5Lws+ftwVYi2JS9A
         jnAAf3EHsA34j7nvcoxLxAW3ANxUcYE8nnbsL9kXlAi1he0vDfOgVaUOkhEnclRnK4Ne
         4s51hvKk8MLIDNmQmXDBvUE4Z9kx8X78Y68z9Asm+xzsiBNaRdCq4aZtLpDUJJ3GNSkj
         ptWdkGtnfi2kmt1eiejW/84bxVkXlRRpzroOUYn/jQKrLWzZu0LXxc+HEolhxs6EZqvx
         QpL/B8BypH2LRN2Mvk3hnfdRmTNhci0UAUuoneln9jDB5I/vE+c/9Rvma6c9ljLCMvUA
         apQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.192 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVbeEl8pQNF+tJuDTTAw0z1qiHfX6TtArvW2y+8/YSMBckpe36N
	witV16SFNSnt1QaEL4DWVom/A1Kb2rmhuUzT7GOtLSxgMtiZD9HePyoiTIEgPxWaE74V5b6z61O
	AxKHIdaEH57GOnurqO4LBWp+cx0LI436RFCXxgQNqntxrbJIAI2eApJTJt/xghdkO1A==
X-Received: by 2002:a50:f781:: with SMTP id h1mr79381819edn.240.1561126852674;
        Fri, 21 Jun 2019 07:20:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTLKJId5b7megOo1Lp9CWCcC9a3ZuHf2NUJlN5M85L/x8QvLN1nSgi9WX/iXtNOS16Zk5t
X-Received: by 2002:a50:f781:: with SMTP id h1mr79381747edn.240.1561126852003;
        Fri, 21 Jun 2019 07:20:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561126851; cv=none;
        d=google.com; s=arc-20160816;
        b=e+D6bezlNSuMNq3vaV/yLqKHoBUljBwbmDBiGWlgS0ViSolaEy4LM/p5Dhs1qKeI6a
         zSNb8BFYau39ti86yCiWbQJcySg7SX6KRVW7kAK7048ko0i9oa+IiWAAArDjq2KPFSwE
         iWwYbtT+CRXNhXXgqRkvmEc7+G/ZJX6tgZKGXlcQ5+5GuLXJdIzkXlV+dTyfDZRZKhuJ
         zwd6KtCZ+sis51Rrcv3OV/9YuXC9J7gFOH9QA/JE1ib5ymi6903W+XDS6nRG+B/PNnWZ
         ShnqstbnFpZcGJZR6zDhjycvCo3Mxq0pcMTQbDM2X3+3rok5X9lh7uHZ6GQ0e4uQU3vw
         bfqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IhUv8kOzmd5g1pqwwhiqADXNfS0X3pC2GAimunNacSQ=;
        b=WOx0ebn/rVwbBrhF9yKb4pqiOK/7Z5vF0IV/VKM4kO7ytRWTC8YLKrz3b9ZQJbk9JR
         kFMwW5Woqy+GO6vLT7QF1gA1NOWN3LpSrhREzyzpk04viE21yQwSn3Z/U58j1SvoBZWG
         6WleugZspR9bkEidTHMgGG3BWff1UHoYsfwPHCwJqFRwB4Bnd/Mnbzb1c1lF8yMi0dYc
         YPphLi1T8Z9ICdaxV8jeSJf/R/RH0A16izoPfG03yeMMjvNH5xd/hq8n/9fglSj/mV+S
         viq5g/h3lMzV32FBLlgmKclyvmSNyi95+R/x7kFXaaosZUEGKYi4G3ZXMhsuxMWS9LJQ
         kR3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.192 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp24.blacknight.com (outbound-smtp24.blacknight.com. [81.17.249.192])
        by mx.google.com with ESMTPS id z2si1906720ejb.3.2019.06.21.07.20.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 07:20:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.192 as permitted sender) client-ip=81.17.249.192;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.192 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp24.blacknight.com (Postfix) with ESMTPS id 6582AB8995
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 15:20:51 +0100 (IST)
Received: (qmail 22845 invoked from network); 21 Jun 2019 14:20:51 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.21.36])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 21 Jun 2019 14:20:51 -0000
Date: Fri, 21 Jun 2019 15:16:33 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Alan Jenkins <alan.christopher.jenkins@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm: fix setting the high and low watermarks
Message-ID: <20190621141633.GA2978@techsingularity.net>
References: <20190621114325.711-1-alan.christopher.jenkins@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190621114325.711-1-alan.christopher.jenkins@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 12:43:25PM +0100, Alan Jenkins wrote:
> When setting the low and high watermarks we use min_wmark_pages(zone).
> I guess this is to reduce the line length.  But we forgot that this macro
> includes zone->watermark_boost.  We need to reset zone->watermark_boost
> first.  Otherwise the watermarks will be set inconsistently.
> 
> E.g. this could cause inconsistent values if the watermarks have been
> boosted, and then you change a sysctl which triggers
> __setup_per_zone_wmarks().
> 
> I strongly suspect this explains why I have seen slightly high watermarks.
> Suspicious-looking zoneinfo below - notice high-low != low-min.
> 
> Node 0, zone   Normal
>   pages free     74597
>         min      9582
>         low      34505
>         high     36900
> 
> https://unix.stackexchange.com/questions/525674/my-low-and-high-watermarks-seem-higher-than-predicted-by-documentation-sysctl-vm/525687
> 
> Signed-off-by: Alan Jenkins <alan.christopher.jenkins@gmail.com>
> Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external
>                       fragmentation event occurs")
> Cc: stable@vger.kernel.org

Either way

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

