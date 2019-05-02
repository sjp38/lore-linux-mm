Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC875C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 22:48:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77815206DF
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 22:48:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lKkyAyPK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77815206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 274686B000A; Thu,  2 May 2019 18:48:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 224396B000C; Thu,  2 May 2019 18:48:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EC256B000D; Thu,  2 May 2019 18:48:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA9836B000A
	for <linux-mm@kvack.org>; Thu,  2 May 2019 18:48:13 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id w3so1698214otg.11
        for <linux-mm@kvack.org>; Thu, 02 May 2019 15:48:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/WKHdnz38BeGL2pjuVKVInpoD4DDdnvc5veO1RpWfD0=;
        b=g/P0ZT8S30EnfAkhSsokAnLXVhT9k6efouoM2mc5mguPpe/ISIpKxSdB5jH9gDQogs
         UhzXJ5c91C6D1qb25E5s7CfUVygZXZtZQnKtAjbcRh63mVIMuDvWCXT3A9J7tZo5R3rD
         U4K+2DOR3AOE5I1yqk9QbqkEij2MkYYt64OB40KRtbkqfuBbwpxdzKyB0APKxUenjC+S
         KjDZF+r2nuvdjDWT8IXlRteiMRAybk8o3D1qjYjKNfhKQbLFe5LGpjkYu7FzrjUEOIm5
         cBGcRI1mNWd8HVI3ZsNmyVMy5MP5G/DU+3utJvfPOh8atNw4pCL5dtyF79B19/dKrgVq
         MveA==
X-Gm-Message-State: APjAAAUQ3dmH/FG2WBalEtQbWLUx/GfnhAjxaB/r3bYKadwgv26IEC7r
	kTReeLydk3I4i3X/wRrmWHR+x5npJKb0bqfvTzktxZLs1Lk1lWtibQwxFTlzKygTVBgswDGP+G5
	T0pMnv8Li02Ai2UdB+pDzcUIF1V6oj9korU18p2HA5vVNZr/AWy9lZdsTg0GQ66ZmGg==
X-Received: by 2002:a9d:6153:: with SMTP id c19mr4407280otk.110.1556837293496;
        Thu, 02 May 2019 15:48:13 -0700 (PDT)
X-Received: by 2002:a9d:6153:: with SMTP id c19mr4407249otk.110.1556837292699;
        Thu, 02 May 2019 15:48:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556837292; cv=none;
        d=google.com; s=arc-20160816;
        b=GLv7LEASArrwgEwdY4xEDoIZVMRy6Xyus0O26eSDLtT0h1d0FdPIMhrYXRGfh8JKW1
         Xy5p4GdD2lBsdNE0zgQshAqerjK74G21/lrHPYFR1hWrsHKwHXettLhbrLXu88vYmNV0
         qwFlAr+gl6g8f+fYYquiCtNP2PKTwfMw2RsMeHe0aEpL0uoxl/tT5CW/ryxnuw8CGX7H
         tvm9ypXJjPAfWmGtpD2gLqPA2k7mU8ol4tEnRyWb5EORBgYjA2vfsEmM8eC+Ks0Y2DMH
         hA8qv6PMkFhxw6OCrPT0KEmCZd6TZd2HJDjr+LlGeNC+Rt9NEzu2Le8+FtgxfGXJ5auh
         X+0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/WKHdnz38BeGL2pjuVKVInpoD4DDdnvc5veO1RpWfD0=;
        b=TBEJqBsGrs/A60QeaHEP5AzI6ybleHBFd1ADd77he2z2EhEbftuE1pEk45yf16inqf
         Js32AXC0v5KX6puK6FBCwLY6J4Qr9SvkC1O38pJzWpqOePA/5pLJ9Euw+Kmbb9hn3ap2
         WVM8lIdauoQ82NBkAOxvZ+0Zgfv12Jw7Gx/RSUtyaPA1PG6L1PPlX5b4l7IhLHnD+o8t
         FBhyutpEy2N4Bwh9a2nZ8g/5nzfHqMBEy/pdaBc3k69IW5EATeTBRgTGp601XW8RVeM6
         dWuo25RZSnjrO6knZDNa8hSv//slQ+Bf0pkiBU63J5H+rrwBVjvZvlpWzqLS5eGyYCIB
         Wuvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lKkyAyPK;
       spf=pass (google.com: domain of y2kenny@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=y2kenny@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t62sor184994oig.135.2019.05.02.15.48.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 15:48:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of y2kenny@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lKkyAyPK;
       spf=pass (google.com: domain of y2kenny@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=y2kenny@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/WKHdnz38BeGL2pjuVKVInpoD4DDdnvc5veO1RpWfD0=;
        b=lKkyAyPK+yQFL7c/rX2h7OTRgVgCfGIA3jxuxf0M3WS5KnZpTp8Mykm0JON9M6qmOF
         30RUqUAUZnZXXZ56qm2hLdvg6D1Psc4W/Y3OoXcZI7QxDQ0zn9C+HqN544+NErubH6Rw
         XJm9/tXR6XQawJT3hvz8sYAAZfKW8NOb+Z1DGTxnr8snyHMop8e80SKJpOuMMnzGi215
         nkeBQ0z5As131KYmogi2xGm1lFCfd+O7ajJgqaIybuACpod0//VhJ13cWDX1xSHC2ZnA
         Rh+r2wlqbLEKsWw9wSjkO4K4Ch3fAorDgZGsOwHCpg084Xzfptn6ptbHxrxct0Pvphjq
         9DRg==
X-Google-Smtp-Source: APXvYqx956/X+reg4oVrDOUcjV7/RLFZT10w3z+8wYApEAreW5PVj2U3DhgtoypbznWBNzSrhUtmkdshwuUO1i5ipOo=
X-Received: by 2002:aca:d90a:: with SMTP id q10mr4133282oig.65.1556837292174;
 Thu, 02 May 2019 15:48:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190501140438.9506-1-brian.welty@intel.com> <20190502083433.GP7676@mtr-leonro.mtl.com>
In-Reply-To: <20190502083433.GP7676@mtr-leonro.mtl.com>
From: Kenny Ho <y2kenny@gmail.com>
Date: Thu, 2 May 2019 18:48:00 -0400
Message-ID: <CAOWid-cYknxeTQvP9vQf3-i3Cpux+bs7uBs7_o-YMFjVCo19bg@mail.gmail.com>
Subject: Re: [RFC PATCH 0/5] cgroup support for GPU devices
To: Leon Romanovsky <leon@kernel.org>
Cc: Brian Welty <brian.welty@intel.com>, Alex Deucher <alexander.deucher@amd.com>, 
	Parav Pandit <parav@mellanox.com>, David Airlie <airlied@linux.ie>, intel-gfx@lists.freedesktop.org, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	dri-devel@lists.freedesktop.org, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, 
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Li Zefan <lizefan@huawei.com>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, 
	cgroups@vger.kernel.org, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	RDMA mailing list <linux-rdma@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Count us (Mellanox) too, our RDMA devices are exposing special and
> limited in size device memory to the users and we would like to provide
> an option to use cgroup to control its exposure.
Doesn't RDMA already has a separate cgroup?  Why not implement it there?


> > and with future work, we could extend to:
> > *  track and control share of GPU time (reuse of cpu/cpuacct)
> > *  apply mask of allowed execution engines (reuse of cpusets)
> >
> > Instead of introducing a new cgroup subsystem for GPU devices, a new
> > framework is proposed to allow devices to register with existing cgroup
> > controllers, which creates per-device cgroup_subsys_state within the
> > cgroup.  This gives device drivers their own private cgroup controls
> > (such as memory limits or other parameters) to be applied to device
> > resources instead of host system resources.
> > Device drivers (GPU or other) are then able to reuse the existing cgroup
> > controls, instead of inventing similar ones.
> >
> > Per-device controls would be exposed in cgroup filesystem as:
> >     mount/<cgroup_name>/<subsys_name>.devices/<dev_name>/<subsys_files>
> > such as (for example):
> >     mount/<cgroup_name>/memory.devices/<dev_name>/memory.max
> >     mount/<cgroup_name>/memory.devices/<dev_name>/memory.current
> >     mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.stat
> >     mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.weight
> >
> > The drm/i915 patch in this series is based on top of other RFC work [1]
> > for i915 device memory support.
> >
> > AMD [2] and Intel [3] have proposed related work in this area within the
> > last few years, listed below as reference.  This new RFC reuses existing
> > cgroup controllers and takes a different approach than prior work.
> >
> > Finally, some potential discussion points for this series:
> > * merge proposed <subsys_name>.devices into a single devices directory?
> > * allow devices to have multiple registrations for subsets of resources?
> > * document a 'common charging policy' for device drivers to follow?
> >
> > [1] https://patchwork.freedesktop.org/series/56683/
> > [2] https://lists.freedesktop.org/archives/dri-devel/2018-November/197106.html
> > [3] https://lists.freedesktop.org/archives/intel-gfx/2018-January/153156.html
> >
> >
> > Brian Welty (5):
> >   cgroup: Add cgroup_subsys per-device registration framework
> >   cgroup: Change kernfs_node for directories to store
> >     cgroup_subsys_state
> >   memcg: Add per-device support to memory cgroup subsystem
> >   drm: Add memory cgroup registration and DRIVER_CGROUPS feature bit
> >   drm/i915: Use memory cgroup for enforcing device memory limit
> >
> >  drivers/gpu/drm/drm_drv.c                  |  12 +
> >  drivers/gpu/drm/drm_gem.c                  |   7 +
> >  drivers/gpu/drm/i915/i915_drv.c            |   2 +-
> >  drivers/gpu/drm/i915/intel_memory_region.c |  24 +-
> >  include/drm/drm_device.h                   |   3 +
> >  include/drm/drm_drv.h                      |   8 +
> >  include/drm/drm_gem.h                      |  11 +
> >  include/linux/cgroup-defs.h                |  28 ++
> >  include/linux/cgroup.h                     |   3 +
> >  include/linux/memcontrol.h                 |  10 +
> >  kernel/cgroup/cgroup-v1.c                  |  10 +-
> >  kernel/cgroup/cgroup.c                     | 310 ++++++++++++++++++---
> >  mm/memcontrol.c                            | 183 +++++++++++-
> >  13 files changed, 552 insertions(+), 59 deletions(-)
> >
> > --
> > 2.21.0
> >
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/dri-devel

