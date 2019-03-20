Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AD8EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:04:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A5AC2085A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:04:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="CIijQ38p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A5AC2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1F366B0003; Tue, 19 Mar 2019 20:04:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D02F6B0006; Tue, 19 Mar 2019 20:04:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E6876B0007; Tue, 19 Mar 2019 20:04:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6DD1E6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:04:09 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id k2so433819ioj.2
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:04:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=oDZe1t9c0QaacZlrpbAimzEMcql8/pq6sGNUEMnWMjQ=;
        b=JmvyXEApW+xAqL27fVrJ6VkdXr8FRdsgfsLEpYXcNpOryvfxe1MG+XvDuL/3TrgXC3
         6jijVhrVsmdQ4VY+iuXNn2h7MGNby1/UKfw7zByFwjrudL5DAgZ+FHvTayBFpOegqd4z
         YU+kvLej7mefbuR2HLeiKPoS9tVvx5fMcOft9e+U/DmVqUojyzOe1msBOY4dFd8WESk9
         ZDA1Q9vOxfziak5FCC2aUsmjByaF/w0YkIuTcbTyglXVMh4Xc+heM06KQH248xcvuxlY
         huTrr3Fga63zNRz+ybAUTPVnK4xFeLA68fOqacsPgL/9L+pvLDiQJVz7Se4Bnrwgz1yY
         L/OA==
X-Gm-Message-State: APjAAAX5WlqdmATZw/FgrEgC27giWXheJqx8GmCdq+ewL6rTiHfQAoFj
	2mzsgCFw765I1WHUXyieEMItVQgpYPCWeptZY0GnCSYz+WXIVb0sKMEa+JKDM90hKbnniiFmeb3
	6WaF+YgM1md/qzKZ3GZJK+lZgI+vhhiIU9jvkwW0D5WwhPMdolfGYvLZ0Rp+/GBuHXg==
X-Received: by 2002:a24:730f:: with SMTP id y15mr3192943itb.126.1553040249156;
        Tue, 19 Mar 2019 17:04:09 -0700 (PDT)
X-Received: by 2002:a24:730f:: with SMTP id y15mr3192893itb.126.1553040248162;
        Tue, 19 Mar 2019 17:04:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553040248; cv=none;
        d=google.com; s=arc-20160816;
        b=lvJ8EiTtDS7BKNAulzndzDgPGxaMBzBLzEqty3ZDee5HPhUjrg33Yg3SiNQ+GGfRH0
         C0rZcVFq/OK4F7LsBUh5YTbAc0pzNgGXO8hZyJdpNfAf3Ca8FTRAvYiCONpr47xONx24
         Ah8ihkPWAeiUKseEK0VABohCI1DjsR0xcER7eRCyzB6QNVB511zdaoAd+Ol/q9uiQ+Ok
         Z3Px54Q/tDy4SthI9fJTVl0GCoc28Kmo0/FddTo87xmoNpGvKiBR/1JTN9h5s3ilSKhr
         l+ZC4/VYlfFgDS5CZ0q+A2CQWTc5GZ9nMldYYBWQt1fQyFeK+BMGCF0zfx5VTIeS8GOo
         LI0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=oDZe1t9c0QaacZlrpbAimzEMcql8/pq6sGNUEMnWMjQ=;
        b=jY3Y/zvsj2AWLd/xJXx3+wEqMHS8EJunMTQtW+v12v9p1Vmxw6bhBMfxl2Jko5rYHX
         EKtTPaQNAFnA99cD3UmBj/2/UOUls/pl8SEO99vT0QFxF1jX2juz+Vl3awKfWNiAazZ6
         ZEG7XbJPAE/+HGjNbGKZVDMa5B6gS/tDiEvH5AfWkHWsrHISSr7CJCkpq9iTXOllOvUq
         M4PqkIGvIBHSwlH8+DlPQ7Ea2sm22UZUVa+ueeVsPEIDj4Gm828G/q2e+x8ERGLAvxsT
         +t9gFXLe6CXB8f4c1nlhIflxxpuHWTSgFMyeQj69CS/NPIqoB+6uiDiT8KDlHiTr2VMp
         XySA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CIijQ38p;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m11sor612829itm.18.2019.03.19.17.04.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 17:04:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CIijQ38p;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=oDZe1t9c0QaacZlrpbAimzEMcql8/pq6sGNUEMnWMjQ=;
        b=CIijQ38pRIRhFAFpNvokHLFR8PSIfXecgjJ8AlRyeY+Kabg6iidqrQRGKu7kYJdzbX
         mAkSf1brUe3fju70jwdjv2B5i+6outQalj3T855ocjYvqJLBxmcu1uZcqTp9cKFhW8f2
         EhGAFalDX31pg/U9SnNKhqYxiV67xGEOEvVa54hbBumop8G9Yl0k3LmFnyWNjCpl5sV7
         2z14fgCmJYLWfhJKF1y4332WYJe2byxf0rdhmR+cku/BIn9yvhHxT/Qw1dbeapxTFU5X
         ev5/OpaIM5PzkBREB0CFnOQ4jnasyGCWnpVlOsvsFU7Sjm4KmjyiSZnNAsqpYcAescQ3
         RKYQ==
X-Google-Smtp-Source: APXvYqxptOFQVH7/oWAuY9VRvDBG6zdc3/EvfChWluvgRHW5zfYg6whmYLvpG+xVy1gNfS7sSGGUsJnECdn89Yg5udY=
X-Received: by 2002:a24:a81:: with SMTP id 123mr3183294itw.43.1553040247723;
 Tue, 19 Mar 2019 17:04:07 -0700 (PDT)
MIME-Version: 1.0
References: <20190308184311.144521-1-surenb@google.com> <20190319225144.GA80186@google.com>
In-Reply-To: <20190319225144.GA80186@google.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 19 Mar 2019 17:03:56 -0700
Message-ID: <CAJuCfpE7hZVEmNFAa4PGjQhufbM3WHS1TSGr_xutGzGETygG9w@mail.gmail.com>
Subject: Re: [PATCH v5 0/7] psi: pressure stall monitors v5
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, 
	Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, dennis@kernel.org, 
	Dennis Zhou <dennisszhou@gmail.com>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org, linux-mm <linux-mm@kvack.org>, 
	linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, 
	kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 3:51 PM Minchan Kim <minchan@kernel.org> wrote:
>
> On Fri, Mar 08, 2019 at 10:43:04AM -0800, Suren Baghdasaryan wrote:
> > This is respin of:
> >   https://lwn.net/ml/linux-kernel/20190206023446.177362-1-surenb%40google.com/
> >
> > Android is adopting psi to detect and remedy memory pressure that
> > results in stuttering and decreased responsiveness on mobile devices.
> >
> > Psi gives us the stall information, but because we're dealing with
> > latencies in the millisecond range, periodically reading the pressure
> > files to detect stalls in a timely fashion is not feasible. Psi also
> > doesn't aggregate its averages at a high-enough frequency right now.
> >
> > This patch series extends the psi interface such that users can
> > configure sensitive latency thresholds and use poll() and friends to
> > be notified when these are breached.
> >
> > As high-frequency aggregation is costly, it implements an aggregation
> > method that is optimized for fast, short-interval averaging, and makes
> > the aggregation frequency adaptive, such that high-frequency updates
> > only happen while monitored stall events are actively occurring.
> >
> > With these patches applied, Android can monitor for, and ward off,
> > mounting memory shortages before they cause problems for the user.
> > For example, using memory stall monitors in userspace low memory
> > killer daemon (lmkd) we can detect mounting pressure and kill less
> > important processes before device becomes visibly sluggish. In our
> > memory stress testing psi memory monitors produce roughly 10x less
> > false positives compared to vmpressure signals. Having ability to
> > specify multiple triggers for the same psi metric allows other parts
> > of Android framework to monitor memory state of the device and act
> > accordingly.
> >
> > The new interface is straight-forward. The user opens one of the
> > pressure files for writing and writes a trigger description into the
> > file descriptor that defines the stall state - some or full, and the
> > maximum stall time over a given window of time. E.g.:
> >
> >         /* Signal when stall time exceeds 100ms of a 1s window */
> >         char trigger[] = "full 100000 1000000"
> >         fd = open("/proc/pressure/memory")
> >         write(fd, trigger, sizeof(trigger))
> >         while (poll() >= 0) {
> >                 ...
> >         };
> >         close(fd);
> >
> > When the monitored stall state is entered, psi adapts its aggregation
> > frequency according to what the configured time window requires in
> > order to emit event signals in a timely fashion. Once the stalling
> > subsides, aggregation reverts back to normal.
> >
> > The trigger is associated with the open file descriptor. To stop
> > monitoring, the user only needs to close the file descriptor and the
> > trigger is discarded.
> >
> > Patches 1-6 prepare the psi code for polling support. Patch 7 implements
> > the adaptive polling logic, the pressure growth detection optimized for
> > short intervals, and hooks up write() and poll() on the pressure files.
> >
> > The patches were developed in collaboration with Johannes Weiner.
> >
> > The patches are based on 5.0-rc8 (Merge tag 'drm-next-2019-03-06').
> >
> > Suren Baghdasaryan (7):
> >   psi: introduce state_mask to represent stalled psi states
> >   psi: make psi_enable static
> >   psi: rename psi fields in preparation for psi trigger addition
> >   psi: split update_stats into parts
> >   psi: track changed states
> >   refactor header includes to allow kthread.h inclusion in psi_types.h
> >   psi: introduce psi monitor
> >
> >  Documentation/accounting/psi.txt | 107 ++++++
> >  include/linux/kthread.h          |   3 +-
> >  include/linux/psi.h              |   8 +
> >  include/linux/psi_types.h        | 105 +++++-
> >  include/linux/sched.h            |   1 -
> >  kernel/cgroup/cgroup.c           |  71 +++-
> >  kernel/kthread.c                 |   1 +
> >  kernel/sched/psi.c               | 613 ++++++++++++++++++++++++++++---
> >  8 files changed, 833 insertions(+), 76 deletions(-)
> >
> > Changes in v5:
> > - Fixed sparse: error: incompatible types in comparison expression, as per
> >  Andrew
> > - Changed psi_enable to static, as per Andrew
> > - Refactored headers to be able to include kthread.h into psi_types.h
> > without creating a circular inclusion, as per Johannes
> > - Split psi monitor from aggregator, used RT worker for psi monitoring to
> > prevent it being starved by other RT threads and memory pressure events
> > being delayed or lost, as per Minchan and Android Performance Team
> > - Fixed blockable memory allocation under rcu_read_lock inside
> > psi_trigger_poll by using refcounting, as per Eva Huang and Minchan
> > - Misc cleanup and improvements, as per Johannes
> >
> > Notes:
> > 0001-psi-introduce-state_mask-to-represent-stalled-psi-st.patch is unchanged
> > from the previous version and provided for completeness.
>
> Please fix kbuild test bot's warning in 6/7
> Other than that, for all patches,

Thanks for the review!
Pushed v6 with the fix for the warning: https://lkml.org/lkml/2019/3/19/987
Also fixed a bug introduced in https://lkml.org/lkml/2019/3/8/686
which I discovered while testing (description in the changelog of the
new patchset).

>
> Acked-by: Minchan Kim <minchan@kernel.org>

