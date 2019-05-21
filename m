Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 554D7C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 12:57:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CFC921773
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 12:57:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="akTuLbwy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CFC921773
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F0376B0007; Tue, 21 May 2019 08:57:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99F896B0008; Tue, 21 May 2019 08:57:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88E666B000A; Tue, 21 May 2019 08:57:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 682816B0007
	for <linux-mm@kvack.org>; Tue, 21 May 2019 08:57:12 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id y144so17640722ywg.16
        for <linux-mm@kvack.org>; Tue, 21 May 2019 05:57:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=T/AHbGrbWFUhevOXCGpUGCgyop6Di8UfE0ud1RTG1ps=;
        b=DgGL26anIdg4l4lCRcEnxvIN7b7IiR9v13W0l0tvfTD/QrlT+8saNtKTOmb2b2cIhG
         Z6PcbIMAlWxVkPu9ERiZjcgMTHJGYPXhhxDp6K9Bs4j05C2f/v2dNcxaVmM93L7arAG+
         0fB7xq3Lo54Akd1QMDfQBCLmRRsDaS0IWo/dF9k1D0ULkyuBNTxWSaO2bPWj/FB/+ue5
         1HQKE612IdZiWuJ/NuXqvGtK+7G8x5NoVBuwlxMmmJIPRNr5cfdtzQ1DvHUnb6llJQnE
         WB40X/AtxgWnpUbu77O9Fx5TR/rFWYFsgjADrMhXtaWVjNyPIsWH9YsU/Uw8kC20Wery
         4ksw==
X-Gm-Message-State: APjAAAVT2nbAv9HPrG7hTRBujwxrSnDWACeJDar+oum+NFMAG9eQCO7A
	IFJwZFpYIdxvj395DPNCk0W0TLKNP+kLU73wfE8DSYlaNjSdb/vRAxRii7XbnPpY+fj8+U6G3Tf
	IoGQyEGSQCFkAOZqA2przlywSdVWxZOmlREekPsVwb4EVvMJRxBxeOb3WpB4NJJiVxg==
X-Received: by 2002:a81:9250:: with SMTP id j77mr8912192ywg.142.1558443432069;
        Tue, 21 May 2019 05:57:12 -0700 (PDT)
X-Received: by 2002:a81:9250:: with SMTP id j77mr8912173ywg.142.1558443431256;
        Tue, 21 May 2019 05:57:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558443431; cv=none;
        d=google.com; s=arc-20160816;
        b=V037yf7DNJHiinPYhgNV6NvVQQKyCpyU0uTTKwKSxyolYlXItGZgO+UnFrCwmGIt8K
         dXw0F94wGbrAbrTclfgmoK7whYaTa5OSbYeZwe9rg0V+GXSyPFRWlPuyMI6bv3qnVEbi
         p0goXYxvHXW2CVL2DdOKLb+Bu/ks+m6nqDJP/RrmGTS8fnFZLfSCyJYykmCP7rSihArw
         Hxx30Ig7AkoNaHcbLRSGsei5UPICJRzU8QMFfZIUVsV0nYaVROEf46T2lzDAq4DmGRAu
         WBRnO55srOPOLjlr3RgLBezM377Lpf4pywyeCz4Px3nWlZKsxnFRIuWhia/huD78VzsH
         avoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=T/AHbGrbWFUhevOXCGpUGCgyop6Di8UfE0ud1RTG1ps=;
        b=CDsSrifYABeLOtzECenNaIYrHUlIl1PpOrbAvThaRil26Um5dAGy5HOlmWIUALPUwH
         +bcGc4ZBKdHZnVsoz20icsRwM8SF0N+5O8QTLXCinG9scrz5hhd+z0/+nqWAWEblnly/
         f5dPn3Ch5+VWyQ3nMviPqx0m97y7a9ZSO/k3AcvRlaRv5PIqNuh6jtaF6y8IxVUZAE3b
         yEttI0uYYN4XqOkVpHWxEfB+qi+WKTA9K8xIFOCPlPN+8wuBLxlKRtkSINnkuFJ+wEzy
         knPdzuorf9a1JL5Gb7Pq/UflqVEbxzPwBsbCTN2TuLqXvPKNd0520GumKe4dfFeFKISi
         5M1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=akTuLbwy;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f10sor10518667ywk.109.2019.05.21.05.57.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 05:57:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=akTuLbwy;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=T/AHbGrbWFUhevOXCGpUGCgyop6Di8UfE0ud1RTG1ps=;
        b=akTuLbwyJU5RN+ZX+1XrhOSjd4MciXH7phKiqrpcWAfdgPdU7zImpJSRTClYg+LnD8
         f72NWpwZAcJEJWW1W6buISDdzYyEyDIrp3SR3YVvwuoBzzqiLJ9PEwNNgqHybiKQNlMJ
         2iG330vUDmL9jD5pERSkZpkiDcA8RywSlF0+wux3E+aw+YbeSJtlt4GB0itIQzksJcGg
         Ox4p2HDQsBtjjFQFbP2hmcPMJ6riI3suMWoQIGSBSXyT4sy107pII8ukRM5RFzlrR0H7
         IR44iZACqmT/AbXbIN0ZY4HXhfvGYsyfHLNXmBvTIPjUwP/LNaI4afQeK3TCCWZpsHCl
         1cnQ==
X-Google-Smtp-Source: APXvYqw2hO53tPry9V/J/vvYsaoh0I6dNYkejzO13Jx59B3H/C01BT/91Z/hSGJB2ngnVnWoIhnH/4HGgY7h5wywf4c=
X-Received: by 2002:a81:5ec3:: with SMTP id s186mr39737429ywb.308.1558443430631;
 Tue, 21 May 2019 05:57:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190520035254.57579-1-minchan@kernel.org> <dbe801f0-4bbe-5f6e-9053-4b7deb38e235@arm.com>
 <CAEe=Sxka3Q3vX+7aWUJGKicM+a9Px0rrusyL+5bB1w4ywF6N4Q@mail.gmail.com> <1754d0ef-6756-d88b-f728-17b1fe5d5b07@arm.com>
In-Reply-To: <1754d0ef-6756-d88b-f728-17b1fe5d5b07@arm.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 21 May 2019 05:56:59 -0700
Message-ID: <CALvZod6ioRxSi7tHB-uSTxN1-hsxD+8O3mfFAjaqdsimjUVmcw@mail.gmail.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Joel Fernandes <joel@joelfernandes.org>, 
	Suren Baghdasaryan <surenb@google.com>, Daniel Colascione <dancol@google.com>, Sonny Rao <sonnyrao@google.com>, 
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 7:55 PM Anshuman Khandual
<anshuman.khandual@arm.com> wrote:
>
>
>
> On 05/20/2019 10:29 PM, Tim Murray wrote:
> > On Sun, May 19, 2019 at 11:37 PM Anshuman Khandual
> > <anshuman.khandual@arm.com> wrote:
> >>
> >> Or Is the objective here is reduce the number of processes which get killed by
> >> lmkd by triggering swapping for the unused memory (user hinted) sooner so that
> >> they dont get picked by lmkd. Under utilization for zram hardware is a concern
> >> here as well ?
> >
> > The objective is to avoid some instances of memory pressure by
> > proactively swapping pages that userspace knows to be cold before
> > those pages reach the end of the LRUs, which in turn can prevent some
> > apps from being killed by lmk/lmkd. As soon as Android userspace knows
> > that an application is not being used and is only resident to improve
> > performance if the user returns to that app, we can kick off
> > process_madvise on that process's pages (or some portion of those
> > pages) in a power-efficient way to reduce memory pressure long before
> > the system hits the free page watermark. This allows the system more
> > time to put pages into zram versus waiting for the watermark to
> > trigger kswapd, which decreases the likelihood that later memory
> > allocations will cause enough pressure to trigger a kill of one of
> > these apps.
>
> So this opens up bit of LRU management to user space hints. Also because the app
> in itself wont know about the memory situation of the entire system, new system
> call needs to be called from an external process.
>
> >
> >> Swapping out memory into zram wont increase the latency for a hot start ? Or
> >> is it because as it will prevent a fresh cold start which anyway will be slower
> >> than a slow hot start. Just being curious.
> >
> > First, not all swapped pages will be reloaded immediately once an app
> > is resumed. We've found that an app's working set post-process_madvise
> > is significantly smaller than what an app allocates when it first
> > launches (see the delta between pswpin and pswpout in Minchan's
> > results). Presumably because of this, faulting to fetch from zram does
>
> pswpin      417613    1392647     975034     233.00
> pswpout    1274224    2661731    1387507     108.00
>
> IIUC the swap-in ratio is way higher in comparison to that of swap out. Is that
> always the case ? Or it tend to swap out from an active area of the working set
> which faulted back again.
>
> > not seem to introduce a noticeable hot start penalty, not does it
> > cause an increase in performance problems later in the app's
> > lifecycle. I've measured with and without process_madvise, and the
> > differences are within our noise bounds. Second, because we're not
>
> That is assuming that post process_madvise() working set for the application is
> always smaller. There is another challenge. The external process should ideally
> have the knowledge of active areas of the working set for an application in
> question for it to invoke process_madvise() correctly to prevent such scenarios.
>
> > preemptively evicting file pages and only making them more likely to
> > be evicted when there's already memory pressure, we avoid the case
> > where we process_madvise an app then immediately return to the app and
> > reload all file pages in the working set even though there was no
> > intervening memory pressure. Our initial version of this work evicted
>
> That would be the worst case scenario which should be avoided. Memory pressure
> must be a parameter before actually doing the swap out. But pages if know to be
> inactive/cold can be marked high priority to be swapped out.
>
> > file pages preemptively and did cause a noticeable slowdown (~15%) for
> > that case; this patch set avoids that slowdown. Finally, the benefit
> > from avoiding cold starts is huge. The performance improvement from
> > having a hot start instead of a cold start ranges from 3x for very
> > small apps to 50x+ for larger apps like high-fidelity games.
>
> Is there any other real world scenario apart from this app based ecosystem where
> user hinted LRU management might be helpful ? Just being curious. Thanks for the
> detailed explanation. I will continue looking into this series.

Chrome OS is another real world use-case for this user hinted LRU
management approach by proactively reclaiming reclaim from tabs not
accessed by the user for some time.

