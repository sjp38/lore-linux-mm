Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6A01C282CE
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 16:43:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7196B20700
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 16:43:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7196B20700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DE2B6B0266; Fri,  5 Apr 2019 12:43:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08E556B0269; Fri,  5 Apr 2019 12:43:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBF7E6B026A; Fri,  5 Apr 2019 12:43:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D8986B0266
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 12:43:23 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e16so3568221edj.1
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 09:43:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=A/JSLKdd2LqT9YI1a7lGKg3fDMDMFibcqPZhv4MbRtY=;
        b=XwxanIMb0+9hFTA6F1dyHZNeSTHRDVSIn5O7ZJTP94H6qupmWDf4ceVJlihuu8bWeq
         PkiENTh1mtcCjz6+fLsOtvFvqRcokv9Guiniv3oEiSC4zw84CFPxglsmczugJg3fqLKb
         khhKSsldMawq8gumC/2mUkgGu/DggyxSTZVDuHgAFO7B3XMxpPDXBHctnX+5DSDJ57gK
         kWHDKlmAYNUwKW5Z36b9vNraw78+ugqSIhAkQXXQL8VnOl14nh1FhD/Q8a3/swBW36M+
         0BwmPfvHT4kDzYD8GbJtNM85N75X4R2zfbs1XwFus783T04Us6B2WrTFwF28F43GOqrz
         6cag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVi2fnkV+QzNFxCdgFpSFmxoHdM6g0qzfawDnPoh7dCuhd7ZL35
	Min3RR9LtghKlRayhJ7MOtrI4kRqrQfrsphqE0a3QA1U7qSCPDplohc8Wml3R2EnnGaa2DNlNbC
	9ZwatEK7pJc+EGzZiHWKZXxOPF7fTJunUnv1GMA/lm5cPsXHpf6J4JkkKq5CE8ibmHw==
X-Received: by 2002:a17:906:b202:: with SMTP id p2mr7893069ejz.266.1554482603158;
        Fri, 05 Apr 2019 09:43:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztDBuIe7SRCY9zWlzxizO/HPNZ4cz+wKx56zbyvNM5sqr5Ws2XCmOXBD3kGLYZ61yti4Pw
X-Received: by 2002:a17:906:b202:: with SMTP id p2mr7893034ejz.266.1554482602260;
        Fri, 05 Apr 2019 09:43:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554482602; cv=none;
        d=google.com; s=arc-20160816;
        b=HP5dyNAb37L7qHM6plmxy2QB5djMQuQCotzMu6keyVooNRP6hybWw9jf92sNu5rQie
         7Yi8FW3fh/u+q0CYkXMrXQzMTHJ96SVJcIRu606jCxIRf4+lpe98D5Gy7GeKr2mHe/gK
         X0Co6e8WUiR/JM+AoAEpqrqI0/GWlvE9R2+badQmYLAnbtV/lW3n1QoD+UKQuDyh5+1i
         ufN1+DbC4tCmYMTXi2d+uQhKbuGzvjGdQIBmi/MkhzGJsQQFXWOTM92VzfqdDAyVyAON
         VLTpKjA4IvRHQ8nE90KLEpRYsTDC79UbCHpnEeSdMfi81prppubY4dUoEGW3xwPf6in+
         V8AQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=A/JSLKdd2LqT9YI1a7lGKg3fDMDMFibcqPZhv4MbRtY=;
        b=SO8LRFt3Jfipksgd5DT89UmMgd8FkqsPN4MyF2anRolfIfgKKYeXBGHVwhrOde8XDl
         KCoActseyoS0UP7ksB0zFn3np2uKHtWHLzhODrgHuC7uo6gHgeDfi71+LgTrUfnSEtpR
         R1fTYucYWQrtHhS7Pfkxk/8F8hOhYLEiLVWkNaKZcUtGyxagLWa3kiiWS4/3vyZUTIGH
         KrS/YiSCwLYfpLhHZbzSDsZUKfCRXQjpBPs2iRe20gq+rs/P2m8pZAYH9WrPWiPTO9ap
         rbudC6LiqTP96PgxC6EduX/bMyA9pgthlo7bFbDr5Kaqj0xou03iU8rMXsOqI3aEpzYx
         2CyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g7si5111369ejk.311.2019.04.05.09.43.21
        for <linux-mm@kvack.org>;
        Fri, 05 Apr 2019 09:43:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 03EAE168F;
	Fri,  5 Apr 2019 09:43:21 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 14B143F68F;
	Fri,  5 Apr 2019 09:43:18 -0700 (PDT)
Date: Fri, 5 Apr 2019 17:43:16 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Qian Cai <cai@lca.pw>,
	akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org,
	rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
Message-ID: <20190405164316.GJ4906@arrakis.emea.arm.com>
References: <20190327005948.24263-1-cai@lca.pw>
 <20190327084432.GA11927@dhcp22.suse.cz>
 <20190327172955.GB17247@arrakis.emea.arm.com>
 <20190327182158.GS10344@bombadil.infradead.org>
 <20190328145917.GC10283@arrakis.emea.arm.com>
 <20190329120237.GB17624@dhcp22.suse.cz>
 <20190329161637.GC48010@arrakis.emea.arm.com>
 <20190401201201.GJ28293@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190401201201.GJ28293@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 01, 2019 at 10:12:01PM +0200, Michal Hocko wrote:
> On Fri 29-03-19 16:16:38, Catalin Marinas wrote:
> > On Fri, Mar 29, 2019 at 01:02:37PM +0100, Michal Hocko wrote:
> > > On Thu 28-03-19 14:59:17, Catalin Marinas wrote:
> > > [...]
> > > > >From 09eba8f0235eb16409931e6aad77a45a12bedc82 Mon Sep 17 00:00:00 2001
> > > > From: Catalin Marinas <catalin.marinas@arm.com>
> > > > Date: Thu, 28 Mar 2019 13:26:07 +0000
> > > > Subject: [PATCH] mm: kmemleak: Use mempool allocations for kmemleak objects
> > > > 
> > > > This patch adds mempool allocations for struct kmemleak_object and
> > > > kmemleak_scan_area as slightly more resilient than kmem_cache_alloc()
> > > > under memory pressure. The patch also masks out all the gfp flags passed
> > > > to kmemleak other than GFP_KERNEL|GFP_ATOMIC.
> > > 
> > > Using mempool allocator is better than inventing its own implementation
> > > but there is one thing to be slightly careful/worried about.
> > > 
> > > This allocator expects that somebody will refill the pool in a finit
> > > time. Most users are OK with that because objects in flight are going
> > > to return in the pool in a relatively short time (think of an IO) but
> > > kmemleak is not guaranteed to comply with that AFAIU. Sure ephemeral
> > > allocations are happening all the time so there should be some churn
> > > in the pool all the time but if we go to an extreme where there is a
> > > serious memory leak then I suspect we might get stuck here without any
> > > way forward. Page/slab allocator would eventually back off even though
> > > small allocations never fail because a user context would get killed
> > > sooner or later but there is no fatal_signal_pending backoff in the
> > > mempool alloc path.
> > 
> > We could improve the mempool code slightly to refill itself (from some
> > workqueue or during a mempool_alloc() which allows blocking) but it's
> > really just a best effort for a debug tool under OOM conditions. It may
> > be sufficient just to make the mempool size tunable (via
> > /sys/kernel/debug/kmemleak).
> 
> The point I've tried to make is that you really have to fail at some
> point but mempool is fundamentally about non-failing as long as the
> allocation is sleepable. And we cannot really break that assumptions
> because existing users really depend on it. But as I've said I would try
> it out and see. This is just a debugging feature and I assume that a
> really fatal oom caused by a real memory leak would be detected sooner
> than the whole thing just blows up.

I'll first push a patch to use mempool as it is, with a tunable size via
/sys/kernel/debug/kmemleak. I think the better solution would be a
rewrite of the metadata handling in kmemleak to embed it into the slab
object (as per Pekka's suggestion). However, I'll be on holiday until
the 15th, so cannot look into this.

Thanks.

-- 
Catalin

