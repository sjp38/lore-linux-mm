Return-Path: <SRS0=X77i=TF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E376C004C9
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 16:55:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51A50208C0
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 16:55:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="pH+cJZVJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51A50208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E532C6B0005; Sun,  5 May 2019 12:55:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E05566B0006; Sun,  5 May 2019 12:55:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCBBC6B0007; Sun,  5 May 2019 12:55:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 91D1C6B0005
	for <linux-mm@kvack.org>; Sun,  5 May 2019 12:55:46 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id q73so6536301pfi.17
        for <linux-mm@kvack.org>; Sun, 05 May 2019 09:55:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Pt7IYDcjG+VErRYfpe/XkcHYA4eSA3LRC4h8pRnF1Rg=;
        b=twH+mZV2n+Id5E+ZdUsFyZRcN2pDVD2os1+sNiA6Z9/I6iL9cSoo3vl05LAk6G7dSW
         iFpfVi8Y1UEyoGOAoutLXxYjMHDOSwsHIEDwCmpgEU838UBYDVnyua7yLsYOwmRGIEgr
         vSGQw48rt2XeGM7yPd+GgYckpwqD7mwf11qDSxGpIwCmMTVhu9pP0IeE2+4KM8i+/02S
         mbRY2T74F4AwxIsuCVSrVVeelpDPuqKv9bHWsUby4OIK9jJxddu6uXwXVphF53kMpAAG
         R3raH3T/CzFRZpXODKehVfyM5oow8AaPfEbGYFoOq6bJ9FSnir7TU8mudP2vuRgyxDIo
         ya2Q==
X-Gm-Message-State: APjAAAVQV/38J44kf+JWeUw7sGXuAEBcZZ+pwQG+/CucKYTjhyuG11bd
	9AzhGi528676AnQh9UDY7l/RWNQydSsoPhK4WpOLRt8DqukBN+NNEnvgNDDSu1O/3EXrnjkfqlb
	gnow/qMVrZcJWJe1lxzZ8seblmlLwJllCOtaaIFYRNgi0ROwtMfU7FpqnDGAXSFEOiQ==
X-Received: by 2002:a17:902:a510:: with SMTP id s16mr1466933plq.334.1557075346119;
        Sun, 05 May 2019 09:55:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylJzXkmNUkCtov5WIv4yYQrkfkYFKYdQpf6qLLYyEs2MZA47JtqQI0xMRi5lvY23GlZ09E
X-Received: by 2002:a17:902:a510:: with SMTP id s16mr1466846plq.334.1557075345195;
        Sun, 05 May 2019 09:55:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557075345; cv=none;
        d=google.com; s=arc-20160816;
        b=EcivjKHBPctPrQvAKk919IQSk+63aPm6ZmVF8q3mHdkK3p5xgu61NX8ti6caPweEIV
         5yhOqVYlEAJ8CBAG9MOX/2tr79GEn6EcyuOXSROd4S2+F2Syfq4/bFnPur5HV+5D4OfU
         f9T9X7JmmwK8njOo1cox/fj7VtG3mEC0kHAatR7TmmCh5B3EaINvvT2EOEpxwgNHl1Db
         4G5cgExuq/qYQLcXduMekcM+oMW7w3WbODH99Ue79Ys5+Q9uWAvtMqyvXoP0KaxVKOcV
         yXDZQSUDc67R5kM5dsHDNxchw1waV3SFYZ2c9/qd5rqaXv6DkybQva6157VCWmbsqxD9
         26AQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Pt7IYDcjG+VErRYfpe/XkcHYA4eSA3LRC4h8pRnF1Rg=;
        b=SSVJqIUIFZhyJJy8PzOZdhJ/Dwm0yJq/LmvzgD+KWjfSKLLbpIBAuMlzTV5AL99iUn
         sySA5/l01RgwB20s7SnQVeDuveVbWuh+7NsWpgJVyj5XKQbPcJFkaZtyJck0PmGxO3Qq
         qgF+7/3MsuGQUlRUZZnTLatUzpygL2miXBX1/prZFB92ZYDTzTLNTmZsGu1EJvS6y5pQ
         8B6UvTALiOIF/++F01OVCUYQgFJf4PJjFLACywsv49o+JrG3cVok826mXXERzBeojFup
         +FHdMQN4Yo8lgdeUBLccqS3MQYIklaTtt2z4rRh9ZU2bmOJDPBGfVyKQQMJHehQWeFrN
         4lGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=pH+cJZVJ;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n16si11121346plp.130.2019.05.05.09.55.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 May 2019 09:55:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=pH+cJZVJ;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [37.142.3.125])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7391D2082F;
	Sun,  5 May 2019 16:55:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557075344;
	bh=aRxPsmSsEhywsafB/6cwzHPxQmzxvwN6POM3K7wiBMc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=pH+cJZVJ5914OfqP20cZw/Iee2fyUCgsSrb8acFROO0vrORufuqIypqcWfl7HLC85
	 Anc3y755FymA/CTGhQdg6+VULP3UjBlhqCkrnJMpQOibKFKmS/aa+UfPu9A/z8KPhS
	 0kxNvHZa/DmjY2/SIBOSqbLpsY35vDl2mIcQOykw=
Date: Sun, 5 May 2019 19:55:38 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Kenny Ho <y2kenny@gmail.com>
Cc: "Welty, Brian" <brian.welty@intel.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	Parav Pandit <parav@mellanox.com>, David Airlie <airlied@linux.ie>,
	intel-gfx@lists.freedesktop.org,
	J??r??me Glisse <jglisse@redhat.com>,
	dri-devel@lists.freedesktop.org, Michal Hocko <mhocko@kernel.org>,
	linux-mm@kvack.org, Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Li Zefan <lizefan@huawei.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	cgroups@vger.kernel.org,
	Christian K??nig <christian.koenig@amd.com>,
	RDMA mailing list <linux-rdma@vger.kernel.org>, kenny.ho@amd.com,
	Harish.Kasiviswanathan@amd.com, daniel@ffwll.ch
Subject: Re: [RFC PATCH 0/5] cgroup support for GPU devices
Message-ID: <20190505165538.GG6938@mtr-leonro.mtl.com>
References: <20190501140438.9506-1-brian.welty@intel.com>
 <20190502083433.GP7676@mtr-leonro.mtl.com>
 <CAOWid-cYknxeTQvP9vQf3-i3Cpux+bs7uBs7_o-YMFjVCo19bg@mail.gmail.com>
 <bb001de0-e4e5-6b3f-7ced-9d0fb329635b@intel.com>
 <20190505071436.GD6938@mtr-leonro.mtl.com>
 <CAOWid-di8kcC2bYKq1KJo+rWfVjwQ13mcVRjaBjhFRzTO=c16Q@mail.gmail.com>
 <20190505160506.GF6938@mtr-leonro.mtl.com>
 <CAOWid-cCq+yB9m-u8YpHFuhUZ+C7EpbT2OD27iszJVrruAtqKg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOWid-cCq+yB9m-u8YpHFuhUZ+C7EpbT2OD27iszJVrruAtqKg@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 05, 2019 at 12:34:16PM -0400, Kenny Ho wrote:
> (sent again.  Not sure why my previous email was just a reply instead
> of reply-all.)
>
> On Sun, May 5, 2019 at 12:05 PM Leon Romanovsky <leon@kernel.org> wrote:
> > We are talking about two different access patterns for this device
> > memory (DM). One is to use this device memory (DM) and second to configure/limit.
> > Usually those actions will be performed by different groups.
> >
> > First group (programmers) is using special API [1] through libibverbs [2]
> > without any notion of cgroups or any limitations. Second group (sysadmins)
> > is less interested in application specifics and for them "device memory" means
> > "memory" and not "rdma, nic specific, internal memory".
> Um... I am not sure that answered it, especially in the context of
> cgroup (this is just for my curiosity btw, I don't know much about
> rdma.)  You said sysadmins are less interested in application
> specifics but then how would they make the judgement call on how much
> "device memory" is provisioned to one application/container over
> another (let say you have 5 cgroup sharing an rdma device)?  What are
> the consequences of under provisioning "device memory" to an
> application?  And if they are all just memory, can a sysadmin
> provision more system memory in place of device memory (like, are they
> interchangeable)?  I guess I am confused because if device memory is
> just memory (not rdma, nic specific) to sysadmins how would they know
> to set the right amount?

One of the immediate usages of this DM that come to my mind is very
fast spinlocks for MPI applications. In such case, the amount of DM
will be property of network topology in given MPI cluster.

In this scenario, precise amount of memory will ensure that all jobs
will continue to give maximal performance despite any programmer's
error in DM allocation.

For under provisioning scenario and if application is written correctly,
users will experience more latency and less performance, due to the PCI
accesses.

Slide 3 in Liran's presentation gives brief overview about motivation.

Thanks

>
> Regards,
> Kenny
>
> > [1] ibv_alloc_dm()
> > http://man7.org/linux/man-pages/man3/ibv_alloc_dm.3.html
> > https://www.openfabrics.org/images/2018workshop/presentations/304_LLiss_OnDeviceMemory.pdf
> > [2] https://github.com/linux-rdma/rdma-core/blob/master/libibverbs/
> >
> > >
> > > I think we need to be careful about drawing the line between
> > > duplication and over couplings between subsystems.  I have other
> > > thoughts and concerns and I will try to organize them into a response
> > > in the next few days.
> > >
> > > Regards,
> > > Kenny
> > >
> > >
> > > > >
> > > > > Is AMD interested in collaborating to help shape this framework?
> > > > > It is intended to be device-neutral, so could be leveraged by various
> > > > > types of devices.
> > > > > If you have an alternative solution well underway, then maybe
> > > > > we can work together to merge our efforts into one.
> > > > > In the end, the DRM community is best served with common solution.
> > > > >
> > > > >
> > > > > >
> > > > > >>> and with future work, we could extend to:
> > > > > >>> *  track and control share of GPU time (reuse of cpu/cpuacct)
> > > > > >>> *  apply mask of allowed execution engines (reuse of cpusets)
> > > > > >>>
> > > > > >>> Instead of introducing a new cgroup subsystem for GPU devices, a new
> > > > > >>> framework is proposed to allow devices to register with existing cgroup
> > > > > >>> controllers, which creates per-device cgroup_subsys_state within the
> > > > > >>> cgroup.  This gives device drivers their own private cgroup controls
> > > > > >>> (such as memory limits or other parameters) to be applied to device
> > > > > >>> resources instead of host system resources.
> > > > > >>> Device drivers (GPU or other) are then able to reuse the existing cgroup
> > > > > >>> controls, instead of inventing similar ones.
> > > > > >>>
> > > > > >>> Per-device controls would be exposed in cgroup filesystem as:
> > > > > >>>     mount/<cgroup_name>/<subsys_name>.devices/<dev_name>/<subsys_files>
> > > > > >>> such as (for example):
> > > > > >>>     mount/<cgroup_name>/memory.devices/<dev_name>/memory.max
> > > > > >>>     mount/<cgroup_name>/memory.devices/<dev_name>/memory.current
> > > > > >>>     mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.stat
> > > > > >>>     mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.weight
> > > > > >>>
> > > > > >>> The drm/i915 patch in this series is based on top of other RFC work [1]
> > > > > >>> for i915 device memory support.
> > > > > >>>
> > > > > >>> AMD [2] and Intel [3] have proposed related work in this area within the
> > > > > >>> last few years, listed below as reference.  This new RFC reuses existing
> > > > > >>> cgroup controllers and takes a different approach than prior work.
> > > > > >>>
> > > > > >>> Finally, some potential discussion points for this series:
> > > > > >>> * merge proposed <subsys_name>.devices into a single devices directory?
> > > > > >>> * allow devices to have multiple registrations for subsets of resources?
> > > > > >>> * document a 'common charging policy' for device drivers to follow?
> > > > > >>>
> > > > > >>> [1] https://patchwork.freedesktop.org/series/56683/
> > > > > >>> [2] https://lists.freedesktop.org/archives/dri-devel/2018-November/197106.html
> > > > > >>> [3] https://lists.freedesktop.org/archives/intel-gfx/2018-January/153156.html
> > > > > >>>
> > > > > >>>
> > > > > >>> Brian Welty (5):
> > > > > >>>   cgroup: Add cgroup_subsys per-device registration framework
> > > > > >>>   cgroup: Change kernfs_node for directories to store
> > > > > >>>     cgroup_subsys_state
> > > > > >>>   memcg: Add per-device support to memory cgroup subsystem
> > > > > >>>   drm: Add memory cgroup registration and DRIVER_CGROUPS feature bit
> > > > > >>>   drm/i915: Use memory cgroup for enforcing device memory limit
> > > > > >>>
> > > > > >>>  drivers/gpu/drm/drm_drv.c                  |  12 +
> > > > > >>>  drivers/gpu/drm/drm_gem.c                  |   7 +
> > > > > >>>  drivers/gpu/drm/i915/i915_drv.c            |   2 +-
> > > > > >>>  drivers/gpu/drm/i915/intel_memory_region.c |  24 +-
> > > > > >>>  include/drm/drm_device.h                   |   3 +
> > > > > >>>  include/drm/drm_drv.h                      |   8 +
> > > > > >>>  include/drm/drm_gem.h                      |  11 +
> > > > > >>>  include/linux/cgroup-defs.h                |  28 ++
> > > > > >>>  include/linux/cgroup.h                     |   3 +
> > > > > >>>  include/linux/memcontrol.h                 |  10 +
> > > > > >>>  kernel/cgroup/cgroup-v1.c                  |  10 +-
> > > > > >>>  kernel/cgroup/cgroup.c                     | 310 ++++++++++++++++++---
> > > > > >>>  mm/memcontrol.c                            | 183 +++++++++++-
> > > > > >>>  13 files changed, 552 insertions(+), 59 deletions(-)
> > > > > >>>
> > > > > >>> --
> > > > > >>> 2.21.0
> > > > > >>>
> > > > > >> _______________________________________________
> > > > > >> dri-devel mailing list
> > > > > >> dri-devel@lists.freedesktop.org
> > > > > >> https://lists.freedesktop.org/mailman/listinfo/dri-devel

