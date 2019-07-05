Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0EEBC5B57D
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 23:39:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9469D20863
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 23:39:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Vr37Kcg6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9469D20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FD6A6B0003; Fri,  5 Jul 2019 19:39:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AE6D8E0003; Fri,  5 Jul 2019 19:39:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19D988E0001; Fri,  5 Jul 2019 19:39:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id EDF6B6B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 19:39:52 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id w17so11330054iom.2
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 16:39:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=sq9F33IQp154Hc3CT0DLsiwhph66dbKhKe1mXt9jS+c=;
        b=ENeaWQG30W+Y0RbGPzBOKqTUBuub3d6dyFrngfJrpelInZ9xgoI449hv8L/YsVUIhG
         E5cZbeOoDXKz9Ak07oigU9Qmmj42nC4M56+F6aat0sGWYJUGzM5sbl0MlAwepKrmnFba
         /p+zZTXpTYSVy0KsweFbVNSAhA6irekS5YyjT530dfKyR8tRVU/sk1tscj4U2v1SizI5
         QKHlGSPfQ0ULpof2Es/i3gP8L3DcHIu6TTFyqJFNLeePYXyRcjIKmAxhT9woznGeTw+u
         NURc7pLirAnE7hgVxxTb5emVkKu/Rp27mRkvviaXp27ZLCrjfI5dnztlOiG9wUjQuKel
         XNkw==
X-Gm-Message-State: APjAAAWC1Wektmo5vecZB8bDSy8hKXX2RZgZX5NsbzMAhXr7jzvCKCrm
	lUEZvgNRoe8B6dm0IXQC9lcbHaPV9LjGCcsmeIi/LLCFhfoxF+eYyIVnyzGQdMHYWveC2KKZveO
	boj0SsZlcMN1tlH8pcH6WuPWFp92cZU0+pxHSElHbDFM2d3sEZSwzXZbjT8gcTkoUOQ==
X-Received: by 2002:a6b:b985:: with SMTP id j127mr6847457iof.186.1562369992621;
        Fri, 05 Jul 2019 16:39:52 -0700 (PDT)
X-Received: by 2002:a6b:b985:: with SMTP id j127mr6847408iof.186.1562369991746;
        Fri, 05 Jul 2019 16:39:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562369991; cv=none;
        d=google.com; s=arc-20160816;
        b=Jw5C57wTUToYrGkPrUWeEct96KlKoScEVwiumQV6Nc0XfgFLWQoBS32IVrkisGtcZX
         7dQnWxARaHmow611qPZhDj4NybnixySXxcBEEJKjNXxsCPR1crmbg1k7nXLmfpN9v3PS
         GdIyEJ4xbQ8il7exy5PXTSI3uHPecjUpxUBvdbh4Z/WcnN2Qi2hVa8MqBb9kSWBdLr1Q
         sHbQ0wxdRns86CLSzDSUNC7AynuZspXu2bHZrUyPJ9TsBL9evPbMDaSFuq22uNdo2cEx
         8f02RZYyNCk7uX+w2zrzbrWHiJeawjLBwu/96nkwADGFv2ACcahF02aTCyzdVHOR1kCv
         nY9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=sq9F33IQp154Hc3CT0DLsiwhph66dbKhKe1mXt9jS+c=;
        b=eopS/kU3O5JODc6PYq4Z7ezat2wkGW6HfotNkAxNy2CWzVUCF5C+xZA0oE/AlF3Sft
         MDE71zNjL1ds+2+fWKs3A5usyg7RsEOhRX2tEdcdj8AhawoEJNETfFTuDaVvjzFX/O+C
         2IGPCb5njo3/Pa1MSLGg1NNvmRtCIRE8Pigq0R9mN0TWPyGzuTmdNnF2EP7zTdUq7BKS
         /vXfBCpw+pRPz0giYDYgpK3AnTy7xh1vgHoSIdw3S9aQK0L+Xm1mA3jACNYY/a2huOr7
         7gkyLSm36FqovLW0ulS9TehMJlqq3xvNJiS/THYTc1JhPcR5UuUURvfHeTo7rBcxgWql
         Ed3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Vr37Kcg6;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q2sor7981897ior.86.2019.07.05.16.39.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Jul 2019 16:39:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Vr37Kcg6;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=sq9F33IQp154Hc3CT0DLsiwhph66dbKhKe1mXt9jS+c=;
        b=Vr37Kcg627ITaKGc4NRCnPxFp8s1zj7IkD4+oUykUPlRg1WnILprYgN7l+ncct94oW
         zLT0sioTwHFcQo1zR5T4zwpkrw6w4XNpvIPGdbGF9d9NMggFY+XSMpcwi/Zs1squbpHd
         6NhP1OGDabC/hCXJ04xX9MiXE5Dd4/X2qJQljL3R9W87JGckqXJlJxkaA9RWC1t4i3wz
         y0OZz7oZQTuNjjMVUUaHodZ3fvkdTMrYnYSCxnIQETW/Q87TzibhTfM6u9Ao7T9tEAwq
         ycvRg7/JUvGIiEHZbOasUB1qJogTkNrvR9gEgKwltWXXTozfE/iEHyOrRH4/4Uurf/cm
         pbaA==
X-Google-Smtp-Source: APXvYqxnohcjBQRztjf0hYU/JsLzhXw1zLVQnPOhw7NNixBOFSkYP+mSg0IXdNjoA7KZ/Mg3LrOWGvKFlpyJlCkOUqI=
X-Received: by 2002:a5d:9282:: with SMTP id s2mr6517548iom.36.1562369991307;
 Fri, 05 Jul 2019 16:39:51 -0700 (PDT)
MIME-Version: 1.0
References: <1562310330-16074-1-git-send-email-laoar.shao@gmail.com>
 <20190705090902.GF8231@dhcp22.suse.cz> <CALOAHbAw5mmpYJb4KRahsjO-Jd0nx1CE+m0LOkciuL6eJtavzQ@mail.gmail.com>
 <20190705111043.GJ8231@dhcp22.suse.cz> <CALOAHbA3PL6-sBqdy-sGKC8J9QGe_vn4-QU8J1HG-Pgn60WFJA@mail.gmail.com>
 <20190705151045.GI37448@bfoster>
In-Reply-To: <20190705151045.GI37448@bfoster>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sat, 6 Jul 2019 07:39:15 +0800
Message-ID: <CALOAHbApDsrYrxSBLmR+vWWwnf_wqU9sPFvztoFArWu27=aX+A@mail.gmail.com>
Subject: Re: [PATCH] mm, memcg: support memory.{min, low} protection in cgroup v1
To: Brian Foster <bfoster@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Shakeel Butt <shakeelb@google.com>, 
	Yafang Shao <shaoyafang@didiglobal.com>, linux-xfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 5, 2019 at 11:11 PM Brian Foster <bfoster@redhat.com> wrote:
>
> cc linux-xfs
>
> On Fri, Jul 05, 2019 at 10:33:04PM +0800, Yafang Shao wrote:
> > On Fri, Jul 5, 2019 at 7:10 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Fri 05-07-19 17:41:44, Yafang Shao wrote:
> > > > On Fri, Jul 5, 2019 at 5:09 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > [...]
> > > > > Why cannot you move over to v2 and have to stick with v1?
> > > > Because the interfaces between cgroup v1 and cgroup v2 are changed too
> > > > much, which is unacceptable by our customer.
> > >
> > > Could you be more specific about obstacles with respect to interfaces
> > > please?
> > >
> >
> > Lots of applications will be changed.
> > Kubernetes, Docker and some other applications which are using cgroup v1,
> > that will be a trouble, because they are not maintained by us.
> >
> > > > It may take long time to use cgroup v2 in production envrioment, per
> > > > my understanding.
> > > > BTW, the filesystem on our servers is XFS, but the cgroup  v2
> > > > writeback throttle is not supported on XFS by now, that is beyond my
> > > > comprehension.
> > >
> > > Are you sure? I would be surprised if v1 throttling would work while v2
> > > wouldn't. As far as I remember it is v2 writeback throttling which
> > > actually works. The only throttling we have for v1 is reclaim based one
> > > which is a huge hammer.
> > > --
> >
> > We did it in cgroup v1 in our kernel.
> > But the upstream still don't support it in cgroup v2.
> > So my real question is why upstream can't support such an import file system ?
> > Do you know which companies  besides facebook are using cgroup v2  in
> > their product enviroment?
> >
>
> I think the original issue with regard to XFS cgroupv2 writeback
> throttling support was that at the time the XFS patch was proposed,
> there wasn't any test coverage to prove that the code worked (and the
> original author never followed up). That has since been resolved and
> Christoph has recently posted a new patch [1], which appears to have
> been accepted by the maintainer.
>
> Brian
>
> [1] https://marc.info/?l=linux-xfs&m=156138379906141&w=2
>

Thanks for your reference.
I will pay attention to that thread.

