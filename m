Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5D3DC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:00:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61880216F4
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:00:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WaA4XB0e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61880216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CE126B0003; Tue,  6 Aug 2019 21:00:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07FDB6B0006; Tue,  6 Aug 2019 21:00:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAFBD6B0007; Tue,  6 Aug 2019 21:00:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF4EE6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:00:38 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id q16so51480089otn.11
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:00:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Tf2IVgrU6o0+LHpP6jsIas9LZLOan8+imWqtG8bEbmo=;
        b=fcg/f7cnOeq2PWzYUqPIhJtYe7/0sXxBb3QNI2IjkLX5kzmW4x+VjmHhNa/ODh0l2O
         RcoLDCsxg3v3AStjNaz3J+sALhlsBFP7eIjU4ZfF/mmREL1AjszwuV5BFIGAweSjFExK
         PStUm68PItBd1mD0o5+tL6vzlCJrW3L4C5QyMzgw5G+3/VnEmDSaBsshXkLIcM+0KWdu
         U454v9WvCdW9OA5YZK5X6EGoVxLFR9c1ExthhGEvJP1SPXMLTfIViQ+lMbVNlQowSJ7K
         SmQ18vRzFukilfwCZ8dXOym6ekHKvdLfk7bpWnwCDiXyJdc2FHTeeqMk7e3EWf4QkQgJ
         xrbQ==
X-Gm-Message-State: APjAAAW/tMfUqFaGIZB0S8ZE9B/NuQRJHuCYlFvMDmaGKdQY8Ag8hULY
	LgdiVjn1zDUW1YFGF5s5S6OCJ4NUwaiCYGUIOGmmZbZx0oHy1poZZod/xIqcDGGyhpBXMOdihvi
	Iroa9nruQSfvw4uFJNfxda2AIiwgp85enFCWRsJM9FBz3BZqNoxMfXr8sbN4HcRJvqA==
X-Received: by 2002:a5d:9d58:: with SMTP id k24mr6395567iok.116.1565139638442;
        Tue, 06 Aug 2019 18:00:38 -0700 (PDT)
X-Received: by 2002:a5d:9d58:: with SMTP id k24mr6395526iok.116.1565139637885;
        Tue, 06 Aug 2019 18:00:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565139637; cv=none;
        d=google.com; s=arc-20160816;
        b=MfrupEMUiy8+Yza0znD+veSQpZ5NJt9aWlB6DeYWfmmtxNe2JTrwtju4x9jh+QNA/6
         tatHRfuQAK652zgEAmpGNLISPmdlvvBQk3OfJLjsB95ATY1LGAr73cZm5aVu4N1mdIdH
         ebFuBkXe6p8U2mBYJQ5exMvTL0mbNp06w/qcAiiCmjJNmsRd//bVeCstLwal4Ho420cW
         6dhIh8aPZiic7Xy3JzI5wVSfVZVMw8O10wppvxRiVteycYwGDJ/fF32PcXbt167rZpf9
         zhvfePLzVKZRaXckDZUcoWCGj+7ZWdgJG1F3QBMnZszeeA+m6I4tohPV2SmPpHQ9uoSL
         RaWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Tf2IVgrU6o0+LHpP6jsIas9LZLOan8+imWqtG8bEbmo=;
        b=Gix7C0CirDOJYEyyrfD3ooIesqLtlm3GzBoVQtgbRmtfRRMmuIAsxAjUCUKAcyw4y0
         O5Bko5R0agbGC210gB3Lx5E9GnORswCgY3TnsLfvIR7BK+HmGTl+0PCp1zFjKWsvD+/k
         uaKgoNAJvRtbjSFW63UgVEWNiB9TM0oRvSWyoxxMW0MXyeSc2WRGpgoSyresenV0sLNZ
         qwDh6deHnpr8jckgYmSd+X7mMsPcVh4bLMCfIAUaCkfd0KeB7rS4gMouWTILxGjOHV9V
         K8V4Ydz+1rsLT8WKJP97a/e2QI+LjxLSwQf650ye/UnZl0ukqAummcJ8dmoO89oWr/5e
         eUtA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WaA4XB0e;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l63sor60778105iof.27.2019.08.06.18.00.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:00:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WaA4XB0e;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Tf2IVgrU6o0+LHpP6jsIas9LZLOan8+imWqtG8bEbmo=;
        b=WaA4XB0e2zbt4Tw3Ek4iefnQvXijVsxLx+hiOKYBrqhXVUVOeAG/kp1M2NQU8mDhb8
         PM0h8gc2Y89QO3ggsnIp0F742z2GlApNbD2m2L32eMgOPDNgD3yTAJPY+WX4BL4zqkgL
         hsgHWuHiFL9kigslswjHsD6hbGG+hrRH/7HMpeiW9lS+FC/XtmBxWyVl1fMhVC2Wd6yn
         J+dE0pGxXGix1VF5L0kC4R8J5do1/1Y1JsvoJvVAvWGFtjYQRD+OV9UkjA7OBAa17PfG
         7fpBkFNvp74QZLSE05vhu/rDb3WYtqlFFdsZhlBAQzqh74l7sYzGOw9hoYJsRUYqPTmU
         C/TQ==
X-Google-Smtp-Source: APXvYqw5yoDAssTbbcVYnwh/yZJ9wiDG201Yx/0GzcGiXGScobELzyd8N9yDg//mQyE/ynjBZmxD8JnakwwpCL43nVw=
X-Received: by 2002:a5d:8451:: with SMTP id w17mr6643266ior.226.1565139637572;
 Tue, 06 Aug 2019 18:00:37 -0700 (PDT)
MIME-Version: 1.0
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz> <CALOAHbD6ick6gnSed-7kjoGYRqXpDE4uqBAnSng6nvoydcRTcQ@mail.gmail.com>
 <20190806152918.hs74nr7xa5rl7nrg@ca-dmjordan1.us.oracle.com>
In-Reply-To: <20190806152918.hs74nr7xa5rl7nrg@ca-dmjordan1.us.oracle.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Wed, 7 Aug 2019 09:00:01 +0800
Message-ID: <CALOAHbDGojd3K=m=E6mJc+9bMGQtw8FdFc0sVRhvSAngOZTHhg@mail.gmail.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, 
	Christoph Lameter <cl@linux.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 11:29 PM Daniel Jordan
<daniel.m.jordan@oracle.com> wrote:
>
> On Tue, Aug 06, 2019 at 04:23:29PM +0800, Yafang Shao wrote:
> > On Tue, Aug 6, 2019 at 3:35 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > Considering that this is a long term behavior of a rarely used node
> > > reclaim I would rather not touch it unless some _real_ workload suffers
> > > from this behavior. Or is there any reason to fix this even though there
> > > is no evidence of real workloads suffering from the current behavior?
> > > --
> >
> > When we do performance tuning on some workloads(especially if this
> > workload is NUMA sensitive), sometimes we may enable it on our test
> > environment and then do some benchmark to  dicide whether or not
> > applying it on the production envrioment. Although the result is not
> > good enough as expected, it is really a performance tuning knob.
>
> So am I understanding correctly that you sometimes enable node reclaim in
> production workloads when you find the numbers justify it?  If so, which ones?

We used to enable it on production environment, but it caused some
latency spike(because of memory pressure),
so we have to disable it now.
BTW, do you plan to enable it for your workload ?

Thanks
Yafang

