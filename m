Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 513E4C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:19:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1829C222A1
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:19:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1829C222A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC4288E0003; Thu, 14 Feb 2019 05:19:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A71A78E0001; Thu, 14 Feb 2019 05:19:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 961268E0003; Thu, 14 Feb 2019 05:19:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5EC8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:19:45 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o14so288307edr.15
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:19:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=T9skCINMXqm8znyDp5bc/RS9lXiK/zgG6MfNGEn7tFY=;
        b=WBp+g8JU0Nlxft6Iw0yl5okoYG8Y8FRZ3cftC2GY/8YTSMm5ZYKSxef7BIZOQeUxdg
         VYZ2wOJtVWf2FGyfZf3nl5FBJn/RSj1/KmAi5/QhTy/GqpdKxM9OFDWR2rOrsH9bvGnB
         ro1XTnYTBYt3p+Y4RSugi3Zy3VK3vEIDh/at03fZYrEj9EmhLSTfyo2O+U2/zDKva7zn
         MMmLM2Rzf/a2htBfkn/eei7yMkK5jzkIQDvCkdiVdRaEfuOBKGRcEuDR+MmhKSukDem/
         VhqhIiTqK/95fftt+7X6Rim8D8h7qnUEw+OsKuHRwh+U67Yci/ZbHqXvttr9K/YtWmda
         3w/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: AHQUAua82+B38YzF0nHmJ66MXetEONz9uC+6AX+M2fxtjwuiwyQcrpx5
	Bm6hqHEPXO/12fYsA00Q0OD1/K5Bi9Z11w+Fhe9g7UlUJ5NX9TJPAWSq2PdqjZ1k5LWTwcYOPsE
	9hDYCKD/acfOQFcZxTaJLpaOCSdJ/x1PADnsy347zRovtqJyasGmf8by1DiGUztypng==
X-Received: by 2002:a50:8f86:: with SMTP id y6mr2490816edy.131.1550139584711;
        Thu, 14 Feb 2019 02:19:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib7rMSEoZLG8phRkLHLdTOg2hL+ralOqcf4Oxk3CYn3CUNYUa0Usa2bB31XPsBW6f9iOVYc
X-Received: by 2002:a50:8f86:: with SMTP id y6mr2490767edy.131.1550139583863;
        Thu, 14 Feb 2019 02:19:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550139583; cv=none;
        d=google.com; s=arc-20160816;
        b=gm73dfY24HNHeQPOsqPI/7oXvCdVXGLKaNiTSxyG/U5ELJWxXBx97TSAcYZVtq0dPd
         rhuOPCGUs30XX+4nS4FDHd8+reof5Au40MgOMyg+I54DTL03LAcqET/V1w85fMPx9kbt
         RPjWqZpqGlN7lqMBqueEtHwfKBgwh2rb+lFaa3B48BQqyle7MO75iCSoE/Mw2jrYkJJ7
         wdxTNlgWDvAHkxv66DGch0v7fG8lLt1uW2gAZllFIq5OHjuZJz1ifqWNIWlfJ0ioQyJf
         VWhM/eXV7bD7Xqcm/xFQhwf97eQC/gqUH6435jufIi2muHKXAVu4Ds8T11r1rjA1PoVG
         1+xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=T9skCINMXqm8znyDp5bc/RS9lXiK/zgG6MfNGEn7tFY=;
        b=Lyzrzn2d88fPlI5bwdoib/0VLfwTKLqFpct8II2BP+QCHUqfR2Mv62WdQ+aavi/G5s
         BXUzz+py+5tqapgsf6rxVClqgBzd51s+50w0+4PJ8MthxzBDwVNyA5TMVFS3Oq7GJcgg
         h1uhriV+A/UuJcZaygB155T6tlDGDt16gudXhLevh1yIgaJVWoT05h7krcYQY3UzGvkC
         tn2VdsdCFJsLcAwvyeS7qOVrFV9ebTANgn7ABKAgwtRKJsHAxzdwDRh1wawMsWdq/v2j
         l5MX7uAJU3uRtyrEn/a7+5Q6je9HY5/tEAOtMwDUm1ZRYJdy//l6z+qlwdp8jCxi1IN/
         ju7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l1si909477edn.1.2019.02.14.02.19.43
        for <linux-mm@kvack.org>;
        Thu, 14 Feb 2019 02:19:43 -0800 (PST)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 990DAEBD;
	Thu, 14 Feb 2019 02:19:42 -0800 (PST)
Received: from c02tf0j2hf1t.cambridge.arm.com (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 356B53F575;
	Thu, 14 Feb 2019 02:19:40 -0800 (PST)
Date: Thu, 14 Feb 2019 10:19:37 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Michal Hocko <mhocko@suse.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org,
	akpm@linux-foundation.org, kirill@shutemov.name,
	kirill.shutemov@linux.intel.com, vbabka@suse.cz,
	will.deacon@arm.com, dave.hansen@intel.com
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
Message-ID: <20190214101936.GD9296@c02tf0j2hf1t.cambridge.arm.com>
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <20190213112135.GA9296@c02tf0j2hf1t.cambridge.arm.com>
 <20190213153819.GS4525@dhcp22.suse.cz>
 <0b6457d0-eed1-54e4-789b-d62881bea013@arm.com>
 <20190214083844.GZ4525@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214083844.GZ4525@dhcp22.suse.cz>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 09:38:44AM +0100, Michal Hocko wrote:
> On Thu 14-02-19 11:34:09, Anshuman Khandual wrote:
> > On 02/13/2019 09:08 PM, Michal Hocko wrote:
> > > Are there any numbers to show the optimization impact?
> > 
> > This series transfers execution cost linearly with nr_pages from migration path
> > to subsequent exec access path for normal, THP and HugeTLB pages. The experiment
> > is on mainline kernel (1f947a7a011fcceb14cb912f548) along with some patches for
> > HugeTLB and THP migration enablement on arm64 platform.
> 
> Please make sure that these numbers are in the changelog. I am also
> missing an explanation why this is an overal win. Why should we pay
> on the later access rather than the migration which is arguably a slower
> path. What is the usecase that benefits from the cost shift?

Originally the investigation started because of a regression we had
sending IPIs on each set_pte_at(PROT_EXEC). This has been fixed
separately, so the original value of this patchset has been diminished.

Trying to frame the problem, let's analyse the overall cost of migration
+ execute. Removing other invariants like cost of the initial mapping of
the pages or the mapping of new pages after migration, we have:

M - number of mapped executable pages just before migration
N - number of previously mapped pages that will be executed after
    migration (N <= M)
D - cost of migrating page data
I - cost of I-cache maintenance for a page
F - cost of an instruction fault (handle_mm_fault() + set_pte_at()
    without the actual I-cache maintenance)

Tc - total migration cost current kernel (including executing)
Tp - total migration cost patched kernel (including executing)

  Tc = M * (D + I)
  Tp = M * D + N * (F + I)

To be useful, we want this patchset to lead to:

  Tp < Tc

Simplifying:

  M * D + N * (F + I) < M * (D + I)
  ...
  F < I * (M - N) / N

So the question is, in a *real-world* scenario, what proportion of the
mapped executable pages would still be executed from after migration.
I'd leave this as a task for Anshuman to investigate and come up with
some numbers (and it's fine if it's just in the noise, we won't need
this patchset).

Also note that there are ARM CPU implementations that don't need I-cache
maintenance (the I side can snoop the D side), so for those this
patchset introducing an additional cost. But we can make the decision in
the arch code via pte_mklazyexec().

We implemented something similar in arm64 KVM (d0e22b4ac3ba "KVM:
arm/arm64: Limit icache invalidation to prefetch aborts") but the
use-case was different: previously KVM considered all pages executable
though the vast majority were only data pages in guests.

-- 
Catalin

