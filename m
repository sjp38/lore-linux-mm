Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1B02C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 17:12:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38D112070D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 17:12:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="ob+cFF2I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38D112070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6F3F8E0109; Fri, 22 Feb 2019 12:12:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F77B8E0108; Fri, 22 Feb 2019 12:12:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C0258E0109; Fri, 22 Feb 2019 12:12:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5FED58E0108
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 12:12:50 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id s18so1112455oie.19
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 09:12:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DCy2TmrFrn4FdoGZB4ffQHIWsmcBtIU1to+2B1lop8k=;
        b=WMetw29q3k1ZoFmpE1ayLsyNG3DkanwEPiviawYbc8QMbrXhvm484Z7NO0pMJ/6KNR
         JbIXr0mtRpSmfC7ISvDWEzaCpFhJvaAEff27uImwwdJvcDKihd57rcXIN4jVxH3jpKBN
         /jNK58HcZP6bPW9OK3JE02PxCTLuKQrwiRK5i2qUAbv6QLygVkNlpNvi0SANtzm34CL7
         5QernhUyWj2THRyN7eW0ZKqdlIeIUesDe9jmaXXx6GtyMHoAe3UgOuKWObqm0cXPeDyO
         U0po4jbQP5C9ixZ5THCO2M+KnYq/Rs4KI0LJ5uXity/CjoZIJPIt2c1qs0Fo9XZ0I+v7
         n+Kg==
X-Gm-Message-State: AHQUAuZi09fPcL7X7e3QY2lp3Nqk/x+31JFXV5g1OYdeq2wn4wBgZs/q
	FbHk4bHvRNDdtB0CLSSjz1vqLaJh9z+Vyu43WvqDvzuAuvU4CUEREwwI0l75k2O8e++LgmTCiog
	zTPcClWBMEMH1ICSRLop0dkehMX2V/9MOTvuJRk72jJ/s3s0sU6fujmthWmlN6EgFNa07+nvnKH
	f6UDN81nSNxtVRQCN/LFH6sr8ynjQ2P8K2rvsIgyEgF+HlcnL8SgGrTYCxr3UPJBnUvtfVGyBAm
	oRGlf39YIex8CfnpLoqAn4y+TXF1YsO9dcscs3pa8/63SHCfRXOQQQhwnkTeOIJRw8lFzHFC+fG
	rbU2Px+fkp2Ucz8OEUt7TBWxGFMYFagbXFAP4Rfuth+FiYZiDyUH1nycGApHgJq6MTePTBnpSnW
	d
X-Received: by 2002:aca:5e8b:: with SMTP id s133mr3199493oib.2.1550855569918;
        Fri, 22 Feb 2019 09:12:49 -0800 (PST)
X-Received: by 2002:aca:5e8b:: with SMTP id s133mr3199443oib.2.1550855568805;
        Fri, 22 Feb 2019 09:12:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550855568; cv=none;
        d=google.com; s=arc-20160816;
        b=mSj4OlW9d818wocHZn3cKoUrOlL5M+OipxE/dJsIqbPOpV43J1nSciPSIZZ/UtxxAq
         poT+W4v3uJTgDu7lysv2nTrErVUI/96+t0kdYSQbbfsJPozJVqCzqaUj4QPuNIwMEvAy
         H0oOJh+3eyG6BygoEZrE3VUmWkDKqnJSyVOdLvHJp79D9DQ8+c1o92isC4wfeNtKvVes
         FomKy/Y9i7iO8fexccTOUuYcImUcE6Y7RsSMsivStkxVh5UpxO4DSjS36amrjRkOXqCc
         kcTkcpFD/ggOFakiXu73X3rIXts3y6Mk/H8bWOZtn+7nGYlQd8yS4LshkuKfhtXWjrFI
         9I5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DCy2TmrFrn4FdoGZB4ffQHIWsmcBtIU1to+2B1lop8k=;
        b=RGilqXRlX3h+W1XPdIYSvo7M75JJx/bMgVDDWhTL983YzVJV085SBwL7ytxb4K58GA
         cYlJQHQZZQxH1lhEWEIStzb5a1/f7zXv2ZbtAp5fswgF7g36lbU0m7WT2CWw5iQyc+uG
         xo+QZAbDaoovgBDwkecUv6EhQjDgE0E2psXn0C5xQjUsKBd86MalCObwMgQGRVf+9TJK
         k5zjDpLdLAUTFLWWBpz/j86V7PFPgzbXNGbxWWrq2ctJ0bM9664wTTjC0hVUXT52f6+3
         bOqfTYW7zG4PkFPqvfb7dsSCE1Lx+g3UitYBpKDEfutx3GY5I88UkzFPA1+6C/sDKWQq
         kNbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ob+cFF2I;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t8sor1215914otp.105.2019.02.22.09.12.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 09:12:48 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ob+cFF2I;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DCy2TmrFrn4FdoGZB4ffQHIWsmcBtIU1to+2B1lop8k=;
        b=ob+cFF2IiGDD3i3c+AWY8o2klmU+SaeSrFvlZgghTkfRkxp9Cw5oItRHWEkV+n8Rx8
         KN19QrxBwdMhiI4ylHSFD7TzjnfQYi1AjhgslFOvr91JxCZ02+9vFa+u5bCx/RrVxjq6
         x5k1rfdWHHHIvzA7eASgGq259HUmF1DbZFGpRcCVx+WEUpltaRQAg6FpJlPtDya2HiGa
         oJhAJ0I2wYHYDDfKA9zLXmSNKattz+WiUMjhmEzzGLpq8CMDl09SN1Jskj7y3vpXyg6T
         riv7J3uLpjU4voMyVI5y4TD3L+BEnsRqqW9W/zkn3Rx+sL9CPv+Fx86lYjxhEZOYJRt0
         FOKg==
X-Google-Smtp-Source: AHgI3IZQ5U/QCli5IOcPCUie+xzIXLZp3AhFa0uDbSeoevQ+nGv8bVvzWjwrfadoTy5tRS+h2TL86cWNoMjBzeHWRSw=
X-Received: by 2002:a9d:77d1:: with SMTP id w17mr3170557otl.353.1550855567968;
 Fri, 22 Feb 2019 09:12:47 -0800 (PST)
MIME-Version: 1.0
References: <155000668075.348031.9371497273408112600.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155000671719.348031.2347363160141119237.stgit@dwillia2-desk3.amr.corp.intel.com>
 <x49ftsgsnzp.fsf@segfault.boston.devel.redhat.com> <CAPcyv4h9s1jYROGqkMfKk0MNBUedP=vQ1nJObLRwFiTB405nOg@mail.gmail.com>
 <x49imxbx22d.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x49imxbx22d.fsf@segfault.boston.devel.redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 22 Feb 2019 09:12:37 -0800
Message-ID: <CAPcyv4jweuVTm6D2OTaAMGvUXfxqZMDPfaASJ=QL9=8SdGUZqg@mail.gmail.com>
Subject: Re: [PATCH 7/7] libnvdimm/pfn: Fix 'start_pad' implementation
To: Jeff Moyer <jmoyer@redhat.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, stable <stable@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Vishal L Verma <vishal.l.verma@intel.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 7:42 AM Jeff Moyer <jmoyer@redhat.com> wrote:
>
> Dan Williams <dan.j.williams@intel.com> writes:
>
> >> > However, to fix this situation a non-backwards compatible change
> >> > needs to be made to the interpretation of the nd_pfn info-block.
> >> > ->start_pad needs to be accounted in ->map.map_offset (formerly
> >> > ->data_offset), and ->map.map_base (formerly ->phys_addr) needs to be
> >> > adjusted to the section aligned resource base used to establish
> >> > ->map.map formerly (formerly ->virt_addr).
> >> >
> >> > The guiding principles of the info-block compatibility fixup is to
> >> > maintain the interpretation of ->data_offset for implementations like
> >> > the EFI driver that only care about data_access not dax, but cause older
> >> > Linux implementations that care about the mode and dax to fail to parse
> >> > the new info-block.
> >>
> >> What if the core mm grew support for hotplug on sub-section boundaries?
> >> Would't that fix this problem (and others)?
> >
> > Yes, I think it would, and I had patches along these lines [2]. Last
> > time I looked at this I was asked by core-mm folks to await some
> > general refactoring of hotplug [3], and I wasn't proud about some of
> > the hacks I used to make it work. In general I'm less confident about
> > being able to get sub-section-hotplug over the goal line (core-mm
> > resistance to hotplug complexity) vs the local hacks in nvdimm to deal
> > with this breakage.
>
> You first posted that patch series in December of 2016.  How long do we
> wait for this refactoring to happen?
>
> Meanwhile, we've been kicking this can down the road for far too long.
> Simple namespace creation fails to work.  For example:
>
> # ndctl create-namespace -m fsdax -s 128m
>   Error: '--size=' must align to interleave-width: 6 and alignment: 2097152
>   did you intend --size=132M?
>
> failed to create namespace: Invalid argument
>
> ok, I can't actually create a small, section-aligned namespace.  Let's
> bump it up:
>
> # ndctl create-namespace -m fsdax -s 132m
> {
>   "dev":"namespace1.0",
>   "mode":"fsdax",
>   "map":"dev",
>   "size":"126.00 MiB (132.12 MB)",
>   "uuid":"2a5f8fe0-69e2-46bf-98bc-0f5667cd810a",
>   "raw_uuid":"f7324317-5cd2-491e-8cd1-ad03770593f2",
>   "sector_size":512,
>   "blockdev":"pmem1",
>   "numa_node":1
> }
>
> Great!  Now let's create another one.
>
> # ndctl create-namespace -m fsdax -s 132m
> libndctl: ndctl_pfn_enable: pfn1.1: failed to enable
>   Error: namespace1.2: failed to enable
>
> failed to create namespace: No such device or address
>
> (along with a kernel warning spew)

I assume you're seeing this on the libnvdimm-pending branch?

> And at this point, all further ndctl create-namespace commands fail.
> Lovely.  This is a wart that was acceptable only because a fix was
> coming.  2+ years later, and we're still adding hacks to work around it
> (and there have been *several* hacks).

True.

>
> > Local hacks are always a sad choice, but I think leaving these
> > configurations stranded for another kernel cycle is not tenable. It
> > wasn't until the github issue did I realize that the problem was
> > happening in the wild on NVDIMM-N platforms.
>
> I understand the desire for expediency.  At some point, though, we have
> to address the root of the problem.

Well, you've defibrillated me back to reality. We've suffered the
incomplete broken hacks for 2 years, what's another 10 weeks? I'll
dust off the sub-section patches and take another run at it.

