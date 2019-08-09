Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18171C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 17:57:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBAEC21743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 17:57:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBAEC21743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82D8C6B027E; Fri,  9 Aug 2019 13:57:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 801FB6B0292; Fri,  9 Aug 2019 13:57:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F2556B02BB; Fri,  9 Aug 2019 13:57:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 237476B027E
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 13:57:10 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id c14so1472088wml.5
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 10:57:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tL5tZxLa+RzvMcGkhmFt47LHLw70KZgGHl3uiuIM6xY=;
        b=LFepOd4E29I818vv4J9rmH+rittOMCy4yL0r1sdCD6qU9M/hmDHrrNeQRNBA4sqWja
         ANtHEnZunZCFxDoGsRuAZWSk/+m+OySJj/NoCFiNHvKdfKoHPQiaySneyXm/hWVnGtvS
         KH1/uFcxsTfxbLVFaCNBHbchjECht6Dydko8iWhRfE83DiywgPTSZncxlYXvBIWQ57pu
         +ZgAO7xQkq6uKZrEKVV4Gpse08ZLlnInSmrJNl9wpaL51ugc2HS49cpqFKqfJW/eOAGN
         KDtaYQu1xAMVOLC1tvXKCnyxt7ki9UGL0SMwBPMEj4Q40/UjQgflq70ZZGrcQA0ApeOg
         vteA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.191 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAWAw4LuQx2bqObndXuHMKoE0qodOi2CJjSIpS9MpTdqxRIyZg7e
	MfwQUflKEGYpleGUD060hy7lyIuYZe5+f2fPySKb3/YuL0Rol8VUxm7DukT4umfupQFLyEk32nl
	24Ug4GLXAZwXwXYLsqWtbVbcOmlTK7k/2U69egM+JboJ43ZgmlZsbLuT3KG+kPleuBQ==
X-Received: by 2002:adf:f481:: with SMTP id l1mr19366278wro.123.1565373429713;
        Fri, 09 Aug 2019 10:57:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5OtUIGq/B7Kkab84vsLm3X/3BhXhheoQtNemP0ZN6Vfxd5pnqx9HKIOXHfI+Vg369Ld+p
X-Received: by 2002:adf:f481:: with SMTP id l1mr19366232wro.123.1565373428925;
        Fri, 09 Aug 2019 10:57:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565373428; cv=none;
        d=google.com; s=arc-20160816;
        b=GevtHkcVQQp368X5LEl6giPi5dShlU3d1Axz1yKifJZaizLTDnFWfQHWMtwyQbK329
         8t5uZ/y7RiJl24BtUHg4CoAfccebSSsRkgy7d/4Tdn5oC/eqqfEE33VLnb/lTDIzQzE2
         Bb8nY5wAfiyrXzaGngDcW12m+eGKuF5XL4mY/y4wpa/0wQs1TSrM1ocgf6CgEvPYUe3T
         98UCqKX8qjJxeuEo/t5d/jDEm1VsuzHtDz6cK3SbFJ0MgoPWZYlz0tjdMJ8AO6WSyhF9
         Ch6REmDngMHDPxlsCCjSHLZKhMgpJA2I3OKk93fFAcEkeDoA/GA2KhPczvMiV8Of/PSV
         o4TA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tL5tZxLa+RzvMcGkhmFt47LHLw70KZgGHl3uiuIM6xY=;
        b=qf2Ik64OcnOMDb1oSgNtcody68UPVCUUDBZLK/eeQ2vxhU4XssytVRa1i9l42KDMcd
         ebVHlxcNZOt9XeWnjEYFrXn+0KxybWDgYTC30drR2jVexGFN/e5mkvNvH3AJple7cMvR
         jui0r/p5rdtZyyJV3TOSvwdn93PqJyKjQYym9EjOGQGh/FApp7ZSASrfQodLakmb42qZ
         8WSOlpieBAbqOISEtXHS1HEcdgoXoys9802ZNN7PRdlvf0Bg52z/UMIyonKA1sYth0u6
         rIXkfvZceuxLm5CQBPQ1T/CRegM32nHfCDcXselh2ctsbf6QMmYWVQ00paX73gA4c/ue
         CgBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.191 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp23.blacknight.com (outbound-smtp23.blacknight.com. [81.17.249.191])
        by mx.google.com with ESMTPS id o137si4376571wme.39.2019.08.09.10.57.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 10:57:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.191 as permitted sender) client-ip=81.17.249.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.191 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp23.blacknight.com (Postfix) with ESMTPS id 84DA4B86DE
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:57:08 +0100 (IST)
Received: (qmail 23304 invoked from network); 9 Aug 2019 17:57:08 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.18.93])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 9 Aug 2019 17:57:08 -0000
Date: Fri, 9 Aug 2019 18:57:06 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC PATCH] mm: drop mark_page_access from the unmap path
Message-ID: <20190809175706.GO2739@techsingularity.net>
References: <20190729082052.GA258885@google.com>
 <20190729083515.GD9330@dhcp22.suse.cz>
 <20190730121110.GA184615@google.com>
 <20190730123237.GR9330@dhcp22.suse.cz>
 <20190730123935.GB184615@google.com>
 <20190730125751.GS9330@dhcp22.suse.cz>
 <20190731054447.GB155569@google.com>
 <20190731072101.GX9330@dhcp22.suse.cz>
 <20190806105509.GA94582@google.com>
 <20190809124305.GQ18351@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190809124305.GQ18351@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 02:43:24PM +0200, Michal Hocko wrote:
> On Tue 06-08-19 19:55:09, Minchan Kim wrote:
> > On Wed, Jul 31, 2019 at 09:21:01AM +0200, Michal Hocko wrote:
> > > On Wed 31-07-19 14:44:47, Minchan Kim wrote:
> [...]
> > > > As Nick mentioned in the description, without mark_page_accessed in
> > > > zapping part, repeated mmap + touch + munmap never acticated the page
> > > > while several read(2) calls easily promote it.
> > > 
> > > And is this really a problem? If we refault the same page then the
> > > refaults detection should catch it no? In other words is the above still
> > > a problem these days?
> > 
> > I admit we have been not fair for them because read(2) syscall pages are
> > easily promoted regardless of zap timing unlike mmap-based pages.
> > 
> > However, if we remove the mark_page_accessed in the zap_pte_range, it
> > would make them more unfair in that read(2)-accessed pages are easily
> > promoted while mmap-based page should go through refault to be promoted.
> 
> I have really hard time to follow why an unmap special handling is
> making the overall state more reasonable.
> 
> Anyway, let me throw the patch for further discussion. Nick, Mel,
> Johannes what do you think?
> 

I won't be able to answer follow-ups to this for a while but here is some
superficial thinking.

Minimally, you should test PageReferenced before setting it like
mark_page_accessed does to avoid unnecessary atomics.  I know it wasn't
done that way before but there is no harm in addressing it now.

workingset_activation is necessarily expensive. It could speculatively
lookup memcg outside the RCU read lock and only acquire it if there is
something interesting to lookup. Probably not much help though.

Note that losing the potential workingset_activation from the patch
may have consequences if we are relying on refaults to fix this up. I'm
undecided as to what degree it matters.

That said, I do agree that the mark_page_accessed on page zapping may
be overkill given that it can be a very expensive call if the page
gets activated and it's potentially being called in the zap path at a
high frequency. It's also not a function that is particularly easy to
optimise if you want to cover all the cases that matter. It really would
be preferably to have knowledge of a workload that really cares about
the activations from mmap/touch/munmap.

mark_page_accessed is a hint, it's known that there are gaps with
it so we shouldn't pay too much of a cost on information that only
might be useful. If the system is under no memory pressure because the
workloads are tuned to fit in memory (e.g. database using direct IO)
then mark_page_accessed is only cost. We could avoid marking it accessed
entirely if PF_EXITING given that if a task is exiting, it's not a strong
indication that the page is of any interest.  Even if the page is heavily
shared page and one user exits, the other users will keep it referenced
and prevent reclaim anyway. The benefit is too marginal too.

Given the definite cost of mark_page_accessed in this path and the main
corner case being tasks that access pages via mmap/touch/munmap (which is
insanely expensive if done at high frequency), I think it's reasonable to
rely on SetPageReferenced giving the page another lap of the LRU in most
cases (the obvious exception being CMA forcing reclaim). That opinion
might change if there is a known example of a realistic workload that
would suffer from the lack of explicit activations from teardown context.

-- 
Mel Gorman
SUSE Labs

