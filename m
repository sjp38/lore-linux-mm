Return-Path: <SRS0=X77i=TF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5E4EC004C9
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 14:21:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E994206DF
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 14:21:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AWQlbU8V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E994206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDC426B0005; Sun,  5 May 2019 10:21:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D65E46B0006; Sun,  5 May 2019 10:21:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDE296B0007; Sun,  5 May 2019 10:21:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 87E536B0005
	for <linux-mm@kvack.org>; Sun,  5 May 2019 10:21:44 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id m8so3768735oih.0
        for <linux-mm@kvack.org>; Sun, 05 May 2019 07:21:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IQqSIA7uD5M0wQf7Hipk4HlzkvDnQtg0hg1zEHr33zY=;
        b=pxEOoKQvPS6jKxB5cIEhfg1SyYcu5BXW1UXVz7nSvOky5xmNUuR4a9yStDtDoPMEMD
         MWObjOIx9T1VpPWNJCLVjjlHWDvS/0MjsUdnf72VAzWblG20mhF+Eg2QDnyl+gj9Jpt5
         Gw4grbWZpeygoCnr1el3JGJYMrup8WWjp5gLt0eOdfe0ftdj7x3CoWJs6AxaMhVBrLtC
         YJDUS5HCEIdZKAGcebyMCOuPSbJYF8eVVuCASvVPH8LJ8OhfKL8A0W1UqVj7vqHDRdjQ
         d5OsTo9OXkbQqidgrl+vqf/EvhIf+o87Ztn0igoTj+LNd4LM8hYBZza/HzNHWuopsHsC
         OoEw==
X-Gm-Message-State: APjAAAVd8aaw/B+GCYdTqllI2t56UB2JGNMSfd16tKKewngzu+3ybTZF
	131pl6SQozbQB0Q3J8ikziAS2Q1ylPkprAFq9gZdT/vOCdPB/4scVbmOyfZwE1h3CrZm4t5Co3y
	bC0eELpZSBY7nYxQ5j5XBNV7yyuu0tNW9WNhRNCMvT28ika0qXJsTccfa0OekCASltw==
X-Received: by 2002:aca:d7d5:: with SMTP id o204mr5515742oig.23.1557066103803;
        Sun, 05 May 2019 07:21:43 -0700 (PDT)
X-Received: by 2002:aca:d7d5:: with SMTP id o204mr5515705oig.23.1557066102855;
        Sun, 05 May 2019 07:21:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557066102; cv=none;
        d=google.com; s=arc-20160816;
        b=JKFcer8e/15GKv3yuqmTjXUOkdgo3CGYTJCQc7OeyZEAMCsbaUj8J70ehHWgQSFoQ5
         jiK3g7a5ljfdCUm3tIlRbRH/HGf7oRAgUa07F0t2wKHXTlf458dpI2TXf7bzKPytL1Hu
         bAWlyp2+Zj2+3LOEcbQVNfcACnFOk2+JbFAPx/EbN60GI4ny/rcyGUZpdcXXECZaEwi+
         pMas+EKeLcSs+T7m/7+pyHHMSQyivINqbjgpjO724+e+KVKTaeogF7v1aaiGrxuoe0yG
         zs5qFS49GeGjVm153kccPFu0FxiAJ7hLtjvMrCTlonKYJOgr6OutjbUaW4ny5RLfl6R0
         7wpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IQqSIA7uD5M0wQf7Hipk4HlzkvDnQtg0hg1zEHr33zY=;
        b=B/h0XQgnTVAzynbCiNCRT9+5B3OLCBq7wb4ZuFaAPDVQU+26/R867UWbFhq6g5SU+w
         /RLDXczZIdgipbd3v8WsV50ZiWlEfruZSJDamADqKX8YkdsdC8AEsBg2qyX9LooU33f1
         fi1WSPhUepbz8mMAISY50RXooWHVFXBC/rJzuWVyNEb3Q4TQkY+MpPr13Ynzqp3zUqgO
         Pg4jfT31ktuND9Ajoicb9VoLBcJe6GubHiSgM98cLjyBD4YOakeCvZQfXo+E9kRhfUNa
         U5ScH8nfRvOqx87oWDVrGDIhy7OIJbPP7PT3tC0jCPbd3QE4T/VGM2gsKwVHwf++P+rH
         b7Sw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AWQlbU8V;
       spf=pass (google.com: domain of y2kenny@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=y2kenny@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b199sor3168169oih.93.2019.05.05.07.21.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 05 May 2019 07:21:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of y2kenny@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AWQlbU8V;
       spf=pass (google.com: domain of y2kenny@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=y2kenny@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IQqSIA7uD5M0wQf7Hipk4HlzkvDnQtg0hg1zEHr33zY=;
        b=AWQlbU8VoVdVOq3fIViQl9WYLUDY46SLhaBmW9Msab5SMYgL0D5pHgqnoecO4JXrdp
         2K/zjn5/HgnHS3DI4TKeICobLr5jNn3MZFF8AWGvOzgMQvaFxHj0UersObHSwzbqjCHU
         kXFFzOlrutozkLHx0JC/PEftOVW4BUW7jl9QNtEAmrYuDNdqb7lyNN17WYTdeLCmWnPy
         UnxDtMS+e3G9oMwruAOb/RYs10NL5OqNm6D+D7hRvzETt/45lB6Xuk6D+wbdv1aVOktJ
         iYhmorWgDXqeGGDkgoGwbfAGo4MEe7F2Ixq+NKElGpK8fo9OAlyHVml2Qc8WS9v2A1Yi
         1sNg==
X-Google-Smtp-Source: APXvYqxtCTlnFpaog3a+ume/+CFEM0o9HMexE6GdSPSB//kAtVjADF27eCZpP5vpBUt2GA/SlUqk8VsrOlucOhccchs=
X-Received: by 2002:aca:72c9:: with SMTP id p192mr5372420oic.164.1557066102015;
 Sun, 05 May 2019 07:21:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190501140438.9506-1-brian.welty@intel.com> <20190502083433.GP7676@mtr-leonro.mtl.com>
 <CAOWid-cYknxeTQvP9vQf3-i3Cpux+bs7uBs7_o-YMFjVCo19bg@mail.gmail.com>
 <bb001de0-e4e5-6b3f-7ced-9d0fb329635b@intel.com> <20190505071436.GD6938@mtr-leonro.mtl.com>
In-Reply-To: <20190505071436.GD6938@mtr-leonro.mtl.com>
From: Kenny Ho <y2kenny@gmail.com>
Date: Sun, 5 May 2019 10:21:30 -0400
Message-ID: <CAOWid-di8kcC2bYKq1KJo+rWfVjwQ13mcVRjaBjhFRzTO=c16Q@mail.gmail.com>
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

On Sun, May 5, 2019 at 3:14 AM Leon Romanovsky <leon@kernel.org> wrote:
> > > Doesn't RDMA already has a separate cgroup?  Why not implement it there?
> > >
> >
> > Hi Kenny, I can't answer for Leon, but I'm hopeful he agrees with rationale
> > I gave in the cover letter.  Namely, to implement in rdma controller, would
> > mean duplicating existing memcg controls there.
>
> Exactly, I didn't feel comfortable to add notion of "device memory"
> to RDMA cgroup and postponed that decision to later point of time.
> RDMA operates with verbs objects and all our user space API is based around
> that concept. At the end, system administrator will have hard time to
> understand the differences between memcg and RDMA memory.
Interesting.  I actually don't understand this part (I worked in
devops/sysadmin side of things but never with rdma.)  Don't
applications that use rdma require some awareness of rdma (I mean, you
mentioned verbs and objects... or do they just use regular malloc for
buffer allocation and then send it through some function?)  As a user,
I would have this question: why do I need to configure some part of
rdma resources under rdma cgroup while other part of rdma resources in
a different, seemingly unrelated cgroups.

I think we need to be careful about drawing the line between
duplication and over couplings between subsystems.  I have other
thoughts and concerns and I will try to organize them into a response
in the next few days.

Regards,
Kenny


> >
> > Is AMD interested in collaborating to help shape this framework?
> > It is intended to be device-neutral, so could be leveraged by various
> > types of devices.
> > If you have an alternative solution well underway, then maybe
> > we can work together to merge our efforts into one.
> > In the end, the DRM community is best served with common solution.
> >
> >
> > >
> > >>> and with future work, we could extend to:
> > >>> *  track and control share of GPU time (reuse of cpu/cpuacct)
> > >>> *  apply mask of allowed execution engines (reuse of cpusets)
> > >>>
> > >>> Instead of introducing a new cgroup subsystem for GPU devices, a new
> > >>> framework is proposed to allow devices to register with existing cgroup
> > >>> controllers, which creates per-device cgroup_subsys_state within the
> > >>> cgroup.  This gives device drivers their own private cgroup controls
> > >>> (such as memory limits or other parameters) to be applied to device
> > >>> resources instead of host system resources.
> > >>> Device drivers (GPU or other) are then able to reuse the existing cgroup
> > >>> controls, instead of inventing similar ones.
> > >>>
> > >>> Per-device controls would be exposed in cgroup filesystem as:
> > >>>     mount/<cgroup_name>/<subsys_name>.devices/<dev_name>/<subsys_files>
> > >>> such as (for example):
> > >>>     mount/<cgroup_name>/memory.devices/<dev_name>/memory.max
> > >>>     mount/<cgroup_name>/memory.devices/<dev_name>/memory.current
> > >>>     mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.stat
> > >>>     mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.weight
> > >>>
> > >>> The drm/i915 patch in this series is based on top of other RFC work [1]
> > >>> for i915 device memory support.
> > >>>
> > >>> AMD [2] and Intel [3] have proposed related work in this area within the
> > >>> last few years, listed below as reference.  This new RFC reuses existing
> > >>> cgroup controllers and takes a different approach than prior work.
> > >>>
> > >>> Finally, some potential discussion points for this series:
> > >>> * merge proposed <subsys_name>.devices into a single devices directory?
> > >>> * allow devices to have multiple registrations for subsets of resources?
> > >>> * document a 'common charging policy' for device drivers to follow?
> > >>>
> > >>> [1] https://patchwork.freedesktop.org/series/56683/
> > >>> [2] https://lists.freedesktop.org/archives/dri-devel/2018-November/197106.html
> > >>> [3] https://lists.freedesktop.org/archives/intel-gfx/2018-January/153156.html
> > >>>
> > >>>
> > >>> Brian Welty (5):
> > >>>   cgroup: Add cgroup_subsys per-device registration framework
> > >>>   cgroup: Change kernfs_node for directories to store
> > >>>     cgroup_subsys_state
> > >>>   memcg: Add per-device support to memory cgroup subsystem
> > >>>   drm: Add memory cgroup registration and DRIVER_CGROUPS feature bit
> > >>>   drm/i915: Use memory cgroup for enforcing device memory limit
> > >>>
> > >>>  drivers/gpu/drm/drm_drv.c                  |  12 +
> > >>>  drivers/gpu/drm/drm_gem.c                  |   7 +
> > >>>  drivers/gpu/drm/i915/i915_drv.c            |   2 +-
> > >>>  drivers/gpu/drm/i915/intel_memory_region.c |  24 +-
> > >>>  include/drm/drm_device.h                   |   3 +
> > >>>  include/drm/drm_drv.h                      |   8 +
> > >>>  include/drm/drm_gem.h                      |  11 +
> > >>>  include/linux/cgroup-defs.h                |  28 ++
> > >>>  include/linux/cgroup.h                     |   3 +
> > >>>  include/linux/memcontrol.h                 |  10 +
> > >>>  kernel/cgroup/cgroup-v1.c                  |  10 +-
> > >>>  kernel/cgroup/cgroup.c                     | 310 ++++++++++++++++++---
> > >>>  mm/memcontrol.c                            | 183 +++++++++++-
> > >>>  13 files changed, 552 insertions(+), 59 deletions(-)
> > >>>
> > >>> --
> > >>> 2.21.0
> > >>>
> > >> _______________________________________________
> > >> dri-devel mailing list
> > >> dri-devel@lists.freedesktop.org
> > >> https://lists.freedesktop.org/mailman/listinfo/dri-devel

