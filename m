Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E13CC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 21:29:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A290B2173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 21:29:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="KalgEU89"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A290B2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D6926B0007; Thu,  8 Aug 2019 17:29:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 161926B0008; Thu,  8 Aug 2019 17:29:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 001376B000A; Thu,  8 Aug 2019 17:29:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id BE5136B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 17:29:11 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id v49so64546346otb.6
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 14:29:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DzaZFkNgePDlVaXLESVKlCNNCGSeU4vRw8is94V5UdA=;
        b=QtBksVjrwbruqzCfUOcyj6oT4fuez7pcN0qxuxW5U+2R5Oqj0Q0h6dBHCC/3cKE6Zr
         S0BklPV6h+gFPt5zK+uqaI3bhMqadMcXjHRtePWGrb2Uw9SK04FMZ1Hwy4uMSnpzHA60
         nYL5Fq4n5jdQN10D86QFueevxlmiGPm7DH+HcA4TVTW+oOLJy7q7Jz0ApEeBz/XNHbrG
         vSAqbZW/gOEEQd4sKZceWO8pRVmPEGE/XNLbOoP44KUGqNXjm/SmC93/q1LGAg2+b6or
         023sDziO7DpkTNP2r6IgF3u5atPDXAD09NoFh1ilNJ9QniYrtdLKRNuZbTCUuYNrcgVk
         FYFg==
X-Gm-Message-State: APjAAAVP/j6iy9VsscVGtQiDsll/8hE2RGunQWuur6A2FiqEMP+HUQA1
	8OxWcniiSi1/hN23WA5x8kUZYr7LSIBVi4P4tlWyISUgtIz6P5rMiG72tCMnpPSr+ySddpDeMP4
	meyy1pQEZwHXAe1wl9WCtHqak0S0mMS9gvJrFxSiWoQ8gM/HhlzxlrLc+A2z4+fn5fg==
X-Received: by 2002:a05:6830:2148:: with SMTP id r8mr15580134otd.179.1565299751401;
        Thu, 08 Aug 2019 14:29:11 -0700 (PDT)
X-Received: by 2002:a05:6830:2148:: with SMTP id r8mr15580095otd.179.1565299750560;
        Thu, 08 Aug 2019 14:29:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565299750; cv=none;
        d=google.com; s=arc-20160816;
        b=gbLRP7+Yphu2oKCfVh9+8CjVDnAPUpTTBep3okIMjC78lHAVpf44q4POULcjrgLJXw
         /qlE3VYIrxWvuRrknKVF21uikSvUdEP7IhG3yfvXPUknQcdB/tXTMECtHlB0Dh0qBlFq
         ml0bZvo+r5bUEXOQQx2BUXpp5/ITdHPLhTRiDL6TYpVzcq0JEaHoiGJ+iSfS3McvMyUj
         jIkpi+POYqyYY9b+VRk9pvBWQIABmZli2f61/73a9/hTMZLZxMBZ5r6bEWolKlNF9a6l
         1AXE3izFGGKeAyF+QUbxhe5o7xQBOMrdOCUOtbd+wWNnhgfmqSuuZCOUcS6mLVi1QjWY
         Du1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DzaZFkNgePDlVaXLESVKlCNNCGSeU4vRw8is94V5UdA=;
        b=BFzKQPUlLnpGcX+Fv3K1BMQYk9mHdgv2qrGB1peuyoX47Saz9UdthLBXvKAdW+d9/N
         Bj2v6JwsuE1aMvoXpsUjs0UYnUdBH+BJTcCHaEGd5R1j1fuEBPp1VMR6UeWpoq2i6c2S
         X2D3VexqYkIqbb76qu2kbrnMgToEqdWNr6yoxJPFKDGECFtfNunD84qV7fqeU5M078Vj
         OKidrns0McGNQQzTIvekTAVPtWQzaIgfDV8jGaBxOmPy+/O+yRhPfbsz7PNYvkUo5tqN
         kQB28SzzZ4RtszvPDyRUpm8RVdQkJvjMhaQPcZbMtroYSOpAHaxpMAMGJ5h5JR/oTPmq
         +cqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KalgEU89;
       spf=pass (google.com: domain of almasrymina@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=almasrymina@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l184sor40896852oib.119.2019.08.08.14.29.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 14:29:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of almasrymina@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KalgEU89;
       spf=pass (google.com: domain of almasrymina@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=almasrymina@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DzaZFkNgePDlVaXLESVKlCNNCGSeU4vRw8is94V5UdA=;
        b=KalgEU890W2v3tdxmH2d7QO3pSxS/bg4+84+pquKaYaO7PNVW3CsGLHZm1QndUrNeZ
         Kes6GlrYRGfs39qNLpaAgPALwmTqr8BKMMDL5YAXSUayczbCfJxZvC8USF5mL1RKr9Sa
         eRAaFlqu14/WjkMYqOYUArE0eXX4bUHL0XyNPJl7FJW+2B2PgpuY+2Wdnir2QC1oGtI0
         dQ41Y0PXBN3BlV82y7AA5w0ORAvn6hNVFoAThakwZ8ytbFoZkjLxwp4YHOk8JYbHk2BI
         hbfDika9QTq8x7qLymoedawkBjxAXrS54uUhsJGvcAM/+Jd3EOiC5gLCctXcL7jWI7Du
         +VHQ==
X-Google-Smtp-Source: APXvYqzoPupi/hlxnLQxtV5HHOP2zFDbWqQf5PEzMQj2ePkR0PAEk3t0ZRroKEvH5zKdgxYIRQ3cyRsINwSRUJIJevY=
X-Received: by 2002:aca:39c4:: with SMTP id g187mr4300457oia.8.1565299749633;
 Thu, 08 Aug 2019 14:29:09 -0700 (PDT)
MIME-Version: 1.0
References: <20190808194002.226688-1-almasrymina@google.com> <528b37c6-3e7a-c6fc-a322-beecb89011a5@kernel.org>
In-Reply-To: <528b37c6-3e7a-c6fc-a322-beecb89011a5@kernel.org>
From: Mina Almasry <almasrymina@google.com>
Date: Thu, 8 Aug 2019 14:28:58 -0700
Message-ID: <CAHS8izPosKtqr3nJYEKz-jjG9iuTq_TPqE7yyN+2OQ5Gx8qUGw@mail.gmail.com>
Subject: Re: [RFC PATCH] hugetlbfs: Add hugetlb_cgroup reservation limits
To: shuah <shuah@kernel.org>
Cc: mike.kravetz@oracle.com, David Rientjes <rientjes@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, akpm@linux-foundation.org, 
	khalid.aziz@oracle.com, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	linux-kselftest@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 8, 2019 at 1:23 PM shuah <shuah@kernel.org> wrote:
>
> On 8/8/19 1:40 PM, Mina Almasry wrote:
> > Problem:
> > Currently tasks attempting to allocate more hugetlb memory than is available get
> > a failure at mmap/shmget time. This is thanks to Hugetlbfs Reservations [1].
> > However, if a task attempts to allocate hugetlb memory only more than its
> > hugetlb_cgroup limit allows, the kernel will allow the mmap/shmget call,
> > but will SIGBUS the task when it attempts to fault the memory in.
> >
> > We have developers interested in using hugetlb_cgroups, and they have expressed
> > dissatisfaction regarding this behavior. We'd like to improve this
> > behavior such that tasks violating the hugetlb_cgroup limits get an error on
> > mmap/shmget time, rather than getting SIGBUS'd when they try to fault
> > the excess memory in.
> >
> > The underlying problem is that today's hugetlb_cgroup accounting happens
> > at hugetlb memory *fault* time, rather than at *reservation* time.
> > Thus, enforcing the hugetlb_cgroup limit only happens at fault time, and
> > the offending task gets SIGBUS'd.
> >
> > Proposed Solution:
> > A new page counter named hugetlb.xMB.reservation_[limit|usage]_in_bytes. This
> > counter has slightly different semantics than
> > hugetlb.xMB.[limit|usage]_in_bytes:
> >
> > - While usage_in_bytes tracks all *faulted* hugetlb memory,
> > reservation_usage_in_bytes tracks all *reserved* hugetlb memory.
> >
> > - If a task attempts to reserve more memory than limit_in_bytes allows,
> > the kernel will allow it to do so. But if a task attempts to reserve
> > more memory than reservation_limit_in_bytes, the kernel will fail this
> > reservation.
> >
> > This proposal is implemented in this patch, with tests to verify
> > functionality and show the usage.
> >
> > Alternatives considered:
> > 1. A new cgroup, instead of only a new page_counter attached to
> >     the existing hugetlb_cgroup. Adding a new cgroup seemed like a lot of code
> >     duplication with hugetlb_cgroup. Keeping hugetlb related page counters under
> >     hugetlb_cgroup seemed cleaner as well.
> >
> > 2. Instead of adding a new counter, we considered adding a sysctl that modifies
> >     the behavior of hugetlb.xMB.[limit|usage]_in_bytes, to do accounting at
> >     reservation time rather than fault time. Adding a new page_counter seems
> >     better as userspace could, if it wants, choose to enforce different cgroups
> >     differently: one via limit_in_bytes, and another via
> >     reservation_limit_in_bytes. This could be very useful if you're
> >     transitioning how hugetlb memory is partitioned on your system one
> >     cgroup at a time, for example. Also, someone may find usage for both
> >     limit_in_bytes and reservation_limit_in_bytes concurrently, and this
> >     approach gives them the option to do so.
> >
> > Caveats:
> > 1. This support is implemented for cgroups-v1. I have not tried
> >     hugetlb_cgroups with cgroups v2, and AFAICT it's not supported yet.
> >     This is largely because we use cgroups-v1 for now. If required, I
> >     can add hugetlb_cgroup support to cgroups v2 in this patch or
> >     a follow up.
> > 2. Most complicated bit of this patch I believe is: where to store the
> >     pointer to the hugetlb_cgroup to uncharge at unreservation time?
> >     Normally the cgroup pointers hang off the struct page. But, with
> >     hugetlb_cgroup reservations, one task can reserve a specific page and another
> >     task may fault it in (I believe), so storing the pointer in struct
> >     page is not appropriate. Proposed approach here is to store the pointer in
> >     the resv_map. See patch for details.
> >
> > [1]: https://www.kernel.org/doc/html/latest/vm/hugetlbfs_reserv.html
> >
> > Signed-off-by: Mina Almasry <almasrymina@google.com>
> > ---
> >   include/linux/hugetlb.h                       |  10 +-
> >   include/linux/hugetlb_cgroup.h                |  19 +-
> >   mm/hugetlb.c                                  | 256 ++++++++--
> >   mm/hugetlb_cgroup.c                           | 153 +++++-
>
> Is there a reason why all these changes are in a single patch?
> I can see these split in at least 2 or 3 patches with the test
> as a separate patch.
>

Only because I was expecting feedback on the approach and alternative
approaches before an in-detail review. But, no problem; I'll break it
into smaller patches now.
> Makes it lot easier to review.
>
> thanks,
> -- Shuah

