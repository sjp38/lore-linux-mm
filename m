Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFAC0C43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 21:20:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F92A2085A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 21:20:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="Tz3wIEMJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F92A2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DB986B0006; Wed, 19 Jun 2019 17:20:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08E108E0002; Wed, 19 Jun 2019 17:20:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBEA48E0001; Wed, 19 Jun 2019 17:20:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id C363F6B0006
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 17:20:38 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id h184so200388oif.16
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 14:20:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bI9P9AKaggByB2J+3Bzt1bHMyBdbzhZul43br86InHM=;
        b=QeJaYfJuaSChpe26XQfG8qcq/XQi03dgceJMlo8SeiaoFSHfOUMn3+ZT8lzHQxrH/g
         8dlA0YTaAquwjmurenWr9KzE24iPxXhHSgDqOYtGG7zWesZHns6Pme0bplObiD+vpDoO
         BfivBZREabr+BsjrjKNa0ZhnWolQ0fEVmHaUlaj/dwhxv9egNrmtiN0+Bayxv6GNJGxO
         7PNTf4ZPuhaBUdKVLZP8piqZ53yCsifE/qHsR/OmBZeQtD7C8AgIu0gls2InwdzBDvGo
         j+/GScfElk2wX4Qz4pVVqKi+eGf4+nTGSI+2lzlt363Twt8qH4uRRi+9bIqrYtuyVmlf
         2WoA==
X-Gm-Message-State: APjAAAUrPZsTc33+8qGfKkkVPbvmlz0V2dHGEaZ9vu336FVgaLrS8tiQ
	tC+VjxsEPCmxwZ6W/mQREpDrNprYqKQzGNGkml9ZI/GB7dOxGH+pIjZzWJhbjWXqkcu9HnCbb8x
	g0rAizPEbzgdWfRO1fY7YLWxayX1z1XUkjlTp9lC70ef6moLiJL5ec3qTZjshsOl7Kg==
X-Received: by 2002:a54:4694:: with SMTP id k20mr3728450oic.136.1560979238321;
        Wed, 19 Jun 2019 14:20:38 -0700 (PDT)
X-Received: by 2002:a54:4694:: with SMTP id k20mr3728411oic.136.1560979237649;
        Wed, 19 Jun 2019 14:20:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560979237; cv=none;
        d=google.com; s=arc-20160816;
        b=QPD7uXXr1XbSs0lNLEhHZqNDQCj0Rmf3Y0GKDi+/TrSmjbObbRjQJOeKHVayrFC/ls
         /W/6SEYGX9Hb3qVo7YRq7xbjgaHXmG/SSzW7s5tXBvtyH6y5Az7KJDYapCUBHW9MaaZj
         gXyzC2dbVyPihY03FuzoUDhr/P0eooETU0Cu6pSz53CSID2GBTNU3ZQKaTyCD/Lkemdq
         1Zfr8zxQ/HJfjy6qXUgk6M20IqlovEY4GZP2RjEterUWMQ0OZgv+hOHSJCrRkJr/fNiH
         3bwJ+YsjIewZ3bHdwoabzsv1GVeYm5N5ayBNikqdup00IJcjiJTptYnIf10bSwxszxAR
         I2xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bI9P9AKaggByB2J+3Bzt1bHMyBdbzhZul43br86InHM=;
        b=u9m1LYM7pwbtT/iREvQB20iNajD2Jac3vVB5gzhfUOhy+JDEn82u95ocn5cljyID0y
         ycNFXNiukbEC07I15clwWhr9oc2L6YeQoUsoF2wL5DNEUm/7w5eYda1VLpe5G3WInG4Q
         oAILYnT949qkZxEc91NGC6UEUFi6tn8tgGoFXRETZRCWciWcylLaY/9CIAnfTjJVevIW
         Kjv7J17ESFacZMPYZcqoYSHjAlSD/2zVwBZQ6U/pqe0C2b6+gJyGa5QeTQqgjhVy8XuM
         XBsz0i2Mb0uw5BMJ038F5W/gMI6M4uxBzUqh2do5phEiOjSGwIDEQ02g4x/jjisysPT9
         PbPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=Tz3wIEMJ;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x11sor6850683oia.38.2019.06.19.14.20.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 14:20:37 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=Tz3wIEMJ;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bI9P9AKaggByB2J+3Bzt1bHMyBdbzhZul43br86InHM=;
        b=Tz3wIEMJQ6KUu24p8kJGpTzmA6Co/vmiIUI3dfmnw92cqIil2cOfv4n0isjZeDFBj/
         N2DwUQt3F8qi0Lq/xtl6BMeVRiOStswnCRJNxGBm9I3jcsl0Vin08++XC8/kTEXa8Rb4
         gdhuT8fnTwj/ll0yWjskwxZDpP7xdYe59hvjI=
X-Google-Smtp-Source: APXvYqx/TLTpB9wGr9JZtdZ6RHY2xIrpHVS+clHcKNaPFf5G0BlbrC2hAFkgq7x4pUPG8gx88sa6UIhdMVbNbLa5tDI=
X-Received: by 2002:a05:6808:118:: with SMTP id b24mr3757147oie.128.1560979237149;
 Wed, 19 Jun 2019 14:20:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
 <20190521154411.GD3836@redhat.com> <20190618152215.GG12905@phenom.ffwll.local>
 <20190619165055.GI9360@ziepe.ca> <CAKMK7uGpupxF8MdyX3_HmOfc+OkGxVM_b9WbF+S-2fHe0F5SQA@mail.gmail.com>
 <20190619201340.GL9360@ziepe.ca> <CAKMK7uGtXT1qLdUqnmTd9uUkdMrcreg4UmAxscx0Fp4Pv6uj_A@mail.gmail.com>
 <20190619204243.GM9360@ziepe.ca>
In-Reply-To: <20190619204243.GM9360@ziepe.ca>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Wed, 19 Jun 2019 23:20:23 +0200
Message-ID: <CAKMK7uEJu4+gDLGDabxeDpArgXEGQ0B+9Z_SUM2zTB4QsnTB+g@mail.gmail.com>
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

On Wed, Jun 19, 2019 at 10:42 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Wed, Jun 19, 2019 at 10:18:43PM +0200, Daniel Vetter wrote:
> > On Wed, Jun 19, 2019 at 10:13 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > On Wed, Jun 19, 2019 at 09:57:15PM +0200, Daniel Vetter wrote:
> > > > On Wed, Jun 19, 2019 at 6:50 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > > > On Tue, Jun 18, 2019 at 05:22:15PM +0200, Daniel Vetter wrote:
> > > > > > On Tue, May 21, 2019 at 11:44:11AM -0400, Jerome Glisse wrote:
> > > > > > > On Mon, May 20, 2019 at 11:39:42PM +0200, Daniel Vetter wrote:
> > > > > > > > Just a bit of paranoia, since if we start pushing this deep into
> > > > > > > > callchains it's hard to spot all places where an mmu notifier
> > > > > > > > implementation might fail when it's not allowed to.
> > > > > > > >
> > > > > > > > Inspired by some confusion we had discussing i915 mmu notifiers and
> > > > > > > > whether we could use the newly-introduced return value to handle some
> > > > > > > > corner cases. Until we realized that these are only for when a task
> > > > > > > > has been killed by the oom reaper.
> > > > > > > >
> > > > > > > > An alternative approach would be to split the callback into two
> > > > > > > > versions, one with the int return value, and the other with void
> > > > > > > > return value like in older kernels. But that's a lot more churn for
> > > > > > > > fairly little gain I think.
> > > > > > > >
> > > > > > > > Summary from the m-l discussion on why we want something at warning
> > > > > > > > level: This allows automated tooling in CI to catch bugs without
> > > > > > > > humans having to look at everything. If we just upgrade the existing
> > > > > > > > pr_info to a pr_warn, then we'll have false positives. And as-is, no
> > > > > > > > one will ever spot the problem since it's lost in the massive amounts
> > > > > > > > of overall dmesg noise.
> > > > > > > >
> > > > > > > > v2: Drop the full WARN_ON backtrace in favour of just a pr_warn for
> > > > > > > > the problematic case (Michal Hocko).
> > > > >
> > > > > I disagree with this v2 note, the WARN_ON/WARN will trigger checkers
> > > > > like syzkaller to report a bug, while a random pr_warn probably will
> > > > > not.
> > > > >
> > > > > I do agree the backtrace is not useful here, but we don't have a
> > > > > warn-no-backtrace version..
> > > > >
> > > > > IMHO, kernel/driver bugs should always be reported by WARN &
> > > > > friends. We never expect to see the print, so why do we care how big
> > > > > it is?
> > > > >
> > > > > Also note that WARN integrates an unlikely() into it so the codegen is
> > > > > automatically a bit more optimal that the if & pr_warn combination.
> > > >
> > > > Where do you make a difference between a WARN without backtrace and a
> > > > pr_warn? They're both dumped at the same log-level ...
> > >
> > > WARN panics the kernel when you set
> > >
> > > /proc/sys/kernel/panic_on_warn
> > >
> > > So auto testing tools can set that and get a clean detection that the
> > > kernel has failed the test in some way.
> > >
> > > Otherwise you are left with frail/ugly grepping of dmesg.
> >
> > Hm right.
> >
> > Anyway, I'm happy to repaint the bikeshed in any color that's desired,
> > if that helps with landing it. WARN_WITHOUT_BACKTRACE might take a bit
> > longer (need to find a bit of time, plus it'll definitely attract more
> > comments).
>
> I was actually just writing something very similar when looking at the
> hmm things..
>
> Also, is the test backwards?

Yes, in the last rebase I screwed things up :-/
-Daniel

> mmu_notifier_range_blockable() == true means the callback must return
> zero
>
> mmu_notififer_range_blockable() == false means the callback can return
> 0 or -EAGAIN.
>
> Suggest this:
>
>                                 pr_info("%pS callback failed with %d in %sblockable context.\n",
>                                         mn->ops->invalidate_range_start, _ret,
>                                         !mmu_notifier_range_blockable(range) ? "non-" : "");
> +                               WARN_ON(mmu_notifier_range_blockable(range) ||
> +                                       _ret != -EAGAIN);
>                                 ret = _ret;
>                         }
>                 }
>
> To express the API invariant.
>
> Jason



-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

