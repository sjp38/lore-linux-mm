Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C5BCC43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 08:34:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B06ED2089E
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 08:34:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="SbgCz/Ci"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B06ED2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19E6F6B0005; Thu,  2 May 2019 04:34:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 127E16B0006; Thu,  2 May 2019 04:34:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE49A6B0007; Thu,  2 May 2019 04:34:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B2DCA6B0005
	for <linux-mm@kvack.org>; Thu,  2 May 2019 04:34:38 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id j1so870031pll.13
        for <linux-mm@kvack.org>; Thu, 02 May 2019 01:34:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PqiPedEe9YitrejOthOOXjn20qXgmuEnJT+XoMm7BjM=;
        b=Hpxw3/iHudWCjDn+ob2RYN6TOY4K8hFwSEUw+DBIXl+x/Bx+SphjjGLFvUt3xwyewr
         K+cUwYBpvajlQGjk95+SGGtqP4R0mfv89q7++uKlKFoCrxSIR2lV1+7Wj+s8JkrmDiCi
         eaNHIePYczLYhg5B/tkUzWUBxCHPf/NB4RXVcIJVdUiCQLbSDYZMo2T3Z/vGM9w1GY2l
         Pj9/4m27R2E/6iOhZHQjZCpDG86zt+sTIG7nFcnIY6CSK2VXc4lcmS7R3540LtuiK+nu
         b8slDFVR5OBuqiVm4t9fciVHS+/DAMTXbb8Ww2DGZAux2VvRQqVShVSWDCcqr3s0ETdj
         ONcw==
X-Gm-Message-State: APjAAAW1RSYSm5pArIIap+GQMNdtZWoDRMNLBwJvWr87K/h1Ihsnpn00
	mo7xPbeYBRK0VxhbfAq+jdcNg04pp7KDpml8U2JSaGfiOrD7fff5vD9IEzcFDmgi+2LevmDNG6+
	o7JAW40QnHF1XeZbXYteoFq4GofEflzJmgAOipLjUliLq9eESFiT34EIibRvYz/JfBQ==
X-Received: by 2002:a63:5742:: with SMTP id h2mr2697722pgm.194.1556786078109;
        Thu, 02 May 2019 01:34:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2xIO0cEPhCHOY18R/eax+ufcsZ1rrDd2fQ+LsDoaQ8rJCn8dz4B/XhrYPTYhop8RXgZvr
X-Received: by 2002:a63:5742:: with SMTP id h2mr2697680pgm.194.1556786077222;
        Thu, 02 May 2019 01:34:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556786077; cv=none;
        d=google.com; s=arc-20160816;
        b=uH8AC7nt1s/DfqppCnUNRFmJz+BAgD4jjlzkhrrZRxQB5TapW3H7h+Fqg4fxx0KBVd
         D392gXS5UeXso4yZ64823lyNmB6H23tTrsnYhWrenxJBblb/Uv7JFqzEUQT8lYaaH/9C
         iJW1yYgalYU4AnQGTo4UxFiTOs7shXb0Tw6ADh/8Z8lLIFiblLVTPTsMdJJAw8vbb0Hg
         RKWRsJIurXPKkriRc6Qhq+p6Z8t7ulLdecpZNuyJiuVqBr/5Ynlrmo/SRJ5f+rSH7/DO
         45jso2R/bGX6vGDBbNacPq7T+jfgQt9x2o5jlU7Vh5okrx5HZtRaYuFdYYKO9qjidzlX
         90Qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PqiPedEe9YitrejOthOOXjn20qXgmuEnJT+XoMm7BjM=;
        b=Q0bMrNfxl7h7QmymiciipPOl5ZU4KkPoeTS4rvUvUz4pVFrxGyRoI/mT8jDcvn5sxn
         kdKOH/tCpRb0YQdLy7o3l8Qjff7NbGr0NMqMw5jlTr0xq7f+mGaLVyaZ008Yworh1wJ1
         QJd1Cmy4avCvbZFwZaa0qExQmBsJatCUjec70sz49Nk92+WaGPl2wLvbJbyqB+31FZMe
         wNhEO2YnHL/sl8D7xfZhRPEKfMlSSzqo2/afvQw2DfJAI+zSJgPXQHmCtIoUNcle4Sah
         9GQXVmCQBJqRcHW4LaHdblg7t1ya2xHVB+ciBsRN+MDlYYl/AwtYt8FaTAJ444o2VQCR
         LL5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="SbgCz/Ci";
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h26si18870772pfn.240.2019.05.02.01.34.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 01:34:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="SbgCz/Ci";
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [37.142.3.125])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2857820873;
	Thu,  2 May 2019 08:34:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556786076;
	bh=MQjRhogQLnzUq3Lldq3yF0nYV1BdOcxeJjuqAcrDwDs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=SbgCz/Ciyhy9PYlonWt+ep9RVgw8J2IFnpExiZTS5DqSsrl7BV3EvScRoeQcunY8K
	 gkHyue9SwLa/sINCO1qPNZEAsamW8wbTXuAttdzB52fzyO/zsBr82g7MzLfowj53gJ
	 4JRjWY9yKbREVMzC396iMWRTv9obSvTVIbdZHr+E=
Date: Thu, 2 May 2019 11:34:33 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Brian Welty <brian.welty@intel.com>
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>,
	linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>, intel-gfx@lists.freedesktop.org,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	ChunMing Zhou <David1.Zhou@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	RDMA mailing list <linux-rdma@vger.kernel.org>,
	Parav Pandit <parav@mellanox.com>
Subject: Re: [RFC PATCH 0/5] cgroup support for GPU devices
Message-ID: <20190502083433.GP7676@mtr-leonro.mtl.com>
References: <20190501140438.9506-1-brian.welty@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190501140438.9506-1-brian.welty@intel.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2019 at 10:04:33AM -0400, Brian Welty wrote:
> In containerized or virtualized environments, there is desire to have
> controls in place for resources that can be consumed by users of a GPU
> device.  This RFC patch series proposes a framework for integrating
> use of existing cgroup controllers into device drivers.
> The i915 driver is updated in this series as our primary use case to
> leverage this framework and to serve as an example for discussion.
>
> The patch series enables device drivers to use cgroups to control the
> following resources within a GPU (or other accelerator device):
> *  control allocation of device memory (reuse of memcg)

Count us (Mellanox) too, our RDMA devices are exposing special and
limited in size device memory to the users and we would like to provide
an option to use cgroup to control its exposure.

> and with future work, we could extend to:
> *  track and control share of GPU time (reuse of cpu/cpuacct)
> *  apply mask of allowed execution engines (reuse of cpusets)
>
> Instead of introducing a new cgroup subsystem for GPU devices, a new
> framework is proposed to allow devices to register with existing cgroup
> controllers, which creates per-device cgroup_subsys_state within the
> cgroup.  This gives device drivers their own private cgroup controls
> (such as memory limits or other parameters) to be applied to device
> resources instead of host system resources.
> Device drivers (GPU or other) are then able to reuse the existing cgroup
> controls, instead of inventing similar ones.
>
> Per-device controls would be exposed in cgroup filesystem as:
>     mount/<cgroup_name>/<subsys_name>.devices/<dev_name>/<subsys_files>
> such as (for example):
>     mount/<cgroup_name>/memory.devices/<dev_name>/memory.max
>     mount/<cgroup_name>/memory.devices/<dev_name>/memory.current
>     mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.stat
>     mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.weight
>
> The drm/i915 patch in this series is based on top of other RFC work [1]
> for i915 device memory support.
>
> AMD [2] and Intel [3] have proposed related work in this area within the
> last few years, listed below as reference.  This new RFC reuses existing
> cgroup controllers and takes a different approach than prior work.
>
> Finally, some potential discussion points for this series:
> * merge proposed <subsys_name>.devices into a single devices directory?
> * allow devices to have multiple registrations for subsets of resources?
> * document a 'common charging policy' for device drivers to follow?
>
> [1] https://patchwork.freedesktop.org/series/56683/
> [2] https://lists.freedesktop.org/archives/dri-devel/2018-November/197106.html
> [3] https://lists.freedesktop.org/archives/intel-gfx/2018-January/153156.html
>
>
> Brian Welty (5):
>   cgroup: Add cgroup_subsys per-device registration framework
>   cgroup: Change kernfs_node for directories to store
>     cgroup_subsys_state
>   memcg: Add per-device support to memory cgroup subsystem
>   drm: Add memory cgroup registration and DRIVER_CGROUPS feature bit
>   drm/i915: Use memory cgroup for enforcing device memory limit
>
>  drivers/gpu/drm/drm_drv.c                  |  12 +
>  drivers/gpu/drm/drm_gem.c                  |   7 +
>  drivers/gpu/drm/i915/i915_drv.c            |   2 +-
>  drivers/gpu/drm/i915/intel_memory_region.c |  24 +-
>  include/drm/drm_device.h                   |   3 +
>  include/drm/drm_drv.h                      |   8 +
>  include/drm/drm_gem.h                      |  11 +
>  include/linux/cgroup-defs.h                |  28 ++
>  include/linux/cgroup.h                     |   3 +
>  include/linux/memcontrol.h                 |  10 +
>  kernel/cgroup/cgroup-v1.c                  |  10 +-
>  kernel/cgroup/cgroup.c                     | 310 ++++++++++++++++++---
>  mm/memcontrol.c                            | 183 +++++++++++-
>  13 files changed, 552 insertions(+), 59 deletions(-)
>
> --
> 2.21.0
>

