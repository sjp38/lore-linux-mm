Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E924AC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:56:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 991802083D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:56:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="srMzDC+m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 991802083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4368F6B0003; Mon, 25 Mar 2019 12:56:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E5A66B0006; Mon, 25 Mar 2019 12:56:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D5716B0007; Mon, 25 Mar 2019 12:56:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0940A6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 12:56:57 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d8so9127055qkk.17
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 09:56:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=hdrToB2TSv1yp4eb70QIvwrlSIW2W5jFyB226wrDD0Q=;
        b=qkf/qojS/ogO1NAnQL4xtfqXYOXPRfjp7Oa+zlhl9TS5j2U+2ndkYrGWSeeCQ7/rJI
         h4npjdhSWJ1pi5RLS71lYUPMgH+DCQDOEhFYwoKzcv4gBN3CkkkyIacBGndnNiU4/JXR
         XFdv17b8FhEqLdqWH3UtUHn6J6qlJBfVXQ5BiQ0d9UO5BdS9wxJ889UWMExuCerIW7ov
         g4PBP7WyIPL5Tzeeguh6lRDy4nP5oETQ9tfF8c6Bg0I2wtj23+M8ns4g/sVXJmGxW/59
         vg/frbywf9cR36FrdFmmuMr9Npo7aqFSpmKCSt/jq22ilI3zaa3Rta7EpbEYw3hKAw2U
         qOcQ==
X-Gm-Message-State: APjAAAWjw0njz/Uh0UiTCYLvapbRddLDc8s3NZYDxaNNIbtC95iAi6BY
	u7s611ZFy7G4RE0yhgCv6JVSsRk4zHHEMIuXB6odkOE9jgnKq++2S2Q9ODTEcjfYBKFs3Y+cMUb
	IksiJUEVXN9wEwziXkHojPP56bPOuFOCXJiwXDgw2Wvn0XOBM4Vqggtz2Hr3i/AlveQ==
X-Received: by 2002:a05:620a:13d7:: with SMTP id g23mr20166848qkl.198.1553533016801;
        Mon, 25 Mar 2019 09:56:56 -0700 (PDT)
X-Received: by 2002:a05:620a:13d7:: with SMTP id g23mr20166798qkl.198.1553533016082;
        Mon, 25 Mar 2019 09:56:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553533016; cv=none;
        d=google.com; s=arc-20160816;
        b=S9WOOrmtEs5YJcZU00dzm2Y613EfROuMYsx0gJC5QMUqRC0tvnO71VzOJYAHEgAT2i
         7dqTLk0p9DgHZyGJIFykvVvykLbUWAJPI++BZwUaRi0TQiYgfYU3JK/7OfI5rQTO0Qc9
         GMZebF4PLx5YWPYrpSSx772j3+KhwSyT3mj9Umocxyb0DAZjD6qezR01jEwnMZoHOgLj
         QZUV4rKzkMQQAGmdwbSgDiMPI02CLYnhdIWNGdlHemKAauGfGTDr1ty7NVZ7dy14Hhze
         8/gOfESk+r8LUHGEKOilgGCVlkf0TjqLSa/aVr/Vg1hzXR1voJoOAlRlQV9i3HUrgS7Z
         YF/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=hdrToB2TSv1yp4eb70QIvwrlSIW2W5jFyB226wrDD0Q=;
        b=GG+v0p/nIbm6S0wP5FN7IWuLZ2oz14fjVqUY7Ggk59YOIZerDEGBzcleifgmuEgiWL
         I3OptjoFyke1FAXNyccZkrNQtSCr3cUadl0NjUEMjvql+vHIKUGaTa6/HhA2oRLGpN2d
         2QS/JEvClRmy9ye+3cjc0xuqI0bba3EAfJJdkTgcDE6e9rXZTEGeXyP6SZqdKc9YeooI
         D95SRQc0bF1rusz0tvpg72xkMCMCc96W80nJ9+hq+EmcgCTb1yxs3S2+uIIe93OAvWew
         ybqAkesPLeg4UX4/141Rm3//5YyV0DMykp1oO1CCH+WPMf5SLb0hapQo8HvlxqvoJ0sy
         8JzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=srMzDC+m;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v15sor25605623qth.40.2019.03.25.09.56.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 09:56:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=srMzDC+m;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=hdrToB2TSv1yp4eb70QIvwrlSIW2W5jFyB226wrDD0Q=;
        b=srMzDC+ms5YQVqrvZwEGDX/E/ckzFQVhFOG1bMHwhic4SroBbCVHANYL/SW7vm3dcp
         avpmvQxnZulEN13hnbtVkEInZPvG6TPTYzdDrz+/SKsrOhPEA9oiiF754eehdWTs2lLD
         Gm7FtbqtzbumYo/P3bUaAQK0CG5bPTt/s9ZE4Xqrz46K+vzzbO3DuYepBASZG0TS4WLX
         nliN3mXxhSN40Ia6QSqWfU9+lMq2AO9rAOlFtskjaIc+pmLucpgXw6v4ByzXWNa2jc7l
         toVmuhIDkJ9VSAsPKdzbegy/3sLS/c7VmTttjV+bhDJF9mZUrMjXI6G474lIcbTt1PeZ
         rgAQ==
X-Google-Smtp-Source: APXvYqy5O1uj8uqWIybnhXlb2Rx+YIOdNrjiO8M6dBrKRM6Bjpvp5sf0FW3DMqU3p8w8Fpikdd4u7Clq96P0hl/KHRU=
X-Received: by 2002:ac8:32fb:: with SMTP id a56mr21951184qtb.338.1553533015773;
 Mon, 25 Mar 2019 09:56:55 -0700 (PDT)
MIME-Version: 1.0
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com> <cc6f44e2-48b5-067f-9685-99d8ae470b50@inria.fr>
In-Reply-To: <cc6f44e2-48b5-067f-9685-99d8ae470b50@inria.fr>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 25 Mar 2019 09:56:44 -0700
Message-ID: <CAPcyv4it1w7SdDVBV24cRCVHtLb3s1pVB5+SDM02Uw4RbahKiA@mail.gmail.com>
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@suse.com>, 
	Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@surriel.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Dave Hansen <dave.hansen@intel.com>, Keith Busch <keith.busch@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>, 
	"Huang, Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 9:15 AM Brice Goglin <Brice.Goglin@inria.fr> wrote:
>
>
> Le 23/03/2019 =C3=A0 05:44, Yang Shi a =C3=A9crit :
> > With Dave Hansen's patches merged into Linus's tree
> >
> > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/comm=
it/?id=3Dc221c0b0308fd01d9fb33a16f64d2fd95f8830a4
> >
> > PMEM could be hot plugged as NUMA node now. But, how to use PMEM as NUM=
A node
> > effectively and efficiently is still a question.
> >
> > There have been a couple of proposals posted on the mailing list [1] [2=
].
> >
> > The patchset is aimed to try a different approach from this proposal [1=
]
> > to use PMEM as NUMA nodes.
> >
> > The approach is designed to follow the below principles:
> >
> > 1. Use PMEM as normal NUMA node, no special gfp flag, zone, zonelist, e=
tc.
> >
> > 2. DRAM first/by default. No surprise to existing applications and defa=
ult
> > running. PMEM will not be allocated unless its node is specified explic=
itly
> > by NUMA policy. Some applications may be not very sensitive to memory l=
atency,
> > so they could be placed on PMEM nodes then have hot pages promote to DR=
AM
> > gradually.
>
>
> I am not against the approach for some workloads. However, many HPC
> people would rather do this manually. But there's currently no easy way
> to find out from userspace whether a given NUMA node is DDR or PMEM*. We
> have to assume HMAT is available (and correct) and look at performance
> attributes. When talking to humans, it would be better to say "I
> allocated on the local DDR NUMA node" rather than "I allocated on the
> fastest node according to HMAT latency".
>
> Also, when we'll have HBM+DDR, some applications may want to use DDR by
> default, which means they want the *slowest* node according to HMAT (by
> the way, will your hybrid policy work if we ever have HBM+DDR+PMEM?).
> Performance attributes could help, but how does user-space know for sure
> that X>Y will still mean HBM>DDR and not DDR>PMEM in 5 years?
>
> It seems to me that exporting a flag in sysfs saying whether a node is
> PMEM could be convenient. Patch series [1] exported a "type" in sysfs
> node directories ("pmem" or "dram"). I don't know how if there's an easy
> way to define what HBM is and expose that type too.

I'm generally against the concept that a "pmem" or "type" flag should
indicate anything about the expected performance of the address range.
The kernel should explicitly look to the HMAT for performance data and
not otherwise make type-based performance assumptions.

