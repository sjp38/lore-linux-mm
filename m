Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 131A2C31E40
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 10:48:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACF172166E
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 10:48:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACF172166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 179176B0003; Sat,  3 Aug 2019 06:48:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 129F96B0005; Sat,  3 Aug 2019 06:48:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F32F76B0006; Sat,  3 Aug 2019 06:48:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A77C56B0003
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 06:48:37 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f3so48419240edx.10
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 03:48:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YGhWdKUQaNvwoPzCp5TamotOjGsrfFaijz/jdHexwMI=;
        b=BY4TzrbMJT+iGXmsZkLQsxf9GSdaCsy0ovIIH+BNOFWKgAKBrNxvpDghtQrhNU5n0K
         RlN4XMbiHOMCKPnnbyStj7nZc2Z8VT4gHDoMTA7WZJy6m9EyY/4yRtrNrBYKTutCsacH
         7k1dGxh6BnsNQR35vu9owaUhhj3aSaqq1W9iVHmFrBHXB2fltQ+AUe8KZfyPN7QmGm0t
         IYjJPwCr70eayHUFFeQh33PlrXdvLDl58W2/3z+vQiEEH4iM/hgg/U04pTLDxnaOgTd5
         mtOCeOMHtxvPn4pSB58i9H6imOBMndF+mctsZwzoqtUb0kY7qV/8kSxWTXaSPlwtQGpE
         U26Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXt1MEg8mdJyTXSVxneErjCJzJYL5vdsCbcXurPVu9kE0j3jVVj
	WzXmnF5NUdRnGoDnjWL3ZqhkiRMueVJvGtMW2SQAIlJ5Fcy9EWbDJy0ODDAA1GRPwu0Xbo6jVUS
	zRLeD03gq8u3mv+k0ajrAoagwffuskWyI8uIZCiZQ8Pp3g0Ar4IWR606u1t2i5l/ymQ==
X-Received: by 2002:a50:ac24:: with SMTP id v33mr123758039edc.30.1564829317076;
        Sat, 03 Aug 2019 03:48:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEL9tXmTOFF5KRdja4yEMRFRYgfnRW4TdELCKZliKqqO9vLJ1vPszkzixxEMCaseRiBfee
X-Received: by 2002:a50:ac24:: with SMTP id v33mr123757983edc.30.1564829316078;
        Sat, 03 Aug 2019 03:48:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564829316; cv=none;
        d=google.com; s=arc-20160816;
        b=DzuAnckzFn5cjKBTBp3qob7/W70XYIfFwmibSAvTZ9SagsvFk2CPk++ofdhcXSVk5x
         xAGXKA89Oms29pVeN/4YteYVooCkx4ge1gYReeyLPU3snuIlY75hzdY11fKId7wa1he+
         lLHViOJvz69BhjQP1xL7iHI+ObcDrT3BefHupR8GMLvqEIMX+jXnmTUnTD122WKcEjR8
         Kvt8MveHn2ieMkK1Q6YlSaebpyxqJCM/VyQtnwLo/8oMbrtCk/uH4edrxEAeIPm/ckKp
         OcAtSf0mF78opeBGelEU0aneZM7Yx4rrNCRX/cY/iofTp1SYL5ff1efrAp4rUlRpqQJm
         9kVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YGhWdKUQaNvwoPzCp5TamotOjGsrfFaijz/jdHexwMI=;
        b=KRFYVultKkzCro+LyONBO6e3FjK6jyW5nnKSM5Wtx17RjdTpDkuC8C9pZwniek0RDE
         ljTZyhn2ZFXaJdsWZ0lzYV+EethIvCD84omXuTEnXXqhjM0mLDOXR63UoDOu/jtKEWGw
         LoWUWQ8JNlsXi7cG/TByFwrrG4zSCjA8l+rFfv5EAYlNnfN2q4KgjaIXRmjY1vqaIebb
         d5lDG1jVQJoJs7BCCjaOCGp7KU/vV/715ChHnRnBGvYksEYZI4hsiHcVRfbOu8yfUSwL
         zZpIWw5q8dnyZ72inkTWtiLPFkK22M+wZ9doxG5dzyWxHok5rbDbCCA8MKiY6UMny4b+
         0ukw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id 11si23002147ejy.102.2019.08.03.03.48.35
        for <linux-mm@kvack.org>;
        Sat, 03 Aug 2019 03:48:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BD29F344;
	Sat,  3 Aug 2019 03:48:34 -0700 (PDT)
Received: from iMac.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A39443F71F;
	Sat,  3 Aug 2019 03:48:33 -0700 (PDT)
Date: Sat, 3 Aug 2019 11:48:31 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>,
	Qian Cai <cai@lca.pw>
Subject: Re: [PATCH v2] mm: kmemleak: Use mempool allocations for kmemleak
 objects
Message-ID: <20190803104830.GB58477@iMac.local>
References: <20190727132334.9184-1-catalin.marinas@arm.com>
 <20190730130215.919b31c19df935cc5f1483e6@linux-foundation.org>
 <20190731154450.GB17773@arrakis.emea.arm.com>
 <20190801064153.GD11627@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801064153.GD11627@dhcp22.suse.cz>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 08:41:53AM +0200, Michal Hocko wrote:
> On Wed 31-07-19 16:44:50, Catalin Marinas wrote:
> > On Tue, Jul 30, 2019 at 01:02:15PM -0700, Andrew Morton wrote:
> > > On Sat, 27 Jul 2019 14:23:33 +0100 Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > > Add mempool allocations for struct kmemleak_object and
> > > > kmemleak_scan_area as slightly more resilient than kmem_cache_alloc()
> > > > under memory pressure. Additionally, mask out all the gfp flags passed
> > > > to kmemleak other than GFP_KERNEL|GFP_ATOMIC.
> > > > 
> > > > A boot-time tuning parameter (kmemleak.mempool) is added to allow a
> > > > different minimum pool size (defaulting to NR_CPUS * 4).
> > > 
> > > btw, the checkpatch warnings are valid:
> > > 
> > > WARNING: usage of NR_CPUS is often wrong - consider using cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc
> > > #70: FILE: mm/kmemleak.c:197:
> > > +static int min_object_pool = NR_CPUS * 4;
> > > 
> > > WARNING: usage of NR_CPUS is often wrong - consider using cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc
> > > #71: FILE: mm/kmemleak.c:198:
> > > +static int min_scan_area_pool = NR_CPUS * 1;
> > > 
> > > There can be situations where NR_CPUS is much larger than
> > > num_possible_cpus().  Can we initialize these tunables within
> > > kmemleak_init()?
> > 
> > We could and, at least on arm64, cpu_possible_mask is already
> > initialised at that point. However, that's a totally made up number. I
> > think we would better go for a Kconfig option (defaulting to, say, 1024)
> > similar to the CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE and we grow it if
> > people report better values in the future.
> 
> If you really want/need to make this configurable then the command line
> parameter makes more sense - think of distribution kernel users for
> example.

I doubt you'd have pre-built distribution kernels with kmemleak enabled.

> But I am still not sure why this is really needed. The initial
> size is a "made up" number of course. There is no good estimation to
> make (without a crystal ball). The value might be increased based on
> real life usage.

We had a similar situation with the early log buffer (before slab is
initialised), initially 400 which was good enough for my needs (embedded
systems) but others had entirely different requirements. A configurable
(cmdline, Kconfig) option would make it easier for people to change,
especially if coupled with a meaningful suggestion in dmesg.

Another option is to use the early log as an emergency pool after
initialisation instead of freeing it (it's currently __initdata) and
drop the mempool idea. I may give this a go, at least we only have a
single Kconfig option.

-- 
Catalin

