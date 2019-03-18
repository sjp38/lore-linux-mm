Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 962DBC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 21:30:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0764820872
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 21:30:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="KCUGuNY/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0764820872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 334966B0005; Mon, 18 Mar 2019 17:30:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BC766B0006; Mon, 18 Mar 2019 17:30:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1ABD46B0007; Mon, 18 Mar 2019 17:30:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id D71956B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 17:30:30 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id i4so8936497otf.3
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 14:30:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=Y8YsUQ1pdHWqexK7sIz4qXDZCsJt+yDdueh4JXEzClU=;
        b=Dm9jBVsP8Ty2yv5d/PBeg/6tTg6N1KQotyNapSVQAsffb/iGJ9n+ozzlSb300qmaqF
         2p7sX1XCl4c27A/UNj73I0xMy7jqyV6Y00kbte91911ighm7YSUde4upYu5z9widUI33
         C/Ak43v//kYYex5He5nCMtRrQihJj1tz6KRRvWWVJW+zQ81vjk7SGZvKd0lZ9LcRc2Tv
         ezJphRWEObtreHw7QdHsaja8OBMBrBjGm4+LkA7qiLgBusqh4AYmrEZGrhJWDJTZz04Y
         TklkHQE7Zdt77ZxDQCiNhQeYgT5p/HsFyDVmayOwfHEzzvz3XJ/CfZQet5GW3j3Lr1cR
         pp5g==
X-Gm-Message-State: APjAAAUyiIXMaf6PgSAnbo1iznoAnZmirHGfyAlzb4rCnKNTOEszcCgJ
	0lhY24hqIM8WIhYuBSMW08ESnJhPt4fKHQGtXTrbuFLIxWLZ8rcBgJaU6jjugPhf1fyMjwsRMvg
	8zwWikPRvcOcJTmo4w77ZDyt2PJO6HOAUDRlGraktBkDO9IQAc+q6VO+6bjvG7yFAGw==
X-Received: by 2002:a9d:7b44:: with SMTP id f4mr7445413oto.38.1552944630462;
        Mon, 18 Mar 2019 14:30:30 -0700 (PDT)
X-Received: by 2002:a9d:7b44:: with SMTP id f4mr7445364oto.38.1552944629527;
        Mon, 18 Mar 2019 14:30:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552944629; cv=none;
        d=google.com; s=arc-20160816;
        b=TZcGYDbH/noL1PJa+HtfPc6+8+i4ftVg5uhPe+z1LnybYhqer0sO8In/dhhOD/Irt/
         ZLf//2/QvIWMECTq/fYnhrDxEgOIZ1JaPbXStvIIEcJnglHYv+9WLl3WsoKbpHkGn2wV
         Y3GFznPKcbRQ3Eu68XB7h7DafM+TsNbeeAzHvLSnobUdywrJUjZggJBeaDKqXfeHAWM5
         GZyJxifzjaukE4fMJdtDG3VMZyrjD3HtYBb8y3RiMvMpjynKWjdrCtI8GYtJOgL3kfnx
         LjCH3z/fvpGNKoNlIABgyCFGWSnqY0NLKny93ChjnfJJHkLsZkQKUIM0KFwlK900zmnh
         mvQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=Y8YsUQ1pdHWqexK7sIz4qXDZCsJt+yDdueh4JXEzClU=;
        b=1D0qj7AzFalV1qEHg48X7+1k6yNh3SoACxkCnqa8OT7LGBq7tXzvDYtnLyTV1qppIV
         6xFBBZTl11SWerHtBhcPEhRT8KFi3DBrnX2MXIFKHRfAHHNuPy5Dyhg3kjoO+QMAX0zs
         G7mvehTra8WE7q9keB9bwddXKCc7BVbpo0+cbmLlTV3QNu5yY8GQrtJ25Xvdt7FwviQ/
         S4Aur6UVM3wihaixrUEw83M87JnLLeEfJwH18Ms0AUd9UY2i5AV/tGJ9rxEH9PRGKKD7
         LKe28s4I0IlADy7qSyq+Lxwy37msnAtZTSAVNJffPaKyGyPF7pl98OET9jj4fhfH6kSO
         qLxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="KCUGuNY/";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 32sor6369845otm.137.2019.03.18.14.30.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 14:30:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="KCUGuNY/";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=Y8YsUQ1pdHWqexK7sIz4qXDZCsJt+yDdueh4JXEzClU=;
        b=KCUGuNY/mUzIWa+2Uv9mcBG4QykEPnd1Ea57GYtl5VlUucexWFnnu4flLt6LSUwd60
         6fQV+8rsTSWWt1sIWhQhnPdNWb4O7N2dy4+wXIRjpBMJaZBkYm5nCqsTn1Y5iyk3U5gm
         VrUN+mtjYc8zJ9H2L2zqW9n69wy6yCuFQvxBXG99eHShKdq0TFc3tYcO5F8Tk4FKout2
         pzZ5pZm+Wu6pd4AWmFsp5ixT14IC46H4VI+zo5zDZeR2ZkH4jSx8p4dGwK08q9DzlG8M
         ibCuyVusvAvOntZCrjp4LjdhCiaAxtsz3ccecU6A+WRlIR9yKXMdrZQEM7bAddHHegeL
         TJiw==
X-Google-Smtp-Source: APXvYqzzHBucIYBPAfl3DK8iqNNp5zzdiL8B8+aQnNAwxL2xJs13E2tlniVLF5qYCAA0/wbG7h3hTLZTomnpn+1MXD8=
X-Received: by 2002:a9d:2c23:: with SMTP id f32mr8388695otb.353.1552944626498;
 Mon, 18 Mar 2019 14:30:26 -0700 (PDT)
MIME-Version: 1.0
References: <20190129165428.3931-1-jglisse@redhat.com> <20190129165428.3931-8-jglisse@redhat.com>
 <CAA9_cmcN+8B_tyrxRy5MMr-AybcaDEEWB4J8dstY6h0cmFxi3g@mail.gmail.com> <20190318204134.GD6786@redhat.com>
In-Reply-To: <20190318204134.GD6786@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 18 Mar 2019 14:30:15 -0700
Message-ID: <CAPcyv4he6v5JQMucezZV4J3i+Ea-i7AsaGpCOnc4f-stCrhGag@mail.gmail.com>
Subject: Re: [PATCH 07/10] mm/hmm: add an helper function that fault pages and
 map them to a device
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 1:41 PM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Mon, Mar 18, 2019 at 01:21:00PM -0700, Dan Williams wrote:
> > On Tue, Jan 29, 2019 at 8:55 AM <jglisse@redhat.com> wrote:
> > >
> > > From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > >
> > > This is a all in one helper that fault pages in a range and map them =
to
> > > a device so that every single device driver do not have to re-impleme=
nt
> > > this common pattern.
> >
> > Ok, correct me if I am wrong but these seem effectively be the typical
> > "get_user_pages() + dma_map_page()" pattern that non-HMM drivers would
> > follow. Could we just teach get_user_pages() to take an HMM shortcut
> > based on the range?
> >
> > I'm interested in being able to share code across drivers and not have
> > to worry about the HMM special case at the api level.
> >
> > And to be clear this isn't an anti-HMM critique this is a "yes, let's
> > do this, but how about a more fundamental change".
>
> It is a yes and no, HMM have the synchronization with mmu notifier
> which is not common to all device driver ie you have device driver
> that do not synchronize with mmu notifier and use GUP. For instance
> see the range->valid test in below code this is HMM specific and it
> would not apply to GUP user.
>
> Nonetheless i want to remove more HMM code and grow GUP to do some
> of this too so that HMM and non HMM driver can share the common part
> (under GUP). But right now updating GUP is a too big endeavor.

I'm open to that argument, but that statement then seems to indicate
that these apis are indeed temporary. If the end game is common api
between HMM and non-HMM drivers then I think these should at least
come with /* TODO: */ comments about what might change in the future,
and then should be EXPORT_SYMBOL_GPL since they're already planning to
be deprecated. They are a point in time export for a work-in-progress
interface.

> I need
> to make progress on more driver with HMM before thinking of messing
> with GUP code. Making that code HMM only for now will make the GUP
> factorization easier and smaller down the road (should only need to
> update HMM helper and not each individual driver which use HMM).
>
> FYI here is my todo list:
>     - this patchset
>     - HMM ODP
>     - mmu notifier changes for optimization and device range binding
>     - device range binding (amdgpu/nouveau/...)
>     - factor out some nouveau deep inner-layer code to outer-layer for
>       more code sharing
>     - page->mapping endeavor for generic page protection for instance
>       KSM with file back page
>     - grow GUP to remove HMM code and consolidate with GUP code

Sounds workable as a plan.

