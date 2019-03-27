Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8E61C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 22:30:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 510982082F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 22:30:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="aaHOcKbm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 510982082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFC156B0005; Wed, 27 Mar 2019 18:30:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B82B76B0006; Wed, 27 Mar 2019 18:30:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A249D6B0007; Wed, 27 Mar 2019 18:30:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74A1F6B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 18:30:00 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id r136so1444542ith.3
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 15:30:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vb2BrBH4oYQzGEnJbFomSh/8BX3FsNmxH+IKvRIF5+g=;
        b=UC6tdymM2YWzZqUEgGbvaAlASSHOUZjDdoWh+b1JE8i0yj5PnNcbMagAmVZ4XZck3J
         2VNQDRhobH/G/VDSwfAIzmPUmWff87aCSB3n0LFZtJ41iZwUijS0qF2f3q8C6xmFFyFj
         pzfFSWmjqlnN99Kn+kOHk/ADHfG+rd0qc6w90zYVbEP4CF+zLhKQ7T+jAHQcEDlFzby4
         OHkLAWLbWjFRjNzYoDX73FEjYc+JXg2HQIOAqyeCAwmpN2x5ZOAl02DQNcj2c5nka0yX
         i+0V01x0DP+crvpENcLK9kIMHGnYfIL/H0uLIKTVOdrW6ozN46KqNdxwRDdwumWF/jbR
         a36w==
X-Gm-Message-State: APjAAAVzV2kGcA6WY1mpQ2bxL187nvzozMYlGARDbE3+4B3X5kfxchox
	ZV2c7yEAeLMe/PV2QU8SpPJzD9POmgyraGPE1D49SaDX/WMWFvdI+i36BcC8lO0ykeYKLGtpJA/
	wYwZHkfzCwFxNpn4/v1vXhDsP05cCH+3X6AzMBtP0kbOQ0ozRtxt8cDHcko4/xaqIUA==
X-Received: by 2002:a24:7542:: with SMTP id y63mr992788itc.70.1553725800164;
        Wed, 27 Mar 2019 15:30:00 -0700 (PDT)
X-Received: by 2002:a24:7542:: with SMTP id y63mr992722itc.70.1553725798936;
        Wed, 27 Mar 2019 15:29:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553725798; cv=none;
        d=google.com; s=arc-20160816;
        b=bXWNRmofQ+d5KjzuHj6s1kz+5ud8oI347u1hl00lwqJmaErh55wGmaQPJpDHGpk6EP
         ++9N0jMA3/ci2uIaQuy7O+7V7cD6ZjPVRK3MbJDsWYBChyK2genOMBr9yMtobGQfLGpB
         kQ78cmk+yphguSMFdM2bJYhBflPXap18NepL7d69MZPwOjXAt8944YYA7OsSH4yoxyrT
         i1EnGI9cL1jCbcFQLckytUBZbTs0ZmP8jXumq666DhohV3cNAJ5k6JHVXRigcZhNi8Dh
         ZfSQkeTlvsj3MJFrMIyAaaDOTxE0uE1DCl6Z13DZVwuU94/LAGDuuyPCoqatIsvh61ZF
         3k1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vb2BrBH4oYQzGEnJbFomSh/8BX3FsNmxH+IKvRIF5+g=;
        b=rN/RiDGBsCVLJjtVV8ZywvN9+PXDCs9DNC/9RF9irItT6QEdUJonqca1+WbbhApZYL
         e//7hPDqJ6XR2jY5EsMSb04nCdtRwFl/HuO9QLcWuhE0CVsEGn6LMF4D30JK236wOv6O
         yOplkC3xmOlfLbXByN71cR2QfJXFvp+nLHkWGLH1bTPANbwIoygFYlHzy1d0pnsK40KY
         B6SlDqjbcopfFB6NmboHTrR492WUKOZ9P7yATXqvvPwnjUD4J5DNGHagzxefvlP7srrj
         OekKEZINqPGeoYgLuHPI6Vdnb62f1ifl08j0Pzg6fiLLOUmvLs4XwT3SnBrmJph0+3uR
         fBcw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aaHOcKbm;
       spf=pass (google.com: domain of gthelen@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gthelen@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 187sor2599287itm.24.2019.03.27.15.29.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Mar 2019 15:29:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of gthelen@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aaHOcKbm;
       spf=pass (google.com: domain of gthelen@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gthelen@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vb2BrBH4oYQzGEnJbFomSh/8BX3FsNmxH+IKvRIF5+g=;
        b=aaHOcKbm5Wc46HDgM0FNGAZSYg9x419T2E4bP/s3ZwTQLA9ox/5uOx2GUg/90BNxUW
         M2CKIwOqOdGMqbRA5XNTOz2kS8EGFKgjQDK1hg7Jd3PcPXTqc6U8nbIweLaYifp0OEeZ
         O9xVFdcDEc6GJDMcS7uAiBs+ciCYga8pyBIUdE0oRC15/Uzh9sOxl3aNDI65KAnA6Lhl
         29F7vhGLOooseb0bAFP1tLmTc8mJ4dDNv3yGDnhNApFuB1df+TWZ6Ni1Tum3JYVMtwuP
         fWN/9v6axFdkX3QeS9QwpCiTnlKk3dSD3dGU0YqoHnYGdkxDPP1zxiG0zBKmrT0oRbH3
         1/MA==
X-Google-Smtp-Source: APXvYqwbULKznaKem+4hXQUdPX78evLmKmtf4Atst3mQOe19/U0Y/XdBnE+P0iiiSkUWIKDzxNN/KlZIjlos60rc5eM=
X-Received: by 2002:a05:660c:9c3:: with SMTP id i3mr4960093itl.168.1553725798322;
 Wed, 27 Mar 2019 15:29:58 -0700 (PDT)
MIME-Version: 1.0
References: <20190307165632.35810-1-gthelen@google.com> <20190322181517.GA12378@tower.DHCP.thefacebook.com>
In-Reply-To: <20190322181517.GA12378@tower.DHCP.thefacebook.com>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 27 Mar 2019 15:29:47 -0700
Message-ID: <CAHH2K0ZqTXhdA+RSZU0a4kjeJexQ5Kh+rMaspzhMCwjKjJvHug@mail.gmail.com>
Subject: Re: [PATCH] writeback: sum memcg dirty counters as needed
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 11:15 AM Roman Gushchin <guro@fb.com> wrote:
>
> On Thu, Mar 07, 2019 at 08:56:32AM -0800, Greg Thelen wrote:
> > Since commit a983b5ebee57 ("mm: memcontrol: fix excessive complexity in
> > memory.stat reporting") memcg dirty and writeback counters are managed
> > as:
> > 1) per-memcg per-cpu values in range of [-32..32]
> > 2) per-memcg atomic counter
> > When a per-cpu counter cannot fit in [-32..32] it's flushed to the
> > atomic.  Stat readers only check the atomic.
> > Thus readers such as balance_dirty_pages() may see a nontrivial error
> > margin: 32 pages per cpu.
> > Assuming 100 cpus:
> >    4k x86 page_size:  13 MiB error per memcg
> >   64k ppc page_size: 200 MiB error per memcg
> > Considering that dirty+writeback are used together for some decisions
> > the errors double.
> >
> > This inaccuracy can lead to undeserved oom kills.  One nasty case is
> > when all per-cpu counters hold positive values offsetting an atomic
> > negative value (i.e. per_cpu[*]=32, atomic=n_cpu*-32).
> > balance_dirty_pages() only consults the atomic and does not consider
> > throttling the next n_cpu*32 dirty pages.  If the file_lru is in the
> > 13..200 MiB range then there's absolutely no dirty throttling, which
> > burdens vmscan with only dirty+writeback pages thus resorting to oom
> > kill.
> >
> > It could be argued that tiny containers are not supported, but it's more
> > subtle.  It's the amount the space available for file lru that matters.
> > If a container has memory.max-200MiB of non reclaimable memory, then it
> > will also suffer such oom kills on a 100 cpu machine.
> >
> > The following test reliably ooms without this patch.  This patch avoids
> > oom kills.
> >
> > ...
> >
> > Make balance_dirty_pages() and wb_over_bg_thresh() work harder to
> > collect exact per memcg counters when a memcg is close to the
> > throttling/writeback threshold.  This avoids the aforementioned oom
> > kills.
> >
> > This does not affect the overhead of memory.stat, which still reads the
> > single atomic counter.
> >
> > Why not use percpu_counter?  memcg already handles cpus going offline,
> > so no need for that overhead from percpu_counter.  And the
> > percpu_counter spinlocks are more heavyweight than is required.
> >
> > It probably also makes sense to include exact dirty and writeback
> > counters in memcg oom reports.  But that is saved for later.
> >
> > Signed-off-by: Greg Thelen <gthelen@google.com>
> > ---
> >  include/linux/memcontrol.h | 33 +++++++++++++++++++++++++--------
> >  mm/memcontrol.c            | 26 ++++++++++++++++++++------
> >  mm/page-writeback.c        | 27 +++++++++++++++++++++------
> >  3 files changed, 66 insertions(+), 20 deletions(-)
> >
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 83ae11cbd12c..6a133c90138c 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -573,6 +573,22 @@ static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
> >       return x;
> >  }
>
> Hi Greg!
>
> Thank you for the patch, definitely a good problem to be fixed!
>
> >
> > +/* idx can be of type enum memcg_stat_item or node_stat_item */
> > +static inline unsigned long
> > +memcg_exact_page_state(struct mem_cgroup *memcg, int idx)
> > +{
> > +     long x = atomic_long_read(&memcg->stat[idx]);
> > +#ifdef CONFIG_SMP
>
> I doubt that this #ifdef is correct without corresponding changes
> in __mod_memcg_state(). As now, we do use per-cpu buffer which spills
> to an atomic value event if !CONFIG_SMP. It's probably something
> that we want to change, but as now, #ifdef CONFIG_SMP should protect
> only "if (x < 0)" part.

Ack.  I'll fix it.

> > +     int cpu;
> > +
> > +     for_each_online_cpu(cpu)
> > +             x += per_cpu_ptr(memcg->stat_cpu, cpu)->count[idx];
> > +     if (x < 0)
> > +             x = 0;
> > +#endif
> > +     return x;
> > +}
>
> Also, isn't it worth it to generalize memcg_page_state() instead?
> By adding an bool exact argument? I believe dirty balance is not
> the only place, where we need a better accuracy.

Nod.  I'll provide a more general version of memcg_page_state().  I'm
testing updated (forthcoming v2) patch set now with feedback from
Andrew and Roman.

