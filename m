Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11667C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:59:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 998F52075B
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:59:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KzkDXYOp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 998F52075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18FEC6B0003; Tue,  6 Aug 2019 14:59:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 142B86B0006; Tue,  6 Aug 2019 14:59:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 008156B0007; Tue,  6 Aug 2019 14:59:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA5FB6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 14:59:11 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id r4so42756974wrt.13
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 11:59:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=KdYR5EY08dTrABja8SUaSb/bjYgZpuHfqWAB/BpsnN0=;
        b=SwjxUl3/c6/+BSpjz9UzWKmNOSd+OHmAvkaOVSGVx53SwK51YJ8YjHnwZzZsghOhYl
         aFYY3IPlD4pgqDvRJzwhmWCfJEhkmp9nSEK5epelbghH2PZK6ZoOIgyYTMeiI/Mv0x0p
         rj0li1rKb2gYknGRdoAoJUgv77L7NbDSSqnNUgtAx5Kwg9WXbCX8QDFRAzZRKPnHivV9
         j3ibdjHqu3rrDM9see3fimnjWLxWCuFyTppR/9uvITe8MBKqvjDYtIPMbGQSvH6CSuUz
         1/TvKEfanwjV2wMSmsqNPtfQKM0ITrORi7J6MzxrUhDRnxczPKb0V6B4f/N/K2O0hGZd
         /kWg==
X-Gm-Message-State: APjAAAXqq8flyWFrAUzH+KmDwVsB3OnK5rofDToJEjkE1fv2JZ9UO0lJ
	UTSdXse9OQluY2VH/c6p8U9MVVYc6P9tp1agjTURFIQ805LbxNA7eGGlOo8anqJoFmw+ObVpEOb
	UYWMXJZ/dmHZq0Babe6sqtbmhVIVIMX+ot307w87nz6wP1ls6JFYdyw3fSREEN94bcA==
X-Received: by 2002:a05:600c:2c7:: with SMTP id 7mr6158220wmn.45.1565117951227;
        Tue, 06 Aug 2019 11:59:11 -0700 (PDT)
X-Received: by 2002:a05:600c:2c7:: with SMTP id 7mr6158197wmn.45.1565117950485;
        Tue, 06 Aug 2019 11:59:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565117950; cv=none;
        d=google.com; s=arc-20160816;
        b=vJkX5r75XCXLcMn1bSwAiQ+AtC1abE0BHIrafyVz6PJJfmiHt/LV6maacFD9hxOfzz
         g2jtF+dguFch9jMyAcr9haHBD5QYczEUmKzcBT+lMziHJUCchILixZumTfZUv0/knkyN
         L3pwd45FmXse39fPIFXUtnw9PPeiu+MQmgsUl8oQHRRu9H99U5DF/x3tNSiOW0V7ViBp
         OwbdKUlYOJXpcsMCpVihHT90TCGmdRJ9LfKQRS2RsY1IdhwTnFT/1K+6bU/j7z0yBZSH
         gv+TZtXELFmjgKr3a20L/M/kjgVNOG3YB4frTAtQLNOHceYu9n5VztttxawmL/m+HC3i
         vrlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=KdYR5EY08dTrABja8SUaSb/bjYgZpuHfqWAB/BpsnN0=;
        b=jRKNypFtTwCJMAuAZPQazFNQ6uaNeAkCr/3lNM1Y3QOi1LFoRTSWrL0Qwa4i6XWs8Y
         bgcfYS0S0B3yp9XLia71oNluJ7p80HC1x/2ZG4vCRz8TpXPo1KsKem8wi2Of8bqB54v8
         34PEQ/ERz6pskZc1LQcfaVoobPSho9XtNdECO0fiwTkieWT+pDwP66N6DInjXnL3mK7G
         YS/ol/tUCEMQkkmq+Z1O0iUAF43uvR07I8HVt0fDFlLhDfmqphBipPf3Gjl7mcPKVGYL
         E//AXUOtkq/pL1T0EQK0EtzFDbmk19iiYVUzG685T6l2nMws6KjuwaSuzwCJu7k/oRIv
         R+FQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KzkDXYOp;
       spf=pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexdeucher@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o2sor61028649wrn.43.2019.08.06.11.59.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 11:59:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KzkDXYOp;
       spf=pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexdeucher@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KdYR5EY08dTrABja8SUaSb/bjYgZpuHfqWAB/BpsnN0=;
        b=KzkDXYOptvkwojTFBCmVBlV+3tIliyzrdwY+53s8Esprf/Qgz2f1eCQC0QZw//ozZE
         RcNDjvbJB0Cq3mVPeQ15pOOzXvlweppXj6YAayOw27YWsleceaonHnL4Nzg52TLIthMV
         rYjlL0699xdOcqu7sevttzOxuBg4lN0lkzV2K+uunyzS+RpjhuoPhqdSTlnWnb+T7JCY
         HjZ7JWiEwVAUgYx71nCzkRtYctAe5o7uJNxjGtB37j8Kd+2mGvXbEYuFLbnlo+SIJTJp
         +5YjsJV6IoI9YUlqfsHsDvbDUa1C/1KA3eKWNZE2oqsn4qlL+cyH/WoPyn6i66w9Lttj
         o0FA==
X-Google-Smtp-Source: APXvYqyvIOyL3ta7PNqlaft8AIjrG08VwxtlFNFvdOLUq+AjfF7aZKuWk+kMq57BwYyz3aJneYaERa/Thq7ouYxDQUo=
X-Received: by 2002:adf:dfc5:: with SMTP id q5mr6393234wrn.142.1565117950081;
 Tue, 06 Aug 2019 11:59:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190806160554.14046-1-hch@lst.de> <20190806160554.14046-16-hch@lst.de>
 <20190806174437.GK11627@ziepe.ca> <587b1c3c-83c4-7de9-242f-6516528049f4@amd.com>
In-Reply-To: <587b1c3c-83c4-7de9-242f-6516528049f4@amd.com>
From: Alex Deucher <alexdeucher@gmail.com>
Date: Tue, 6 Aug 2019 14:58:58 -0400
Message-ID: <CADnq5_Puv-N=FVpNXhv7gOWZ8=tgBD2VjrKpVzEE0imWqJdD1A@mail.gmail.com>
Subject: Re: [PATCH 15/15] amdgpu: remove CONFIG_DRM_AMDGPU_USERPTR
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@lst.de>, 
	"Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, 
	Ralph Campbell <rcampbell@nvidia.com>, 
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, 
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Ben Skeggs <bskeggs@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 1:51 PM Kuehling, Felix <Felix.Kuehling@amd.com> wrote:
>
> On 2019-08-06 13:44, Jason Gunthorpe wrote:
> > On Tue, Aug 06, 2019 at 07:05:53PM +0300, Christoph Hellwig wrote:
> >> The option is just used to select HMM mirror support and has a very
> >> confusing help text.  Just pull in the HMM mirror code by default
> >> instead.
> >>
> >> Signed-off-by: Christoph Hellwig <hch@lst.de>
> >> ---
> >>   drivers/gpu/drm/Kconfig                 |  2 ++
> >>   drivers/gpu/drm/amd/amdgpu/Kconfig      | 10 ----------
> >>   drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c |  6 ------
> >>   drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h | 12 ------------
> >>   4 files changed, 2 insertions(+), 28 deletions(-)
> > Felix, was this an effort to avoid the arch restriction on hmm or
> > something? Also can't see why this was like this.
>
> This option predates KFD's support of userptrs, which in turn predates
> HMM. Radeon has the same kind of option, though it doesn't affect HMM in
> that case.
>
> Alex, Christian, can you think of a good reason to maintain userptr
> support as an option in amdgpu? I suspect it was originally meant as a
> way to allow kernels with amdgpu without MMU notifiers. Now it would
> allow a kernel with amdgpu without HMM or MMU notifiers. I don't know if
> this is a useful thing to have.

Right.  There were people that didn't have MMU notifiers that wanted
support for the GPU.  For a lot of older APIs, a lack of userptr
support was not a big deal (it just disabled some optimizations and
API extensions), but as it becomes more relevant it may make sense to
just make it a requirement.

Alex

>
> Regards,
>    Felix
>
> >
> > Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
> >
> > Jason
> _______________________________________________
> amd-gfx mailing list
> amd-gfx@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/amd-gfx

