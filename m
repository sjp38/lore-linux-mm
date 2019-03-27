Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AC54C10F00
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:34:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E666421734
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:34:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="SpMk7T5k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E666421734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C9966B0006; Wed, 27 Mar 2019 13:34:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8525D6B0007; Wed, 27 Mar 2019 13:34:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71A816B0008; Wed, 27 Mar 2019 13:34:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8896B0006
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:34:25 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id d38so10580399otb.22
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 10:34:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZRsXKwEPHhNUTMu2VJyKE0P1ypRhb30qPc9+kXhTNCI=;
        b=JrjKk6fDK+scPAJ5MAUvqYmZX0pFXsM+b7Z1lpPrlIobRrwuw0YLWpHSfsoUj3dxA7
         6dNcHsW4bdmKJAEKj6NR1zyLr4FIFAbFkkTwPMxCjdfoNSvT3p1qIx+1qWdgBZ4x0AU6
         NvAWVnhcwp1Lvka868IVFGRfgQpps24Me2TQLC62mwBrTcK3udFxuTSiJCI4MQ/tUsod
         Trlo5i8bLwtPbBZ1lx8PsvHVEJYFWB8fNywymbfGXR+FmTtF0bwmIJ/El3VtQpAE7UG5
         4rmSNMNMk2QkjMhmhD8OvnqjECsWAL5eLeSKlowf8Ywjm6iVkKVEzyjtEUTQzNAorlLi
         hjyQ==
X-Gm-Message-State: APjAAAXgqoi259MbUa6tjotgOkW/Rg3/+wkbg0JbIimCr7kDZMIHZ+pX
	0GwDaDXjJQOwA6s+/i7xM2BIP1Eaj10gUCjJCEOb3LQOZHexlmJoru6Q9uJFV6jQ4u+lNLNw5Dp
	8iZr646rjULvIzKsNdmNeL/uRh82X2nDJI+zcj3Ppllp+4tWkJRNa62+e7zTqpvVgAA==
X-Received: by 2002:a9d:6185:: with SMTP id g5mr29166959otk.346.1553708064923;
        Wed, 27 Mar 2019 10:34:24 -0700 (PDT)
X-Received: by 2002:a9d:6185:: with SMTP id g5mr29166888otk.346.1553708063764;
        Wed, 27 Mar 2019 10:34:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553708063; cv=none;
        d=google.com; s=arc-20160816;
        b=OLo3wjPmQHraeLbPU4K1mlurbhLnYPSbjqmG1GG585MtIkXclgv4udQL9P15vzcUlk
         EgbL3MtuSJOEpU0NzMEwYkUx8GH18MWeVyfhW0leKlRzLctqMTe0CiT4zj+XO0iwPVFe
         zB3VeWWFVxKrVfeQ1W48PUerBowjrjAnU+77PJukuq8KDPuAKR0o8/NleLSn95lCPjZo
         o5dcCOkYMCBNXff991IKcAAxBXB1cvdz4+jBDA5WQB+TyShySCt0EUEFs28cj/LNki3x
         hL4yNsvyCD07RnANJht0NRpyYP0jjHs6vM7V0DF7VYpu740k4HR2DHvD8vWjJcrMm1dE
         wk3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZRsXKwEPHhNUTMu2VJyKE0P1ypRhb30qPc9+kXhTNCI=;
        b=O1zmVuTBT3B+mFWzAztJMgxZCSwG3cwv25+c11Z4MofRof1uYr6WHL5MXonlYn+PgT
         NI0nYOUDNn5atn5l2GxGF1wUfKEhcsLaBAkJMcXrKlFlLsgA6sNA2DdZBb9lA0oqk+nQ
         Xh4ITEV7qUUxPow0GuBNpeArtOa1WZ9LO40Xdc+tc1m5MOXajUP9+b2f2ZPvSfPV5faV
         IsL4vzpcrlOAJ60AxAH5+zVbs2ejzLOyuDgUKVq+ajHDtDWWgWCU+MkP/0G1uPEDE5j7
         1sJELtHe1sIBU+MsVMVeMXaR6epJn/ZiK91N7B0sB+3KP0dwIPU+ZlIcemYMIh+iAsUK
         JS2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=SpMk7T5k;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a65sor11311924oif.23.2019.03.27.10.34.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Mar 2019 10:34:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=SpMk7T5k;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZRsXKwEPHhNUTMu2VJyKE0P1ypRhb30qPc9+kXhTNCI=;
        b=SpMk7T5k0NvEEqCkxi1tLXC9kojAMMvQxHKXEKIiYhA667d9Lz5/3dlkGi+ezJF9sw
         xGawUovX5rJGgxiSTXzxwMxoG2eUa2z1+bWZHetaz0KLWeZ9Uj0nT1fndhArAzXWf9Jd
         rrzFttYZVnLzg2VvzwE9zzEBZo9Y569rS0FwWoWRxC27SWa/q4m2UN1ebraHsHuJQE4i
         u0ZniDUcfjLdpDN8cSxq17pPeDSjFN4x4XcBJb2L4EVLCSWxI8SJy6afDZwdh9gC+EKg
         wknZcUsB7VrHSJ4nbjAw9Q+Xh+b0tyCCOySpDxDBxPVmC+egbI8QUvI8HkxHl5NW4YrZ
         5HJg==
X-Google-Smtp-Source: APXvYqxBxRvNPf/Wmyj09SSAinbLmF5M3ukFAMnMvVfeignI+foFwR6J5f0TuAFFXuWST3g7TFg6qcOgI6Ouue1Iuag=
X-Received: by 2002:aca:f581:: with SMTP id t123mr20475646oih.0.1553708062968;
 Wed, 27 Mar 2019 10:34:22 -0700 (PDT)
MIME-Version: 1.0
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190326135837.GP28406@dhcp22.suse.cz> <43a1a59d-dc4a-6159-2c78-e1faeb6e0e46@linux.alibaba.com>
 <20190326183731.GV28406@dhcp22.suse.cz> <f08fb981-d129-3357-e93a-a6b233aa9891@linux.alibaba.com>
 <20190327090100.GD11927@dhcp22.suse.cz>
In-Reply-To: <20190327090100.GD11927@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 27 Mar 2019 10:34:11 -0700
Message-ID: <CAPcyv4heiUbZvP7Ewoy-Hy=-mPrdjCjEuSw+0rwdOUHdjwetxg@mail.gmail.com>
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Mel Gorman <mgorman@techsingularity.net>, 
	Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, 
	Keith Busch <keith.busch@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, 
	"Du, Fan" <fan.du@intel.com>, "Huang, Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 27, 2019 at 2:01 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 26-03-19 19:58:56, Yang Shi wrote:
> >
> >
> > On 3/26/19 11:37 AM, Michal Hocko wrote:
> > > On Tue 26-03-19 11:33:17, Yang Shi wrote:
> > > >
> > > > On 3/26/19 6:58 AM, Michal Hocko wrote:
> > > > > On Sat 23-03-19 12:44:25, Yang Shi wrote:
> > > > > > With Dave Hansen's patches merged into Linus's tree
> > > > > >
> > > > > > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c221c0b0308fd01d9fb33a16f64d2fd95f8830a4
> > > > > >
> > > > > > PMEM could be hot plugged as NUMA node now. But, how to use PMEM as NUMA node
> > > > > > effectively and efficiently is still a question.
> > > > > >
> > > > > > There have been a couple of proposals posted on the mailing list [1] [2].
> > > > > >
> > > > > > The patchset is aimed to try a different approach from this proposal [1]
> > > > > > to use PMEM as NUMA nodes.
> > > > > >
> > > > > > The approach is designed to follow the below principles:
> > > > > >
> > > > > > 1. Use PMEM as normal NUMA node, no special gfp flag, zone, zonelist, etc.
> > > > > >
> > > > > > 2. DRAM first/by default. No surprise to existing applications and default
> > > > > > running. PMEM will not be allocated unless its node is specified explicitly
> > > > > > by NUMA policy. Some applications may be not very sensitive to memory latency,
> > > > > > so they could be placed on PMEM nodes then have hot pages promote to DRAM
> > > > > > gradually.
> > > > > Why are you pushing yourself into the corner right at the beginning? If
> > > > > the PMEM is exported as a regular NUMA node then the only difference
> > > > > should be performance characteristics (module durability which shouldn't
> > > > > play any role in this particular case, right?). Applications which are
> > > > > already sensitive to memory access should better use proper binding already.
> > > > > Some NUMA topologies might have quite a large interconnect penalties
> > > > > already. So this doesn't sound like an argument to me, TBH.
> > > > The major rationale behind this is we assume the most applications should be
> > > > sensitive to memory access, particularly for meeting the SLA. The
> > > > applications run on the machine may be agnostic to us, they may be sensitive
> > > > or non-sensitive. But, assuming they are sensitive to memory access sounds
> > > > safer from SLA point of view. Then the "cold" pages could be demoted to PMEM
> > > > nodes by kernel's memory reclaim or other tools without impairing the SLA.
> > > >
> > > > If the applications are not sensitive to memory access, they could be bound
> > > > to PMEM or allowed to use PMEM (nice to have allocation on DRAM) explicitly,
> > > > then the "hot" pages could be promoted to DRAM.
> > > Again, how is this different from NUMA in general?
> >
> > It is still NUMA, users still can see all the NUMA nodes.
>
> No, Linux NUMA implementation makes all numa nodes available by default
> and provides an API to opt-in for more fine tuning. What you are
> suggesting goes against that semantic and I am asking why. How is pmem
> NUMA node any different from any any other distant node in principle?

Agree. It's just another NUMA node and shouldn't be special cased.
Userspace policy can choose to avoid it, but typical node distance
preference should otherwise let the kernel fall back to it as
additional memory pressure relief for "near" memory.

