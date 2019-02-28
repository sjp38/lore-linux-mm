Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32E06C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:34:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F16EF2183F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:34:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F16EF2183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99E8C8E0003; Thu, 28 Feb 2019 06:34:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94DD38E0001; Thu, 28 Feb 2019 06:34:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 866D78E0003; Thu, 28 Feb 2019 06:34:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4BC8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 06:34:21 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i20so8373547edv.21
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:34:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lzr4fROOkhhmJWDsK5pmC/ulFcOfSSmtBYTv8qUtVZo=;
        b=l3fxDQAAiObUxC1cwj0p8dehLnSYLj4YqPZNyjgQi9tFKKhyF63F2Bsbrtp5IM078p
         m3io5OIfzqw6q5cBIRoTF2cbQW7C8tBp6s4QYcmkRH1gin8eqAAllTfCOaOL60+ceuwo
         ARnB0pcvjwGBn7q9tvUko0sTiEBDGXj0zEwtD/pZms4HWuBnSlEve2CxxO6ZNyHWtW1l
         HNYtMcrB6V7w9+3mabzPA0Ro9dAzBtt7EJh4NbzOSR5x2MBfIGv6LNpburtV5RoYw8Gd
         dz1VwmzokdR5TFBvzvwet6QrOi8LtFflrtPgSFWpU8RYEgM5QWPvevYzryvMKRag1CoO
         Asag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.106 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: AHQUAuZRlzfsz94Ff2BagRf6cqqjS4TCi1RdD9mlhjntha2ZKdkfJQFY
	uAAaoegXK0WQncIrjCfSMFrY0/g4Ol+Istz85uVPwlN2xLFKbH0DSz0D7eNHLR24MjpdutMDbLv
	eEqMqszmZp5T4xNtfZuKUMls/puSFHK/mp3eTzVmuHgWdqgb9ymD6fvdq3UCSpVdBIA==
X-Received: by 2002:a17:906:a48b:: with SMTP id m11mr5140487ejz.36.1551353660844;
        Thu, 28 Feb 2019 03:34:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia3BlKZH0Te+3TOYp5UbLltQXwiQEw3Un0srNwf5DpGYaV0n3qaSAE4bGZpg2mElEr4IGkO
X-Received: by 2002:a17:906:a48b:: with SMTP id m11mr5140454ejz.36.1551353660100;
        Thu, 28 Feb 2019 03:34:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551353660; cv=none;
        d=google.com; s=arc-20160816;
        b=zcrmMNNrVbKj/l8y+A4gS7sIp7TwGK+6wViT6iLkFPvehhusJcpkjYPaSdyRiKeRkI
         bgm48W1oo01I00lk3rajkBiDWpg+8EP4SHlegS3v2tWGf0BkzdhVBdqdVklxGbislT8i
         8TK4qzTi9NQpu4V2fNJSe2kRjVSTZX39dMPby5JoeOXINBGT2dXVWLmtEx3/bX9IDREj
         JlwLyCIW0+G5fQB4A3pAYJBoitTwfnREETJ5Mn+KxP+MflpJrcHDS0YtlypJO2JWrMOc
         Wa6Mq76k65PvOzCrK4tiN37BBA0bJRGAw9CQvXhIufEU5hzrFTEuNgMkMxIaz+jl+c7A
         sgFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lzr4fROOkhhmJWDsK5pmC/ulFcOfSSmtBYTv8qUtVZo=;
        b=iuWolZ/FfSq01bljGpXt527/w5OzHRXE0xYyWCJhgMFqBEZ3Y/ddrMFQswjosb0f3a
         XLb2GtbCy9wA5YJ0RkkXGuGvHaf0iMmJkp6GpgO4jhWhrT6wpKSeqF7fsoESTX4fdrmG
         m8LYisw9x2JQXKTEPtA5pgboDEqC+N4T7hK1oeSnMsaflq3SzdSPLnu01L8rsh3eoPAW
         uKkAWDFCzRRazPjPqFAPOES6AHknerOqvx3BupPuuGy5pV2IzhVVv86+e8YpaJfOox/f
         996hoc5ZuEi1BZJf1hPt/MyT0UpgoJCfmBtF9ImAOSI3hrNx3qliU7JKgZMZCvaBvizK
         wP4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.106 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id m48si455450edd.347.2019.02.28.03.34.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 03:34:20 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.106 as permitted sender) client-ip=46.22.139.106;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.106 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id B54891C20D4
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:34:19 +0000 (GMT)
Received: (qmail 20082 invoked from network); 28 Feb 2019 11:34:19 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 28 Feb 2019 11:34:19 -0000
Date: Thu, 28 Feb 2019 11:34:18 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@surriel.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 4/4] mm/vmscan: remove unused lru_pages argument
Message-ID: <20190228113418.GG9565@techsingularity.net>
References: <20190228083329.31892-1-aryabinin@virtuozzo.com>
 <20190228083329.31892-4-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190228083329.31892-4-aryabinin@virtuozzo.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 11:33:29AM +0300, Andrey Ryabinin wrote:
> Since commit 9092c71bb724 ("mm: use sc->priority for slab shrink targets")
> the argument 'unsigned long *lru_pages' passed around with no purpose.
> Remove it.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

