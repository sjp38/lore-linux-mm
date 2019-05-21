Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EA99C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 18:29:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FC53217F4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 18:29:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FC53217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A81D6B0003; Tue, 21 May 2019 14:29:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87E776B0006; Tue, 21 May 2019 14:29:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 799386B0007; Tue, 21 May 2019 14:29:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0976B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 14:29:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c26so31885039eda.15
        for <linux-mm@kvack.org>; Tue, 21 May 2019 11:29:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gPiOZEbMV0dM3+fsO1DDmJ4OvmzkDSdhvLxb1+ES8Ow=;
        b=IT3Z4vDpaqL1DQuNtYI6/IaUsWgzzLq5yllcil6kylpJEBdc8ZlR1AYIJPjHQGEKqA
         wqTcwWUtoW1DGWz9zay8pYZDL0qMoVQ8c/s+Jf0SoJsKmUwLaEUUSDPyjca5nuSan08r
         OWOJdyyuOTGtUI/D51ihRb7hcgbnHgc0xH2i2FAYtNMaHFGGtFudLhyxg4nWykov1/Hu
         07M3Lu4NPDuUHTNOovNoFkw97+7V5uUnwh8mgM592g6AO0i83IZq2O5VrBOfRNfRY8xe
         th5WxCeSL2mtTCD+fQYXcWVOfP4px30G7lir1NPH4OS95gpAilGRKU4yRsou0ZNrWf7l
         613g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAV5sl/UZGHKFgAmXMCr/cnd7YvvOZ46WE7/4p/XbA41zGNmu1Hj
	DEn+Ta5Gt143K2++d++gtA2FW/WYThPp9LA9jVREuYS3kc7g3lu3CCsdOCsoz/UBIuPCBpyhSV5
	sWrHNkt5JuB7wlaRJGtLvrg3DJvF04EkNk9ZTFYMxMJ2kFfd5d5olsyRuXdHJkWHXmw==
X-Received: by 2002:a50:9490:: with SMTP id s16mr84392028eda.260.1558463384609;
        Tue, 21 May 2019 11:29:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXgx6aRtkXuqf2nVYPOOVSWUcMNDGqJUgAuvZ2LwYz17544VXMOmuDrCYxyh1sS+XXJPt0
X-Received: by 2002:a50:9490:: with SMTP id s16mr84391949eda.260.1558463383661;
        Tue, 21 May 2019 11:29:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558463383; cv=none;
        d=google.com; s=arc-20160816;
        b=GoCjba4yrHgsaclZcG0X6z1ggz1r44p1KuN1ajBLpDMneHibpomP0e50u832DfgAo0
         iqkOZ3e8LEIjXIA+4Fu/+5aCaTlByMaNfR0CP5Roi7fwPhL4PQZf/7IMbhayi4vklGZQ
         SYURfbEXe0cOfv2DoNJvakTGZJ61eP4+6UdR1rssDRmfIzBy3RitM8/qKO2iynMApyK2
         t9ljazP2UFHmO0PgCXbLNVTchynJYj2eay5e+MQzI5b28hKPdksHybMYtqDQhdbxwr4a
         MGXRMepnh1wSVOmy8PQusZsqsHOXBqglL64yviOWDVUn9gmiLsR3fMnmf3rXrGNY5CBj
         1XBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gPiOZEbMV0dM3+fsO1DDmJ4OvmzkDSdhvLxb1+ES8Ow=;
        b=l4lqE7BiOiNk6GnMJnpSmwqaN4zXB3+OW26tdh+r/K3Q2fA2AspXIT+KneDrSX6mc1
         B/hYSXgNKP8OuLubf2VhhtbyOYljE+LyWvSFpeC4RApjrukxNP6GLhVQ2/R+Pp4GMBC+
         nGSva2rTA/RcF9YgLA3Z3rJq6GLBktE1VTypI1JboTqXg3WdYZl6VPtyK6tVKj0X1rQT
         p0GKHS9GffxuPU4YAMcwMvfjgzPo7mz2r8pfSyuqxSTqHHWwTXvd1j7K5UBiEFsQ43l0
         /LJycX1QzTKNMXDqo6GGETCkZUIWpgQg1d1545N9Z/1ZZ1P3jPzBxOYRFF+vju3guQSx
         qChA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k57si568348edb.36.2019.05.21.11.29.43
        for <linux-mm@kvack.org>;
        Tue, 21 May 2019 11:29:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4EE4F80D;
	Tue, 21 May 2019 11:29:42 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 294B83F5AF;
	Tue, 21 May 2019 11:29:36 -0700 (PDT)
Date: Tue, 21 May 2019 19:29:33 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Evgenii Stepanov <eugenis@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Elliott Hughes <enh@google.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190521182932.sm4vxweuwo5ermyd@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 04:53:07PM -0700, Evgenii Stepanov wrote:
> On Fri, May 17, 2019 at 7:49 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > IMO (RFC for now), I see two ways forward:
> >
> > 1. Make this a user space problem and do not allow tagged pointers into
> >    the syscall ABI. A libc wrapper would have to convert structures,
> >    parameters before passing them into the kernel. Note that we can
> >    still support the hardware MTE in the kernel by enabling tagged
> >    memory ranges, saving/restoring tags etc. but not allowing tagged
> >    addresses at the syscall boundary.
> >
> > 2. Similar shim to the above libc wrapper but inside the kernel
> >    (arch/arm64 only; most pointer arguments could be covered with an
> >    __SC_CAST similar to the s390 one). There are two differences from
> >    what we've discussed in the past:
> >
> >    a) this is an opt-in by the user which would have to explicitly call
> >       prctl(). If it returns -ENOTSUPP etc., the user won't be allowed
> >       to pass tagged pointers to the kernel. This would probably be the
> >       responsibility of the C lib to make sure it doesn't tag heap
> >       allocations. If the user did not opt-in, the syscalls are routed
> >       through the normal path (no untagging address shim).
> >
> >    b) ioctl() and other blacklisted syscalls (prctl) will not accept
> >       tagged pointers (to be documented in Vicenzo's ABI patches).
[...]
> Any userspace shim approach is problematic for Android because of the
> apps that use raw system calls. AFAIK, all apps written in Go are in
> that camp - I'm not sure how common they are, but getting them all
> recompiled is probably not realistic.

That's a fair point (I wasn't expecting it would get much traction
anyway ;)). OTOH, it allows upstreaming of the MTE patches while we
continue the discussions around TBI.

> The way I see it, a patch that breaks handling of tagged pointers is
> not that different from, say, a patch that adds a wild pointer
> dereference. Both are bugs; the difference is that (a) the former
> breaks a relatively uncommon target and (b) it's arguably an easier
> mistake to make. If MTE adoption goes well, (a) will not be the case
> for long.

It's also the fact such patch would go unnoticed for a long time until
someone exercises that code path. And when they do, the user would be
pretty much in the dark trying to figure what what went wrong, why a
SIGSEGV or -EFAULT happened. What's worse, we can't even say we fixed
all the places where it matters in the current kernel codebase (ignoring
future patches).

I think we should revisit the static checking discussions we had last
year. Run-time checking (even with compiler instrumentation and
syzkaller fuzzing) would only cover the code paths specific to a Linux
or Android installation.

> This is a bit of a chicken-and-egg problem. In a world where memory
> allocators on one or several popular platforms generate pointers with
> non-zero tags, any such breakage will be caught in testing.
> Unfortunately to reach that state we need the kernel to start
> accepting tagged pointers first, and then hold on for a couple of
> years until userspace catches up.

Would the kernel also catch up with providing a stable ABI? Because we
have two moving targets.

On one hand, you have Android or some Linux distro that stick to a
stable kernel version for some time, so they have better chance of
clearing most of the problems. On the other hand, we have mainline
kernel that gets over 500K lines every release. As maintainer, I can't
rely on my testing alone as this is on a limited number of platforms. So
my concern is that every kernel release has a significant chance of
breaking the ABI, unless we have a better way of identifying potential
issues.

> Perhaps we can start by whitelisting ioctls by driver?

This was also raised by Ruben in private but without a (static) tool to
to check, manually going through all the drivers doesn't scale. It's
very likely that most drivers don't care, just a get_user/put_user is
already handled by these patches. Searching for find_vma() was
identifying one such use-case but is this sufficient? Are there other
cases we need to explicitly untag a pointer?


The other point I'd like feedback on is 2.a above. I see _some_ value
into having the user opt-in to this relaxed ABI rather than blinding
exposing it to all applications. Dave suggested (in private) a new
personality (e.g. PER_LINUX_TBI) inherited by children. It would be the
responsibility of the C library to check the current personality bits
and only tag pointers on allocation *if* the kernel allowed it. The
kernel could provide the AT_FLAGS bit as in Vincenzo's patches if the
personality was set but can't set it retrospectively if the user called
sys_personality. By default, /sbin/init would not have this personality
and libc would not tag pointers, so we can guarantee that your distro
boots normally with a new kernel version. We could have an envp that
gets caught by /sbin/init so you can pass it on the kernel command line
(or a dynamic loader at run-time). But the default should be the current
ABI behaviour.

We can enforce the current behaviour by having access_ok() check the
personality or a TIF flag but we may relax this enforcement at some
point in the future as we learn more about the implications of TBI.

Thanks.

-- 
Catalin

