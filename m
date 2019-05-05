Return-Path: <SRS0=X77i=TF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC8B3C004C9
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 16:34:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F694208C2
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 16:34:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bpOJuZUW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F694208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B1156B0005; Sun,  5 May 2019 12:34:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 539FE6B0006; Sun,  5 May 2019 12:34:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DAFB6B0007; Sun,  5 May 2019 12:34:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE546B0005
	for <linux-mm@kvack.org>; Sun,  5 May 2019 12:34:30 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id m8so3812726oih.0
        for <linux-mm@kvack.org>; Sun, 05 May 2019 09:34:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=O+AqmGA1khN7ngJc0ZfAQ9ZHtbvZiM8Fy0KHh6RIYhw=;
        b=cfS4xCH8L0jAwA6SQeL7kGvyfVYreUmmoh5RbOA4ekqCUpdlUn+D0ycySSWhN08BpK
         nBio5O4U1d9DxU/WzTIVSfLoYJwrhyNVuAVpzjExIQdvVtqGY8Ofr6gTA+xA6fqMLJqN
         tdtU17L6K6qC7Mmqutt3qSUAhWF8cm/2pL4x86IjzChrtFw+by+E24181VzD/YXCNIPT
         JPWbgCYr5mIdFaQKdC8idxn6cUcq7Iy7AtS7WpmFGPz8eumxlJGgKQcI8tCVK7Pfb8+1
         4tFE8qCpecIqa+d0v9SZPCA5a4fKma5Tt6cGKFfcgjPTINoeXCo4I9SHhu9BzltjsHii
         MYzw==
X-Gm-Message-State: APjAAAUOGgHDecROQJ1turaM0bt/UnqqEoo0oCfbrjAcCo+95oK6GMkQ
	HcdS2zHFwJ4yWVVg9dIpw8rVpdvRPMrLbb/Y+3b73k62QC1XxQY1q1guAw/y5Aavyn9Xajby8M+
	1wXBu2y4WclMqBaQX99r1VMgr/ig1hCsQUL4ytP+ti9wAdGsbSxydfOjbRWuaqta3/Q==
X-Received: by 2002:a9d:1428:: with SMTP id h37mr3053608oth.248.1557074069660;
        Sun, 05 May 2019 09:34:29 -0700 (PDT)
X-Received: by 2002:a9d:1428:: with SMTP id h37mr3053569oth.248.1557074068733;
        Sun, 05 May 2019 09:34:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557074068; cv=none;
        d=google.com; s=arc-20160816;
        b=bck8i/38d9KBOqd9O/P5gNuYytbmex0NEf82t3/gCjeXJCk8sI4xRlVR+4rYUW+BMA
         gsJMCP9eSSJl9VNwG3iYtSxpbTOULN0BCUy0YShyy4UXE+N4W6rFCq2s0wcr3vl/2laA
         DeMXVbV49bAXNndAbplpwao5xly8MZZkXGRHEfz4V8DYtRpud8S40V0UGHbRWLGsvYB5
         tGmi/022Zd1cgaLkxGF0LOniSO5fbfK0qKL/ysq7p4Hfy/k6wgB50uu4rRspRkMs4R1S
         HkDBd+2YOwpBPCuDsA1C1AYtreZuluomliLh+zhxP96XuMprZVVNLFpEQjEEIJ8yLMe+
         yXnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=O+AqmGA1khN7ngJc0ZfAQ9ZHtbvZiM8Fy0KHh6RIYhw=;
        b=DbrUDMlJ1zZPW8kXanIf/XcPIFuYvo+1/26lv7Ap+7ISn1fhtlXZFkD19wq4JRwuuo
         0w9lx+Cxug4K9rEGowe2Mv+pVKG5zENM4AS7Z8Bhl7D4sFI2Xs4TLLJESaIP3934ptNM
         d/kSGcisNNZdfValP1zEfrBKUWjxy8URpJSfD6NXCln6gxPsLVB2JUf3sCcuyOgA0MgR
         NJRt1sRKcwcAnptpiNwTMWJMeBUpcbrw8PW4zA9gPCIArfh0Bv7jldmqBoJk7B2KC/N1
         j4uKCYQwfCEb/5fb2Eqbl9FcimEmLGQteY/+X1MueOwu2ScPcmSDhRoDjS7kTPNMb4ns
         plzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bpOJuZUW;
       spf=pass (google.com: domain of y2kenny@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=y2kenny@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u127sor3151727oib.153.2019.05.05.09.34.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 05 May 2019 09:34:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of y2kenny@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bpOJuZUW;
       spf=pass (google.com: domain of y2kenny@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=y2kenny@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=O+AqmGA1khN7ngJc0ZfAQ9ZHtbvZiM8Fy0KHh6RIYhw=;
        b=bpOJuZUWfu1VCJlWJGbXcLeANja/tSPpwm/jvTmNj5ct+99nh4P1CRCUAuHgaGnfhw
         OlEfJTcupsY4Qb1hwVZkV7Bfl2EfmsCtn1d3w4hfgFhUpqO8eljskVqqhFof8RSew5bf
         DR4hecP3vxAXac8OGOWCjCZ4EwI+778W+IaV667hLEfOkva5sqdwcthk+WRqvaVRnzM7
         DYRgOnifflfTIN7jhl9jAQWI0YYkzfDuR/5zu3XwiFk6iCPhF7PX3HLQAKLQM/egeCBY
         I7Kon+VpCQ/gMwVc/6obeLLNoka7jPza8yqIi1xdh3K2GzwIZG20pM20wZYgcB/wiPKi
         V6sA==
X-Google-Smtp-Source: APXvYqznNdaTthFfZhnnE3Ih2EQZ5gWVyu3zldH1UFKrO9xEYtStVjoQSDhP9lWEbuWptvmVGjY3mUgw0FJ0fLgC2Fk=
X-Received: by 2002:aca:d90a:: with SMTP id q10mr5892836oig.65.1557074068215;
 Sun, 05 May 2019 09:34:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190501140438.9506-1-brian.welty@intel.com> <20190502083433.GP7676@mtr-leonro.mtl.com>
 <CAOWid-cYknxeTQvP9vQf3-i3Cpux+bs7uBs7_o-YMFjVCo19bg@mail.gmail.com>
 <bb001de0-e4e5-6b3f-7ced-9d0fb329635b@intel.com> <20190505071436.GD6938@mtr-leonro.mtl.com>
 <CAOWid-di8kcC2bYKq1KJo+rWfVjwQ13mcVRjaBjhFRzTO=c16Q@mail.gmail.com> <20190505160506.GF6938@mtr-leonro.mtl.com>
In-Reply-To: <20190505160506.GF6938@mtr-leonro.mtl.com>
From: Kenny Ho <y2kenny@gmail.com>
Date: Sun, 5 May 2019 12:34:16 -0400
Message-ID: <CAOWid-cCq+yB9m-u8YpHFuhUZ+C7EpbT2OD27iszJVrruAtqKg@mail.gmail.com>
Subject: Re: [RFC PATCH 0/5] cgroup support for GPU devices
To: Leon Romanovsky <leon@kernel.org>
Cc: "Welty, Brian" <brian.welty@intel.com>, Alex Deucher <alexander.deucher@amd.com>, 
	Parav Pandit <parav@mellanox.com>, David Airlie <airlied@linux.ie>, intel-gfx@lists.freedesktop.org, 
	"J??r??me Glisse" <jglisse@redhat.com>, dri-devel@lists.freedesktop.org, 
	Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, 
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Li Zefan <lizefan@huawei.com>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, 
	cgroups@vger.kernel.org, "Christian K??nig" <christian.koenig@amd.com>, 
	RDMA mailing list <linux-rdma@vger.kernel.org>, kenny.ho@amd.com, 
	Harish.Kasiviswanathan@amd.com, daniel@ffwll.ch
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

(sent again.  Not sure why my previous email was just a reply instead
of reply-all.)

On Sun, May 5, 2019 at 12:05 PM Leon Romanovsky <leon@kernel.org> wrote:
> We are talking about two different access patterns for this device
> memory (DM). One is to use this device memory (DM) and second to configure/limit.
> Usually those actions will be performed by different groups.
>
> First group (programmers) is using special API [1] through libibverbs [2]
> without any notion of cgroups or any limitations. Second group (sysadmins)
> is less interested in application specifics and for them "device memory" means
> "memory" and not "rdma, nic specific, internal memory".
Um... I am not sure that answered it, especially in the context of
cgroup (this is just for my curiosity btw, I don't know much about
rdma.)  You said sysadmins are less interested in application
specifics but then how would they make the judgement call on how much
"device memory" is provisioned to one application/container over
another (let say you have 5 cgroup sharing an rdma device)?  What are
the consequences of under provisioning "device memory" to an
application?  And if they are all just memory, can a sysadmin
provision more system memory in place of device memory (like, are they
interchangeable)?  I guess I am confused because if device memory is
just memory (not rdma, nic specific) to sysadmins how would they know
to set the right amount?

Regards,
Kenny

> [1] ibv_alloc_dm()
> http://man7.org/linux/man-pages/man3/ibv_alloc_dm.3.html
> https://www.openfabrics.org/images/2018workshop/presentations/304_LLiss_OnDeviceMemory.pdf
> [2] https://github.com/linux-rdma/rdma-core/blob/master/libibverbs/
>
> >
> > I think we need to be careful about drawing the line between
> > duplication and over couplings between subsystems.  I have other
> > thoughts and concerns and I will try to organize them into a response
> > in the next few days.
> >
> > Regards,
> > Kenny
> >
> >
> > > >
> > > > Is AMD interested in collaborating to help shape this framework?
> > > > It is intended to be device-neutral, so could be leveraged by various
> > > > types of devices.
> > > > If you have an alternative solution well underway, then maybe
> > > > we can work together to merge our efforts into one.
> > > > In the end, the DRM community is best served with common solution.
> > > >
> > > >
> > > > >
> > > > >>> and with future work, we could extend to:
> > > > >>> *  track and control share of GPU time (reuse of cpu/cpuacct)
> > > > >>> *  apply mask of allowed execution engines (reuse of cpusets)
> > > > >>>
> > > > >>> Instead of introducing a new cgroup subsystem for GPU devices, a new
> > > > >>> framework is proposed to allow devices to register with existing cgroup
> > > > >>> controllers, which creates per-device cgroup_subsys_state within the
> > > > >>> cgroup.  This gives device drivers their own private cgroup controls
> > > > >>> (such as memory limits or other parameters) to be applied to device
> > > > >>> resources instead of host system resources.
> > > > >>> Device drivers (GPU or other) are then able to reuse the existing cgroup
> > > > >>> controls, instead of inventing similar ones.
> > > > >>>
> > > > >>> Per-device controls would be exposed in cgroup filesystem as:
> > > > >>>     mount/<cgroup_name>/<subsys_name>.devices/<dev_name>/<subsys_files>
> > > > >>> such as (for example):
> > > > >>>     mount/<cgroup_name>/memory.devices/<dev_name>/memory.max
> > > > >>>     mount/<cgroup_name>/memory.devices/<dev_name>/memory.current
> > > > >>>     mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.stat
> > > > >>>     mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.weight
> > > > >>>
> > > > >>> The drm/i915 patch in this series is based on top of other RFC work [1]
> > > > >>> for i915 device memory support.
> > > > >>>
> > > > >>> AMD [2] and Intel [3] have proposed related work in this area within the
> > > > >>> last few years, listed below as reference.  This new RFC reuses existing
> > > > >>> cgroup controllers and takes a different approach than prior work.
> > > > >>>
> > > > >>> Finally, some potential discussion points for this series:
> > > > >>> * merge proposed <subsys_name>.devices into a single devices directory?
> > > > >>> * allow devices to have multiple registrations for subsets of resources?
> > > > >>> * document a 'common charging policy' for device drivers to follow?
> > > > >>>
> > > > >>> [1] https://patchwork.freedesktop.org/series/56683/
> > > > >>> [2] https://lists.freedesktop.org/archives/dri-devel/2018-November/197106.html
> > > > >>> [3] https://lists.freedesktop.org/archives/intel-gfx/2018-January/153156.html
> > > > >>>
> > > > >>>
> > > > >>> Brian Welty (5):
> > > > >>>   cgroup: Add cgroup_subsys per-device registration framework
> > > > >>>   cgroup: Change kernfs_node for directories to store
> > > > >>>     cgroup_subsys_state
> > > > >>>   memcg: Add per-device support to memory cgroup subsystem
> > > > >>>   drm: Add memory cgroup registration and DRIVER_CGROUPS feature bit
> > > > >>>   drm/i915: Use memory cgroup for enforcing device memory limit
> > > > >>>
> > > > >>>  drivers/gpu/drm/drm_drv.c                  |  12 +
> > > > >>>  drivers/gpu/drm/drm_gem.c                  |   7 +
> > > > >>>  drivers/gpu/drm/i915/i915_drv.c            |   2 +-
> > > > >>>  drivers/gpu/drm/i915/intel_memory_region.c |  24 +-
> > > > >>>  include/drm/drm_device.h                   |   3 +
> > > > >>>  include/drm/drm_drv.h                      |   8 +
> > > > >>>  include/drm/drm_gem.h                      |  11 +
> > > > >>>  include/linux/cgroup-defs.h                |  28 ++
> > > > >>>  include/linux/cgroup.h                     |   3 +
> > > > >>>  include/linux/memcontrol.h                 |  10 +
> > > > >>>  kernel/cgroup/cgroup-v1.c                  |  10 +-
> > > > >>>  kernel/cgroup/cgroup.c                     | 310 ++++++++++++++++++---
> > > > >>>  mm/memcontrol.c                            | 183 +++++++++++-
> > > > >>>  13 files changed, 552 insertions(+), 59 deletions(-)
> > > > >>>
> > > > >>> --
> > > > >>> 2.21.0
> > > > >>>
> > > > >> _______________________________________________
> > > > >> dri-devel mailing list
> > > > >> dri-devel@lists.freedesktop.org
> > > > >> https://lists.freedesktop.org/mailman/listinfo/dri-devel

