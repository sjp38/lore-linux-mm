Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C99C9C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 19:57:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 823982084A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 19:57:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="c98keUgt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 823982084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18FA78E0003; Wed, 19 Jun 2019 15:57:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 141E38E0001; Wed, 19 Jun 2019 15:57:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 008748E0003; Wed, 19 Jun 2019 15:57:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id C9C7E8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 15:57:29 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id d204so96613oib.9
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 12:57:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=7z2tqXWz21B1V8yRVcYZ+guCUeprENU4KV1hN3na0Fs=;
        b=mWbVxQQZPkScFC73bC00WyFzcD52pQkiB58O2QbTq1JnKXaVsPI+4eBeT0zM8E+CO8
         lhh/eRKhzlddXzHnFBVbeNXHf1onT5K5Tkhz5rWETQ3JoOqrgxTJlzZfud7qI1QBxpbo
         6ou+TIGBFRLA+ReS5rUYnWNuQcJ/XZjhXv2GTXgg8fSNE1Agux0+Q3sst7lcsLJ2djdD
         lfToO9WcJh1fK+ZwX5BRVhW2+FGea4SHi90INuCMhD7PjkxMYdlsuW+kUlQ4uVE3/s8W
         6u/SEMZvyYuwk8COnoo2G2wey4j/MnLS2w4w6cmaDjiBOzarVJthUNk67VAC2hTnzKh0
         US+w==
X-Gm-Message-State: APjAAAWBU8Kpv+WdASnh/dyxq2UGGzEToPAUUKRHWl/4AyAHvEsGwOMS
	TO1IIlLhZU00dLG5PGvHumSc3HSAneL2t60o6wErClOUUCYs/qEWZDCZhHhwhjOw6kC0dRuGm8u
	eaZMOIIHeTgJRaDl5QSLTnUoDsyc6gRMaAVbrNdxQ1Kly5O/an/XSNWQxPcJwOOY1fw==
X-Received: by 2002:a9d:6c0a:: with SMTP id f10mr15255473otq.49.1560974249480;
        Wed, 19 Jun 2019 12:57:29 -0700 (PDT)
X-Received: by 2002:a9d:6c0a:: with SMTP id f10mr15255440otq.49.1560974248756;
        Wed, 19 Jun 2019 12:57:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560974248; cv=none;
        d=google.com; s=arc-20160816;
        b=TsstdWCBQcCISIwBlaoYstpPjJWyRjVgHvmCELQwSKFUEkE39AHiOUFugHEsMQnoh6
         MQKBeCpVgz8O0XgFK2pFbCVAHLAZo2TgtVAbA0KZqf1OqxbjMgjtyNJSjP0DuNazmwDW
         TiAySsyz3s9/UxFU5ohCWXdEfx055OJ7A/dxgUdSJ8+/sOJtrIfIdO2BoWEl/5VBon4a
         xQdolexNpqXl3spSs79GY/zTzbUWcpxABEisgMqhdpNayEFpKM7mpJpv4QqHip29LdpF
         1TkuNKiTK2Dt3X0Iy9jI9Elj61ZL6Mb+hU/VGHmrDq4zqdD3JMyLLTNr4RLD0GO93h/M
         nb/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=7z2tqXWz21B1V8yRVcYZ+guCUeprENU4KV1hN3na0Fs=;
        b=xIfQr63vsbJ3ajyUzyzggAel4nIVoxxXfVc3qfGD4UDkU3+pm/I7XcdsfS4f8o05Q8
         efd0Y4N5x+XMufFqyoK4ni8hcewM9+AHR4e7HwXmcylEHRa7Owpd+o/Zozcn+5LfcMHm
         Ujpz8CbBEE+ZyYq1qB9WOwEQgdyxiX9tEAH1jvwFXDue3QNjQt2vEuriRxexDq9tdukL
         hDC1yoNeTvK9xVRjxAJ0kXWw5/esUMHxPktoKJieO1f3TJx8s6y90jBx0ZP4GhcQX1xB
         Sdr4/y4NPjKvpzRHM21+Eb6hAkiOnbpGPY3e/0Mv8+BTweNtrtAmuOgO86QY4F5+TRf/
         AoxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=c98keUgt;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q124sor7003347oig.34.2019.06.19.12.57.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 12:57:28 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=c98keUgt;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7z2tqXWz21B1V8yRVcYZ+guCUeprENU4KV1hN3na0Fs=;
        b=c98keUgte0uTFh2NqchAuIxnX8Q49/GZCgQczWFfVOcAzumkG95NuHQPDWP2WUsqo/
         oCLbH0XtppVL+lGrn05uM9oLm3WIhfibqD8PTm4hTs0/e0Z+Pqsa2VuNsS3X9lc9qmmu
         Z3zqjTkCzBNUM3CWJvMoRhJP+YYYDv1DhjaEA=
X-Google-Smtp-Source: APXvYqw5ofouG26OMfQzFxsOzV+EiqO0k+h0EfPvx43Md1F3SX/w73DYzzvppOkjHYp+QM5aupN2Qz3/NdhkpYGtQiw=
X-Received: by 2002:aca:b2d5:: with SMTP id b204mr3542425oif.101.1560974248386;
 Wed, 19 Jun 2019 12:57:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
 <20190521154411.GD3836@redhat.com> <20190618152215.GG12905@phenom.ffwll.local>
 <20190619165055.GI9360@ziepe.ca>
In-Reply-To: <20190619165055.GI9360@ziepe.ca>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Wed, 19 Jun 2019 21:57:15 +0200
Message-ID: <CAKMK7uGpupxF8MdyX3_HmOfc+OkGxVM_b9WbF+S-2fHe0F5SQA@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm: Check if mmu notifier callbacks are allowed to fail
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, 
	Daniel Vetter <daniel.vetter@intel.com>, 
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, 
	DRI Development <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>, 
	David Rientjes <rientjes@google.com>, Paolo Bonzini <pbonzini@redhat.com>, 
	Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 6:50 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> On Tue, Jun 18, 2019 at 05:22:15PM +0200, Daniel Vetter wrote:
> > On Tue, May 21, 2019 at 11:44:11AM -0400, Jerome Glisse wrote:
> > > On Mon, May 20, 2019 at 11:39:42PM +0200, Daniel Vetter wrote:
> > > > Just a bit of paranoia, since if we start pushing this deep into
> > > > callchains it's hard to spot all places where an mmu notifier
> > > > implementation might fail when it's not allowed to.
> > > >
> > > > Inspired by some confusion we had discussing i915 mmu notifiers and
> > > > whether we could use the newly-introduced return value to handle some
> > > > corner cases. Until we realized that these are only for when a task
> > > > has been killed by the oom reaper.
> > > >
> > > > An alternative approach would be to split the callback into two
> > > > versions, one with the int return value, and the other with void
> > > > return value like in older kernels. But that's a lot more churn for
> > > > fairly little gain I think.
> > > >
> > > > Summary from the m-l discussion on why we want something at warning
> > > > level: This allows automated tooling in CI to catch bugs without
> > > > humans having to look at everything. If we just upgrade the existing
> > > > pr_info to a pr_warn, then we'll have false positives. And as-is, no
> > > > one will ever spot the problem since it's lost in the massive amounts
> > > > of overall dmesg noise.
> > > >
> > > > v2: Drop the full WARN_ON backtrace in favour of just a pr_warn for
> > > > the problematic case (Michal Hocko).
>
> I disagree with this v2 note, the WARN_ON/WARN will trigger checkers
> like syzkaller to report a bug, while a random pr_warn probably will
> not.
>
> I do agree the backtrace is not useful here, but we don't have a
> warn-no-backtrace version..
>
> IMHO, kernel/driver bugs should always be reported by WARN &
> friends. We never expect to see the print, so why do we care how big
> it is?
>
> Also note that WARN integrates an unlikely() into it so the codegen is
> automatically a bit more optimal that the if & pr_warn combination.

Where do you make a difference between a WARN without backtrace and a
pr_warn? They're both dumped at the same log-level ...

I can easily throw an unlikely around this here if that's the only
thing that's blocking the merge.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

