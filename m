Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 978DEC072A4
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 05:12:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E0672070D
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 05:12:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="NOi/c1/B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E0672070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6BD76B0003; Wed, 22 May 2019 01:12:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1C9D6B0006; Wed, 22 May 2019 01:12:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B09ED6B0007; Wed, 22 May 2019 01:12:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 883326B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 01:12:07 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id k71so444211vka.18
        for <linux-mm@kvack.org>; Tue, 21 May 2019 22:12:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=9cSHLpfk2ut/G7daeeu1vHKOr/f5bhaXmSC+S8dDp1M=;
        b=lrkidpHfO9ZJuR0hkZv8PKyzovJPMst9MCftJXoopbfYBgbHZS8m0q3IJCyGaYs7Y5
         gvD0SR+vOA6QL2Z239pO2PZc8zZLjm/S2xqHus6wdqKJw+1sjkEfL+tQNyY+kNuQCrdN
         h4HycMpKNyMF9sWF8aJuUDjuD0K5QWuC8SS+svP09Otgq3iyEO5m+3VV213DQQm4mqI/
         kVpHZQL7rF021F+hVxCIoHoZLBYMLzNNPuexn0oWWhChMIwcVIW3Hm8MF+Gk8bmnAW8o
         iacAaT264u9QSryAK2iTZ7BpyRuLpj+sWQ8580kHpjtu5A19OX+NkfR1aPChck1PDOlN
         XvRg==
X-Gm-Message-State: APjAAAUmRx5tR+jHr8eiZ0aYAia5OmwMLW63M7xH3ZkGUdAeNBCFnAWD
	Fuv4mbiXs+faxFAJKM2eqdsgQNezV6hSrpI2cYcWWCo6k5V8ShmpAD1PJtVfZWH13yS0uVJbass
	W817ObyIweyN7pCp2XqgRFQgxHs4O0OH7BF56J4v5Uzm8egJKcXxXUxzIxhC9TOLwsw==
X-Received: by 2002:a1f:1e48:: with SMTP id e69mr14097129vke.16.1558501927151;
        Tue, 21 May 2019 22:12:07 -0700 (PDT)
X-Received: by 2002:a1f:1e48:: with SMTP id e69mr14097107vke.16.1558501926165;
        Tue, 21 May 2019 22:12:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558501926; cv=none;
        d=google.com; s=arc-20160816;
        b=j/kKLh2y38eLwbqq3/+6RDEUUJaCgB28hAUw8e8yipYZ30cygc30lo6ZHCvWXSlqlE
         atmnkZ3yOi7ifx6Z1+GXNMGZWqgDu0yGFXSZwOg9fnrWEYi8YvvrUZq0P5geqshE+Gq5
         j5rSEngPs71hqkIRaSJDV+0EEGCUQrQxeRY3Qpy2Z6ir9o8yGBSZ4kndfZlV1bGm2InG
         N5sZEeLwd2oyYRq6MIUz0hltIsN6vLCE/4Ws+5B4OX0omzhI9+jMNcKw44zZ2oj54eT/
         8Lr98PRjJzu1Mb0woFnenDRh3Mf87tK7KnAp7GbzPC6rI6yFMFhXdpJ6D9Bdy37qIGmO
         +20w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=9cSHLpfk2ut/G7daeeu1vHKOr/f5bhaXmSC+S8dDp1M=;
        b=T5jx7zT44X1OUT1lGocA2KyVMT81q1EKDxFXF4e0XRu9NtW8CNSgn2KjUGt7bA46jf
         p48VIJ4jve+ajXHircnxjnW451vQR38M/Kn6H3NcFb44HKfZtOFTBGen6n8QdKBIh3vh
         9nvQd8RYGtmH3L47w1A3opG7sVyT2tqSw0Pj3bnf3UKeX6Okxg1VLKSkgoMgZCXB+7hz
         Teb/iQGkgGcvCTWt3L52hxxVoXlqeWjUHO/gCXQOtXUZcUmGT+4pw6391GXgyXi2/j/m
         6ay8queyG8hIabbDT/mjwC/3IIMUlNvIDpsNLxJHcYx02apYWS7+V36hPzNoxTeUsgqd
         LV6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="NOi/c1/B";
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v4sor3084812uam.13.2019.05.21.22.12.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 22:12:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="NOi/c1/B";
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=9cSHLpfk2ut/G7daeeu1vHKOr/f5bhaXmSC+S8dDp1M=;
        b=NOi/c1/BZL0A1MVfXBT4OMbxgq+TQemvctfYgkP3g9iiscfCUdMH6vSQ7H52vQJzHO
         DRZUIY1ZmZ0g2qEGRNSSekNSlq7LKKncp4KHqYeLAKreov879Fuw28YUYpf7hiSmjDm3
         fbVeq9wzHEIwB1Mk8tx5gNrXjWsiCKGqCeffC2cqOozfiRTfOlp2TkeOKm0j3M4VPaJY
         m9IVvtmC6e1oxxn/Y6cO5Cm2EfWQAFdVXJdsIBzJeiKEwI4qXQkshYjX5a5eHJaYIbON
         2DDqK/SLsWzJDrG/puzEK7ZI3rKEkMzCPvwyHD0XnouepO/vuKEigV4541uUAlTp1g6B
         1OEg==
X-Google-Smtp-Source: APXvYqy8+dYZRe6z0Nwha0PQyg+QYkW6/ymoocZj4J2VwOSqdTfwW7boSafeq0W2BM0JYFNKSl7I/6pdfZ4d/zaIRd8=
X-Received: by 2002:ab0:1529:: with SMTP id o38mr21734487uae.30.1558501925277;
 Tue, 21 May 2019 22:12:05 -0700 (PDT)
MIME-Version: 1.0
References: <20190520035254.57579-1-minchan@kernel.org> <20190521084158.s5wwjgewexjzrsm6@brauner.io>
 <20190521110552.GG219653@google.com> <20190521113029.76iopljdicymghvq@brauner.io>
 <20190521113911.2rypoh7uniuri2bj@brauner.io>
In-Reply-To: <20190521113911.2rypoh7uniuri2bj@brauner.io>
From: Daniel Colascione <dancol@google.com>
Date: Tue, 21 May 2019 22:11:53 -0700
Message-ID: <CAKOZuesjDcD3EM4PS7aO7yTa3KZ=FEzMP63MR0aEph4iW1NCYQ@mail.gmail.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
To: Christian Brauner <christian@brauner.io>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>, 
	Brian Geffon <bgeffon@google.com>, Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 4:39 AM Christian Brauner <christian@brauner.io> wr=
ote:
>
> On Tue, May 21, 2019 at 01:30:29PM +0200, Christian Brauner wrote:
> > On Tue, May 21, 2019 at 08:05:52PM +0900, Minchan Kim wrote:
> > > On Tue, May 21, 2019 at 10:42:00AM +0200, Christian Brauner wrote:
> > > > On Mon, May 20, 2019 at 12:52:47PM +0900, Minchan Kim wrote:
> > > > > - Background
> > > > >
> > > > > The Android terminology used for forking a new process and starti=
ng an app
> > > > > from scratch is a cold start, while resuming an existing app is a=
 hot start.
> > > > > While we continually try to improve the performance of cold start=
s, hot
> > > > > starts will always be significantly less power hungry as well as =
faster so
> > > > > we are trying to make hot start more likely than cold start.
> > > > >
> > > > > To increase hot start, Android userspace manages the order that a=
pps should
> > > > > be killed in a process called ActivityManagerService. ActivityMan=
agerService
> > > > > tracks every Android app or service that the user could be intera=
cting with
> > > > > at any time and translates that into a ranked list for lmkd(low m=
emory
> > > > > killer daemon). They are likely to be killed by lmkd if the syste=
m has to
> > > > > reclaim memory. In that sense they are similar to entries in any =
other cache.
> > > > > Those apps are kept alive for opportunistic performance improveme=
nts but
> > > > > those performance improvements will vary based on the memory requ=
irements of
> > > > > individual workloads.
> > > > >
> > > > > - Problem
> > > > >
> > > > > Naturally, cached apps were dominant consumers of memory on the s=
ystem.
> > > > > However, they were not significant consumers of swap even though =
they are
> > > > > good candidate for swap. Under investigation, swapping out only b=
egins
> > > > > once the low zone watermark is hit and kswapd wakes up, but the o=
verall
> > > > > allocation rate in the system might trip lmkd thresholds and caus=
e a cached
> > > > > process to be killed(we measured performance swapping out vs. zap=
ping the
> > > > > memory by killing a process. Unsurprisingly, zapping is 10x times=
 faster
> > > > > even though we use zram which is much faster than real storage) s=
o kill
> > > > > from lmkd will often satisfy the high zone watermark, resulting i=
n very
> > > > > few pages actually being moved to swap.
> > > > >
> > > > > - Approach
> > > > >
> > > > > The approach we chose was to use a new interface to allow userspa=
ce to
> > > > > proactively reclaim entire processes by leveraging platform infor=
mation.
> > > > > This allowed us to bypass the inaccuracy of the kernel=E2=80=99s =
LRUs for pages
> > > > > that are known to be cold from userspace and to avoid races with =
lmkd
> > > > > by reclaiming apps as soon as they entered the cached state. Addi=
tionally,
> > > > > it could provide many chances for platform to use much informatio=
n to
> > > > > optimize memory efficiency.
> > > > >
> > > > > IMHO we should spell it out that this patchset complements MADV_W=
ONTNEED
> > > > > and MADV_FREE by adding non-destructive ways to gain some free me=
mory
> > > > > space. MADV_COLD is similar to MADV_WONTNEED in a way that it hin=
ts the
> > > > > kernel that memory region is not currently needed and should be r=
eclaimed
> > > > > immediately; MADV_COOL is similar to MADV_FREE in a way that it h=
ints the
> > > > > kernel that memory region is not currently needed and should be r=
eclaimed
> > > > > when memory pressure rises.
> > > > >
> > > > > To achieve the goal, the patchset introduce two new options for m=
advise.
> > > > > One is MADV_COOL which will deactive activated pages and the othe=
r is
> > > > > MADV_COLD which will reclaim private pages instantly. These new o=
ptions
> > > > > complement MADV_DONTNEED and MADV_FREE by adding non-destructive =
ways to
> > > > > gain some free memory space. MADV_COLD is similar to MADV_DONTNEE=
D in a way
> > > > > that it hints the kernel that memory region is not currently need=
ed and
> > > > > should be reclaimed immediately; MADV_COOL is similar to MADV_FRE=
E in a way
> > > > > that it hints the kernel that memory region is not currently need=
ed and
> > > > > should be reclaimed when memory pressure rises.
> > > > >
> > > > > This approach is similar in spirit to madvise(MADV_WONTNEED), but=
 the
> > > > > information required to make the reclaim decision is not known to=
 the app.
> > > > > Instead, it is known to a centralized userspace daemon, and that =
daemon
> > > > > must be able to initiate reclaim on its own without any app invol=
vement.
> > > > > To solve the concern, this patch introduces new syscall -
> > > > >
> > > > >         struct pr_madvise_param {
> > > > >                 int size;
> > > > >                 const struct iovec *vec;
> > > > >         }
> > > > >
> > > > >         int process_madvise(int pidfd, ssize_t nr_elem, int *beha=
vior,
> > > > >                                 struct pr_madvise_param *restuls,
> > > > >                                 struct pr_madvise_param *ranges,
> > > > >                                 unsigned long flags);
> > > > >
> > > > > The syscall get pidfd to give hints to external process and provi=
des
> > > > > pair of result/ranges vector arguments so that it could give seve=
ral
> > > > > hints to each address range all at once.
> > > > >
> > > > > I guess others have different ideas about the naming of syscall a=
nd options
> > > > > so feel free to suggest better naming.
> > > >
> > > > Yes, all new syscalls making use of pidfds should be named
> > > > pidfd_<action>. So please make this pidfd_madvise.
> > >
> > > I don't have any particular preference but just wondering why pidfd i=
s
> > > so special to have it as prefix of system call name.
> >
> > It's a whole new API to address processes. We already have
> > clone(CLONE_PIDFD) and pidfd_send_signal() as you have seen since you
> > exported pidfd_to_pid(). And we're going to have pidfd_open(). Your
> > syscall works only with pidfds so it's tied to this api as well so it
> > should follow the naming scheme. This also makes life easier for
> > userspace and is consistent.
>
> This is at least my reasoning. I'm not going to make this a whole big
> pedantic argument. If people have really strong feelings about not using
> this prefix then fine. But if syscalls can be grouped together and have
> consistent naming this is always a big plus.

My hope has been that pidfd use becomes normalized enough that
prefixing "pidfd_" to pidfd-accepting system calls becomes redundant.
We write write(), not fd_write(), right? :-) pidfd_open() makes sense
because the primary purpose of this system call is to operate on a
pidfd, but I think process_madvise() is fine.

