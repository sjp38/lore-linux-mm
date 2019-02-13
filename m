Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2150C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 15:38:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89B32206C0
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 15:38:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89B32206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 189F28E0002; Wed, 13 Feb 2019 10:38:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1373E8E0001; Wed, 13 Feb 2019 10:38:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F40F08E0002; Wed, 13 Feb 2019 10:38:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id ACA438E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 10:38:21 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d9so1170965edl.16
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 07:38:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ukaeXo2L/IzM5J8ARA1DgwBS5A+tLshFUavJmqe9mbs=;
        b=X3YxHOU9G15wWr7w+WdqKXR/5WbTKl/n2o0BsmfeIg3amTuR2SXT06vFyx6SzjcOEC
         IJqz9nf2iYZFCB9heYcH8FnnTs4VLwDim0lp58PnUvs4nddHyKq15X3eK5lPW1grDwvP
         VmseIgEau+G1GJa1X62xfUXzyY6MYkh9+mjENtJww/cx97kfT4aA4ZXX5MiMuz35z3Vt
         E6xDfoCx61YsrMcxwrI7Vbe1Q/VpeBSsGfLXaWHMiJkWGKCCndasZBAlolEKSxCDynxu
         q4cqwGUt6lDX/Kt4ZByOydeiMZv3idFcQiSc24CZauLqlmT89I4BdL+XElVGj67klGIk
         7CnA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: AHQUAuaw9S8dgQAcFbFP+s+hYHdeNbosLAX4KQIBwQk6szRh+bYOXqKy
	15QOq6y+L8/QAUbgi5o+EFB5NEwO7EqCWePPx+VWFDp16fA8F6lkymcxvDIxxwMcnnqMJ14xUsI
	DGjtqZoE7nAtvez/9mzSdJAUZbvxwuO9Fiw5UQsV2jxQNkMCROAFOnHDn+5fUVHa9nA==
X-Received: by 2002:a17:906:64d9:: with SMTP id p25mr823942ejn.90.1550072301260;
        Wed, 13 Feb 2019 07:38:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IarDTj5Tx7FzZ1kUs5nlGCQ9UkKFdO3tV0DbVi6mg9X44VTDfcxmeqP7LPYmu9sgmuvEVg9
X-Received: by 2002:a17:906:64d9:: with SMTP id p25mr823889ejn.90.1550072300328;
        Wed, 13 Feb 2019 07:38:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550072300; cv=none;
        d=google.com; s=arc-20160816;
        b=emTC9e6zRsGAe/kHHSe8cWflLePNG7c/jgXUJUrV6RxkJSGAdi5o1Jew/XjR5z0NCn
         IK+V4HHJM1miSS3sFZMeuC5/YYaEER4Ai9o5bD8hb0AyF1P8ZQLl5qLp5AB16nhteiVX
         Ni0p4jo3Ue1OIaggevO4LuDmXFJVmzAW4U47Xt1F69AZx2mP8UnWh4CPt+k2BW87EW5K
         wjH0MJ/KFqd5KD9aXAoPY8vjWG8EsHnWA7lpNHgHnup25R0mRFaN0SHAYUqDkPqylQV0
         Z79tjgDeBPDImbBpuUXzEh504D4Z+NVk7Y2FEBz7GNaTFueODVCVgu271Any6LCJ03ps
         e1nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ukaeXo2L/IzM5J8ARA1DgwBS5A+tLshFUavJmqe9mbs=;
        b=cWiyQXlDBmCUuMw8nyyXGNE9Ggqcc9fiApHFzktgqFICfS7ZVxtKA3TVUlxO6WdUr1
         x3EMkVhUSe+LoOP0BH/Rbt9ttDKy3/pKXHhoxoBdUWMASiumMK+R/X+R3YHorUiPjfs9
         MC5vIcTVcU45RhHHG8IE1fLCuMvlOixyy84as6rIX7v2r1sCVYx8g4aZMZmD3qKdH75l
         yWOqICOp8kRY3lR3LTCqjJ3b6KDXEPR+goFQo+kAVVTtKy0kOb+T5eodgHFNHYXrcFji
         maF+kuBa4VhEl0X35fGS0cvOJklnQTTrnpJY9q2fPWIJIkuwzyuusczx3r4gS7hVFmCn
         vPQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j12si7270180ejs.120.2019.02.13.07.38.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 07:38:20 -0800 (PST)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AA21EAD60;
	Wed, 13 Feb 2019 15:38:19 +0000 (UTC)
Date: Wed, 13 Feb 2019 16:38:19 +0100
From: Michal Hocko <mhocko@suse.com>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org,
	akpm@linux-foundation.org, kirill@shutemov.name,
	kirill.shutemov@linux.intel.com, vbabka@suse.cz,
	will.deacon@arm.com, dave.hansen@intel.com
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
Message-ID: <20190213153819.GS4525@dhcp22.suse.cz>
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <20190213112135.GA9296@c02tf0j2hf1t.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213112135.GA9296@c02tf0j2hf1t.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-02-19 11:21:36, Catalin Marinas wrote:
> On Wed, Feb 13, 2019 at 01:36:27PM +0530, Anshuman Khandual wrote:
> > Setting an exec permission on a page normally triggers I-cache invalidation
> > which might be expensive. I-cache invalidation is not mandatory on a given
> > page if there is no immediate exec access on it. Non-fault modification of
> > user page table from generic memory paths like migration can be improved if
> > setting of the exec permission on the page can be deferred till actual use.
> > There was a performance report [1] which highlighted the problem.
> [...]
> > [1] http://lists.infradead.org/pipermail/linux-arm-kernel/2018-December/620357.html
> 
> FTR, this performance regression has been addressed by commit
> 132fdc379eb1 ("arm64: Do not issue IPIs for user executable ptes"). That
> said, I still think this patch series is valuable for further optimising
> the page migration path on arm64 (and can be extended to other
> architectures that currently require I/D cache maintenance for
> executable pages).

Are there any numbers to show the optimization impact?
-- 
Michal Hocko
SUSE Labs

