Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2864EC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:55:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8A462083B
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:55:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="ePp8uOPB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8A462083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68CBF8E0188; Mon, 11 Feb 2019 17:55:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6153F8E0186; Mon, 11 Feb 2019 17:55:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DF998E0188; Mon, 11 Feb 2019 17:55:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5DB8E0186
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:55:24 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id n22so658311otq.8
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:55:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=PipVbT9feF+A/+kcKPeIiPlxJtq1FDRuiYejP4/jlTM=;
        b=LVcYHfiS3q+X8MLtQz6+JWkdvtMg4RF/n/RTin+F5D9YXEHEUyByZntUpULGeyI+ze
         rEuvtxT/Un/vShgO5iSj98fjWaFmUBlKHc9in7bhxJydq8FL+ZonrmTZ3Jvlwb7aTux+
         JuO52J0UJf0Z7Sjqn/i2d5y3JmvEXOG2/beyZveKiUHFgc/22O7L9N9cwCzM2HvTm8YW
         M5U/DdEno7kVvCCtr7UNN81f5GyVtG6/G3b70CHwBPobQK3R+v/r03oG7qh4YCXxg3oF
         G0pODTPBk9+ylaQavl3FkHEH1D5J8VhOFMMDXj788CvQEtoWUDHEu3klyiVco3rYseg0
         6X1Q==
X-Gm-Message-State: AHQUAuZWuPA7k680Q9fEPUPJhe0eXat48uGzeFTA5E87iSWlm8/vpSun
	dm04j5/4L1nhTgk/w3V6dGuUbsHa6DIEvYVCgCITe2Y6lSG3ix4bjGfn+J0GnD/vy7C75HEAjqX
	agYzA+zcVkp5ngAzJe8oqAqHCGBbMFt8wS/3uqdEkFQhywi6mvUZsu/vdxTAxaxcVEf/ymnXq8m
	ASJOmXKYpdJ4pFAB7/MBEvtvL1csQqE7YhApFo5GRbqdURBMHeNA9Wm/iROB9cHnHkof2FPlfaN
	TqfFS3/BYG0buXMIZtCQOxOqo6YrD+HlJyw93ygOAVnbe64BSdDp4XRHUDZco+E2XTf8QntHEi5
	CPaZfaUyPuhHMLkMjnJIU78dAhjZ4IX4Agco8C7HsTZdvEUsJzFotl2zfZHWPvdg5JcrzT7F12e
	1
X-Received: by 2002:a9d:3e41:: with SMTP id h1mr658586otg.170.1549925723848;
        Mon, 11 Feb 2019 14:55:23 -0800 (PST)
X-Received: by 2002:a9d:3e41:: with SMTP id h1mr658546otg.170.1549925723117;
        Mon, 11 Feb 2019 14:55:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549925723; cv=none;
        d=google.com; s=arc-20160816;
        b=shnukNWz6DvsvMbvyL4BzH/xe3Xd6VE0rPl2KJicz5lQPt4UzZxQnN2VTMzTNNywte
         lYMz1Cs03GQV9bYSrrhqC81TfOesb9D2lMc4w/yFW23u1ZdZ3rnXuXp+E9TdLcvatRuo
         H49tPNHlcHwQDG19vkeoS5/SC6iORb79MFdhroriL7yu1AmA5GEbVn7oFdZGGV3/Ha/c
         T2eii1PB6GTKohwNV7IykavRzwdxRmHn0uSfdwaTQN8FIj6Jc3Lv2gvLCsp0JmwqGtF+
         gkD9ZFqeSJ9EiUcA+Z6yTgw0Kng3Vsjnf6qjFNk8squBsMV9EDi594J97H+aaB0s+AIG
         IdMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=PipVbT9feF+A/+kcKPeIiPlxJtq1FDRuiYejP4/jlTM=;
        b=P6piEGdBqaYwe3Wwh4hheheYMpJ8S6g2+1iB5XQ8oziV3y1FADZLryYg82x0kjHj7d
         Cny3hJ1MgTAglK0kkA1hMb9/2TaAJvqs1gaUonziuCjF+2HNIhrfvfKy4QJzrna94qqA
         vJANKnoNrZxM7dhQDOs7+N7h8kzRvZwPGIw+D+KhJ6ZgbxIqTS61o1EFxWcAa7H4+K7u
         0mc+ylFxEu0KORHtYyBTjRnUxREwW6uhZDe5Q3POVDgX+j7ffKLVfihC3MBhDAZAZAXO
         4y+OD6c25q0vNfo37geXi0cLfSw6gn7Yc85fj1VxsgSDe0TvjRWaV+Op/dFsBVIJ0DSE
         ZdsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ePp8uOPB;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t16sor7207924oth.4.2019.02.11.14.55.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 14:55:22 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ePp8uOPB;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=PipVbT9feF+A/+kcKPeIiPlxJtq1FDRuiYejP4/jlTM=;
        b=ePp8uOPBs0N6VpZBCYMwGPAoIqlDaY2gC7lJUFZR/emNWOFMvtmbPs6f040V04VIGC
         2vRJz4SREJwH25cT7NuHossKvHgNe1HVHIe4RYI/rASiNarU1LckLx4eEfDZvjb0thx5
         95FeQMZoZJwdy8Fz6vfMEsazvyaO8uwnV0OomuH0G93F+yXCodj1y+8dNhbFMc3xcHjj
         OENj/rh1qIdkhkrjf9fweC7gDSPKiOjSlixCFT7GE5XpgEAOYi7gVmGdy3sFw/3Jid76
         9N7K4Ti/pNGy7OV0X2wloFXKpVeG9i7EijmNrr5HU6fF6bXCxsauJi5TVlMZi/82WpPV
         Lm7A==
X-Google-Smtp-Source: AHgI3IYGo/qsdTLuha3YNsAwQUDrumeNrBs1vI6bpgPeNvmzCn7YXX3I4hUjf+8RHy+iEYulENdHYtDfW2xsnfGRu4c=
X-Received: by 2002:a05:6830:1c1:: with SMTP id r1mr584180ota.229.1549925722592;
 Mon, 11 Feb 2019 14:55:22 -0800 (PST)
MIME-Version: 1.0
References: <20190211201643.7599-1-ira.weiny@intel.com> <20190211201643.7599-3-ira.weiny@intel.com>
 <20190211203916.GA2771@ziepe.ca> <bcc03ee1-4c42-48c3-bc67-942c0f04875e@nvidia.com>
 <20190211212652.GA7790@iweiny-DESK2.sc.intel.com> <fc9c880b-24f8-7063-6094-00175bc27f7d@nvidia.com>
 <20190211215238.GA23825@iweiny-DESK2.sc.intel.com> <20190211220658.GH24692@ziepe.ca>
In-Reply-To: <20190211220658.GH24692@ziepe.ca>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Feb 2019 14:55:10 -0800
Message-ID: <CAPcyv4htDHmH7PVm_=HOWwRKtpcKTPSjrHPLqhwp2vhBUWL4-w@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm/gup: Introduce get_user_pages_fast_longterm()
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Ira Weiny <ira.weiny@intel.com>, John Hubbard <jhubbard@nvidia.com>, 
	linux-rdma <linux-rdma@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Daniel Borkmann <daniel@iogearbox.net>, Davidlohr Bueso <dave@stgolabs.net>, 
	Netdev <netdev@vger.kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, 
	Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 2:07 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Mon, Feb 11, 2019 at 01:52:38PM -0800, Ira Weiny wrote:
> > On Mon, Feb 11, 2019 at 01:39:12PM -0800, John Hubbard wrote:
> > > On 2/11/19 1:26 PM, Ira Weiny wrote:
> > > > On Mon, Feb 11, 2019 at 01:13:56PM -0800, John Hubbard wrote:
> > > >> On 2/11/19 12:39 PM, Jason Gunthorpe wrote:
> > > >>> On Mon, Feb 11, 2019 at 12:16:42PM -0800, ira.weiny@intel.com wrote:
> > > >>>> From: Ira Weiny <ira.weiny@intel.com>
> > > >> [...]
> > > >> It seems to me that the longterm vs. short-term is of questionable value.
> > > >
> > > > This is exactly why I did not post this before.  I've been waiting our other
> > > > discussions on how GUP pins are going to be handled to play out.  But with the
> > > > netdev thread today[1] it seems like we need to make sure we have a "safe" fast
> > > > variant for a while.  Introducing FOLL_LONGTERM seemed like the cleanest way to
> > > > do that even if we will not need the distinction in the future...  :-(
> > >
> > > Yes, I agree. Below...
> > >
> > > > [...]
> > > > This is also why I did not change the get_user_pages_longterm because we could
> > > > be ripping this all out by the end of the year...  (I hope. :-)
> > > >
> > > > So while this does "pollute" the GUP family of calls I'm hoping it is not
> > > > forever.
> > > >
> > > > Ira
> > > >
> > > > [1] https://lkml.org/lkml/2019/2/11/1789
> > > >
> > >
> > > Yes, and to be clear, I think your patchset here is fine. It is easy to find
> > > the FOLL_LONGTERM callers if and when we want to change anything. I just think
> > > also it's appopriate to go a bit further, and use FOLL_LONGTERM all by itself.
> > >
> > > That's because in either design outcome, it's better that way:
> > >
> > > is just right. The gup API already has _fast and non-fast variants, and once
> > > you get past a couple, you end up with a multiplication of names that really
> > > work better as flags. We're there.
> > >
> > > the _longterm API variants.
> >
> > Fair enough.   But to do that correctly I think we will need to convert
> > get_user_pages_fast() to use flags as well.  I have a version of this series
> > which includes a patch does this, but the patch touched a lot of subsystems and
> > a couple of different architectures...[1]
>
> I think this should be done anyhow, it is trouble the two basically
> identical interfaces have different signatures. This already caused a
> bug in vfio..
>
> I also wonder if someone should think about making fast into a flag
> too..
>
> But I'm not sure when fast should be used vs when it shouldn't :(

Effectively fast should always be used just in case the user cares
about performance. It's just that it may fail and need to fall back to
requiring the vma.

Personally I thought RDMA memory registration is a one-time / upfront
slow path so that non-fast-GUP is tolerable.

The workloads that *need* it are O_DIRECT users that can't tolerate a
vma lookup on every I/O.

