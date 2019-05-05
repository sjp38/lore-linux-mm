Return-Path: <SRS0=X77i=TF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1FAFC004C9
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 16:05:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21588208CA
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 16:05:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="iSHEX7oD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21588208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 996886B0005; Sun,  5 May 2019 12:05:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9477A6B0006; Sun,  5 May 2019 12:05:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 810256B0007; Sun,  5 May 2019 12:05:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 47B8C6B0005
	for <linux-mm@kvack.org>; Sun,  5 May 2019 12:05:16 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 94so4113655plc.19
        for <linux-mm@kvack.org>; Sun, 05 May 2019 09:05:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tRbOFHVouu5thpu0OxPF2YRnqbWVWCPI4H/4NTlV1FQ=;
        b=qLkTmhDaoM1V/4n2iEBYwlgx0LbYxrZg0tMOIwKkBiMVodkLvNLowZ5RalB9yjoVMz
         6Qs1m/qlepYmljoWl0BUVNGqAMEbiH2z6z1u1iozy0vg5slSJ8K+SOksACLuquZtiNur
         WShsGkyqzxpD4bN4d0SnSqOwH5m5/wns/o77ayqe/5Kgg/x34ZOhU1M9bJ/zSR5R1AXw
         0PbvreIFIp0t+tBBJ5otjYEVSX0aPu6vO7Z1LZmsSFE3VmaGJr7kOvAOiS5St1c5ay93
         qG1RpLGSqg7QNhG+PZamd8s7EKoh4t9D/ngni4e0TKDncrIXbcxHjPg/gIoIiF3mH4KH
         rHQA==
X-Gm-Message-State: APjAAAVfB68/bgw7tTzrzzItlcG6rAPjXH+QGBV15mML1+Mh0YLgrp60
	D1pOJ713c87aAuTvZXGfHss99FSQGJxYqQHVVYlmVkjAj0ZUHW7pAJq6lEwnFT2hBXi9GJ7taOU
	I+nuKHaKfAPiXJG4Ir2lYy8sEAe1Tkxksh1YLf8Xe5YjlmQmktsCbPZ1KgFmGEDXXKw==
X-Received: by 2002:a62:b602:: with SMTP id j2mr26847961pff.68.1557072315698;
        Sun, 05 May 2019 09:05:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuMxZD+0/MqNI3AwsY7MO6xhilWwQxDnhL/pWtkkNvhTVaE/u7uUnNcp/oTc4FlK3CGHc4
X-Received: by 2002:a62:b602:: with SMTP id j2mr26847809pff.68.1557072314298;
        Sun, 05 May 2019 09:05:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557072314; cv=none;
        d=google.com; s=arc-20160816;
        b=LHZa3oR+KLfgBZX4yL/PAwfBeZvYZFFOqlLo/9MQRVQyjQx0j3ZlgL7DHKkca8gfhV
         Mt+hxhWlHpXL4qKDkT3gUKFjVvOqCpFUbKoiGPDS1UqE/dMIISVf4EkayZE8HxNjdQCU
         C65U5r+93tapgoouyeqJPEQ2Mi4nCsZQQsxPn1nHsJuuyumHnhH4mF7iZMO7W3syq00+
         jbgaaRYKR3ZXU33Yi07ZpUOID0TzPU5lHP64QKrOgqxU48Abh1mcqRiRYRW0d6s/UA81
         Ks8n9QfnmP0YxqmL2dxZE7j7DSDuqelpGhVAa8I8SPeARTpNz8f8B6Dw4e9oFiYMRRnT
         ymPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tRbOFHVouu5thpu0OxPF2YRnqbWVWCPI4H/4NTlV1FQ=;
        b=A4KtvJR/AlWSjuI0cSNezufLVgSCbtk36Ze7vQZioZYP3lxFk/uzYl4yTRDzYqtnne
         V3/LnK5nh/1FIbZbJqShJAlovId4V8xLt7gbsBtOLwbhij8nm9h+rYW6ETcOre7D6DPU
         VSkie3+UsGZy/R9jI1Mq4J2CtDhM5+z+DSQU1tip1c2xWq3saSrqUlc9Dw85iiiLKSUm
         0QKaeuCbF29/M/DgcqSroBzvTR2TccCFDWDTlZZGt6wwdgPaA0vFwQ34wZVw1o7cbAtz
         VkERMIHbrcQIOB293weZX8Pl3b85WVbgsDjktX9gMckeyf7dWo2HQYZOsC2QjHgpxE58
         h99A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=iSHEX7oD;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e24si10669436pgh.403.2019.05.05.09.05.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 May 2019 09:05:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=iSHEX7oD;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [37.142.3.125])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5FD9820578;
	Sun,  5 May 2019 16:05:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557072313;
	bh=kB1uTzGh63D8tqYgHuHg3cawHsaxwBbxWZjl/mhPpi4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=iSHEX7oDEbQ2TzqNO58+cB0qVE0booUv02H/Z1iqx+EteRDxu6yevP4Jw02NpWY0Z
	 in5maay3Cv4QDB4lStQJwZxFcWInUu/Npf7YYZyAuwjZXnsYvogQuYUQmNI2rvS8F9
	 VVCpKH+e9jO1Rzc4eFqosfSEmBRSxKwnQU5laIZY=
Date: Sun, 5 May 2019 19:05:06 +0300
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
Message-ID: <20190505160506.GF6938@mtr-leonro.mtl.com>
References: <20190501140438.9506-1-brian.welty@intel.com>
 <20190502083433.GP7676@mtr-leonro.mtl.com>
 <CAOWid-cYknxeTQvP9vQf3-i3Cpux+bs7uBs7_o-YMFjVCo19bg@mail.gmail.com>
 <bb001de0-e4e5-6b3f-7ced-9d0fb329635b@intel.com>
 <20190505071436.GD6938@mtr-leonro.mtl.com>
 <CAOWid-di8kcC2bYKq1KJo+rWfVjwQ13mcVRjaBjhFRzTO=c16Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOWid-di8kcC2bYKq1KJo+rWfVjwQ13mcVRjaBjhFRzTO=c16Q@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 05, 2019 at 10:21:30AM -0400, Kenny Ho wrote:
> On Sun, May 5, 2019 at 3:14 AM Leon Romanovsky <leon@kernel.org> wrote:
> > > > Doesn't RDMA already has a separate cgroup?  Why not implement it there?
> > > >
> > >
> > > Hi Kenny, I can't answer for Leon, but I'm hopeful he agrees with rationale
> > > I gave in the cover letter.  Namely, to implement in rdma controller, would
> > > mean duplicating existing memcg controls there.
> >
> > Exactly, I didn't feel comfortable to add notion of "device memory"
> > to RDMA cgroup and postponed that decision to later point of time.
> > RDMA operates with verbs objects and all our user space API is based around
> > that concept. At the end, system administrator will have hard time to
> > understand the differences between memcg and RDMA memory.
> Interesting.  I actually don't understand this part (I worked in
> devops/sysadmin side of things but never with rdma.)  Don't
> applications that use rdma require some awareness of rdma (I mean, you
> mentioned verbs and objects... or do they just use regular malloc for
> buffer allocation and then send it through some function?)  As a user,
> I would have this question: why do I need to configure some part of
> rdma resources under rdma cgroup while other part of rdma resources in
> a different, seemingly unrelated cgroups.

We are talking about two different access patterns for this device
memory (DM). One is to use this device memory (DM) and second to configure/limit.
Usually those actions will be performed by different groups.

First group (programmers) is using special API [1] through libibverbs [2]
without any notion of cgroups or any limitations. Second group (sysadmins)
is less interested in application specifics and for them "device memory" means
"memory" and not "rdma, nic specific, internal memory".

[1] ibv_alloc_dm()
http://man7.org/linux/man-pages/man3/ibv_alloc_dm.3.html
https://www.openfabrics.org/images/2018workshop/presentations/304_LLiss_OnDeviceMemory.pdf
[2] https://github.com/linux-rdma/rdma-core/blob/master/libibverbs/

>
> I think we need to be careful about drawing the line between
> duplication and over couplings between subsystems.  I have other
> thoughts and concerns and I will try to organize them into a response
> in the next few days.
>
> Regards,
> Kenny
>
>
> > >
> > > Is AMD interested in collaborating to help shape this framework?
> > > It is intended to be device-neutral, so could be leveraged by various
> > > types of devices.
> > > If you have an alternative solution well underway, then maybe
> > > we can work together to merge our efforts into one.
> > > In the end, the DRM community is best served with common solution.
> > >
> > >
> > > >
> > > >>> and with future work, we could extend to:
> > > >>> *  track and control share of GPU time (reuse of cpu/cpuacct)
> > > >>> *  apply mask of allowed execution engines (reuse of cpusets)
> > > >>>
> > > >>> Instead of introducing a new cgroup subsystem for GPU devices, a new
> > > >>> framework is proposed to allow devices to register with existing cgroup
> > > >>> controllers, which creates per-device cgroup_subsys_state within the
> > > >>> cgroup.  This gives device drivers their own private cgroup controls
> > > >>> (such as memory limits or other parameters) to be applied to device
> > > >>> resources instead of host system resources.
> > > >>> Device drivers (GPU or other) are then able to reuse the existing cgroup
> > > >>> controls, instead of inventing similar ones.
> > > >>>
> > > >>> Per-device controls would be exposed in cgroup filesystem as:
> > > >>>     mount/<cgroup_name>/<subsys_name>.devices/<dev_name>/<subsys_files>
> > > >>> such as (for example):
> > > >>>     mount/<cgroup_name>/memory.devices/<dev_name>/memory.max
> > > >>>     mount/<cgroup_name>/memory.devices/<dev_name>/memory.current
> > > >>>     mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.stat
> > > >>>     mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.weight
> > > >>>
> > > >>> The drm/i915 patch in this series is based on top of other RFC work [1]
> > > >>> for i915 device memory support.
> > > >>>
> > > >>> AMD [2] and Intel [3] have proposed related work in this area within the
> > > >>> last few years, listed below as reference.  This new RFC reuses existing
> > > >>> cgroup controllers and takes a different approach than prior work.
> > > >>>
> > > >>> Finally, some potential discussion points for this series:
> > > >>> * merge proposed <subsys_name>.devices into a single devices directory?
> > > >>> * allow devices to have multiple registrations for subsets of resources?
> > > >>> * document a 'common charging policy' for device drivers to follow?
> > > >>>
> > > >>> [1] https://patchwork.freedesktop.org/series/56683/
> > > >>> [2] https://lists.freedesktop.org/archives/dri-devel/2018-November/197106.html
> > > >>> [3] https://lists.freedesktop.org/archives/intel-gfx/2018-January/153156.html
> > > >>>
> > > >>>
> > > >>> Brian Welty (5):
> > > >>>   cgroup: Add cgroup_subsys per-device registration framework
> > > >>>   cgroup: Change kernfs_node for directories to store
> > > >>>     cgroup_subsys_state
> > > >>>   memcg: Add per-device support to memory cgroup subsystem
> > > >>>   drm: Add memory cgroup registration and DRIVER_CGROUPS feature bit
> > > >>>   drm/i915: Use memory cgroup for enforcing device memory limit
> > > >>>
> > > >>>  drivers/gpu/drm/drm_drv.c                  |  12 +
> > > >>>  drivers/gpu/drm/drm_gem.c                  |   7 +
> > > >>>  drivers/gpu/drm/i915/i915_drv.c            |   2 +-
> > > >>>  drivers/gpu/drm/i915/intel_memory_region.c |  24 +-
> > > >>>  include/drm/drm_device.h                   |   3 +
> > > >>>  include/drm/drm_drv.h                      |   8 +
> > > >>>  include/drm/drm_gem.h                      |  11 +
> > > >>>  include/linux/cgroup-defs.h                |  28 ++
> > > >>>  include/linux/cgroup.h                     |   3 +
> > > >>>  include/linux/memcontrol.h                 |  10 +
> > > >>>  kernel/cgroup/cgroup-v1.c                  |  10 +-
> > > >>>  kernel/cgroup/cgroup.c                     | 310 ++++++++++++++++++---
> > > >>>  mm/memcontrol.c                            | 183 +++++++++++-
> > > >>>  13 files changed, 552 insertions(+), 59 deletions(-)
> > > >>>
> > > >>> --
> > > >>> 2.21.0
> > > >>>
> > > >> _______________________________________________
> > > >> dri-devel mailing list
> > > >> dri-devel@lists.freedesktop.org
> > > >> https://lists.freedesktop.org/mailman/listinfo/dri-devel

