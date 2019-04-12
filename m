Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18C85C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:15:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD29A2186A
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:15:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="YruH5Z8k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD29A2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 419E76B026A; Fri, 12 Apr 2019 10:15:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CA6F6B026B; Fri, 12 Apr 2019 10:15:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E2516B026C; Fri, 12 Apr 2019 10:15:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id D4F986B026A
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 10:15:51 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id f12so6759346wmj.0
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 07:15:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=isbfV1XuLmSpqEnWQt10kSQKeIpdWz/ULZrB6D6jy+I=;
        b=ifN41TEKDuIpiSC8wRiIfdGiQ2X4IhpUtJkdYAH6275eIpkIqlOuyBBoyShSR8jZ2f
         zTz70uMj5tAO/X0sECH2h+DdTI7Vc1feAPjoNRz1b57I663KYcrA9oWUEQmGAQVHCHrf
         LrK2WJpJPakVehsHtx4gge9rJo4g04I6e7LH0AR/7/FfOK+mFWQBmvOeVgSvyh6YwjR9
         ssCFuuhNQr2unUjQy3d8E43WsHU7hE7BziR64egkc4q5T9S2iVXLqX0E+st4mDGiWYMS
         ET7zUkpmSzmpNoXXIEQpw4ylJ1vaZysuCphHYmOrBHldi4x9AbeBR9iXk7MR3nsi3mmT
         ZMbg==
X-Gm-Message-State: APjAAAXeR2pELxMw+mFFR/9TSU8SjPd546G8PLAdhYwYaYOFvIXRSFCU
	+JPdPIP76AxHtNBTTIUH2dkB3NPoMRy+cpZUkEGHCILAHBkVKSaIgm2DOkxNIgVR4bMzYrsVODK
	TmNyeVtgl/EoCYN1Fdt2AQmrNCYFRkn4X6ZFQc/pxp/ILIx/zI5AXfBNfuNutFdAdLA==
X-Received: by 2002:a5d:6406:: with SMTP id z6mr13158406wru.266.1555078551424;
        Fri, 12 Apr 2019 07:15:51 -0700 (PDT)
X-Received: by 2002:a5d:6406:: with SMTP id z6mr13158342wru.266.1555078550483;
        Fri, 12 Apr 2019 07:15:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555078550; cv=none;
        d=google.com; s=arc-20160816;
        b=jZtN8iQiWbdgcQh3LCmZTOy0P3o/ZW58q0GP0KKrrtU6PIJ4Q9evfxZ+dyyh/8J0eq
         tvYJJ8aVJqhbP5NZy3qcU0Q2H+6ZEDiGu9yd7p2Memoy+774muuoHOd+7RvcrVlXaQgx
         Sc2zhlfAFHmKXHg9wuj79YKBWdazMr4aYyhHRuDiDdjyIJBOMxgSqnfnayTDNgl0yLT9
         uPTObOe+qPdFfg1IW3RF+2AxpFramL74TOD+MjaQ+5JYuXz/gQHMlHRu+GAODPY6ioMP
         LQEhqo0APY/J60zOGVnNk44kb95am9U1EU2iuhOf6rxAI+Wz63mt3Um/lC4dgCFcQN6y
         Fiag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=isbfV1XuLmSpqEnWQt10kSQKeIpdWz/ULZrB6D6jy+I=;
        b=Uoc7jFlwN/TyjLHVu/e2h0Uv40unXPGdhIpVAo7iYQyukCdsKGjBKdUxvU5Q8m5cTC
         lRe/HjFSK7spiGv9QmC/N74RSyn32t/tWvaphKkHcNDB/prbT8I+Lw3fGYPVpferNmM0
         /kNGueInf83pIced/tHIuAZXi31IjbwsaR6RDWZJVs8KbE5pRYaA/xGV0y1n6pkSClTP
         fuWP9xgikghiqT4hh9b3xC4ek93jRVJPktZkE3wINKVZlH5Q3BH7N4fmDpeapXG+QDrh
         Ea3WhIPVYW1k1RLKyuXLQtk1xOkYqGrS89ITjTZ7TmT+oafqj0bp9ptptcW5Q6SzEREl
         wLdw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YruH5Z8k;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o17sor31047207wrm.1.2019.04.12.07.15.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 07:15:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YruH5Z8k;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=isbfV1XuLmSpqEnWQt10kSQKeIpdWz/ULZrB6D6jy+I=;
        b=YruH5Z8k4xgBUu9CWgTjJxHl9UejxUlH4wKD2JYwoVT1K9bMqY2J0WZ4aH0XowCf//
         PLimMyeT9FQxLNkGP5+rF6qZrPR5v40N9+ob4Ni2vTf6QS1ojN17wnaqP1NF/ezgvNpL
         q4t5yrXc2C1MhGV5BLsB7qRIA0KVy6rXdRmdCkue2x8a1iHwKrzOf7t6NJZUj8bUemYd
         brERkcwx4YaBMgOPn1TycG4owa7UkE89eBHGApo1DDT3j34IjoqXmEjBefuTslWywqhW
         s0NUzc7Bnjdn355uD7LTANNF9cpjTDWW2k0Rk6IRkQV79g997xLIlBWM5Rl12JJjGLcF
         oM6A==
X-Google-Smtp-Source: APXvYqyTWIVUGogwRz9I6WBbV2kdbjd9f4qSSX9DwdSED9R2DW1oXEigJDSNwpZHBM55VZPccwUi49k0BSHfPsU/Kdc=
X-Received: by 2002:adf:cf0c:: with SMTP id o12mr16912460wrj.16.1555078549686;
 Fri, 12 Apr 2019 07:15:49 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org> <CAJuCfpGQ8c-OCws-zxZyqKGy1CfZpjxDKMH__qAm5FFXBcnWOw@mail.gmail.com>
 <CAKOZuetFU4tXE27bxA86zzDfNSCbw83p8fPxfkQ_d_Em0C04Sg@mail.gmail.com>
 <20190411173649.GF22763@bombadil.infradead.org> <CAKOZuet8-en+tMYu_QqVCxmkak44T7MnmRgfJBot0+P_A+Qzkw@mail.gmail.com>
 <20190412064925.GB13373@dhcp22.suse.cz>
In-Reply-To: <20190412064925.GB13373@dhcp22.suse.cz>
From: Suren Baghdasaryan <surenb@google.com>
Date: Fri, 12 Apr 2019 07:15:38 -0700
Message-ID: <CAJuCfpEHhcrGFxsCmPsZu=aPmYDB0yCeb2Fhs405eH3os-amuQ@mail.gmail.com>
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
To: Michal Hocko <mhocko@kernel.org>
Cc: Daniel Colascione <dancol@google.com>, Matthew Wilcox <willy@infradead.org>, 
	Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, 
	yuzhoujian@didichuxing.com, Souptick Joarder <jrdr.linux@gmail.com>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, Shakeel Butt <shakeelb@google.com>, 
	Christian Brauner <christian@brauner.io>, Minchan Kim <minchan@kernel.org>, 
	Tim Murray <timmurray@google.com>, Joel Fernandes <joel@joelfernandes.org>, 
	Jann Horn <jannh@google.com>, linux-mm <linux-mm@kvack.org>, lsf-pc@lists.linux-foundation.org, 
	LKML <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 11:49 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 11-04-19 10:47:50, Daniel Colascione wrote:
> > On Thu, Apr 11, 2019 at 10:36 AM Matthew Wilcox <willy@infradead.org> wrote:
> > >
> > > On Thu, Apr 11, 2019 at 10:33:32AM -0700, Daniel Colascione wrote:
> > > > On Thu, Apr 11, 2019 at 10:09 AM Suren Baghdasaryan <surenb@google.com> wrote:
> > > > > On Thu, Apr 11, 2019 at 8:33 AM Matthew Wilcox <willy@infradead.org> wrote:
> > > > > >
> > > > > > On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > > > > > > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > > > > > > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > > > > > > victim process. The usage of this flag is currently limited to SIGKILL
> > > > > > > signal and only to privileged users.
> > > > > >
> > > > > > What is the downside of doing expedited memory reclaim?  ie why not do it
> > > > > > every time a process is going to die?
> > > > >
> > > > > I think with an implementation that does not use/abuse oom-reaper
> > > > > thread this could be done for any kill. As I mentioned oom-reaper is a
> > > > > limited resource which has access to memory reserves and should not be
> > > > > abused in the way I do in this reference implementation.
> > > > > While there might be downsides that I don't know of, I'm not sure it's
> > > > > required to hurry every kill's memory reclaim. I think there are cases
> > > > > when resource deallocation is critical, for example when we kill to
> > > > > relieve resource shortage and there are kills when reclaim speed is
> > > > > not essential. It would be great if we can identify urgent cases
> > > > > without userspace hints, so I'm open to suggestions that do not
> > > > > involve additional flags.
> > > >
> > > > I was imagining a PI-ish approach where we'd reap in case an RT
> > > > process was waiting on the death of some other process. I'd still
> > > > prefer the API I proposed in the other message because it gets the
> > > > kernel out of the business of deciding what the right signal is. I'm a
> > > > huge believer in "mechanism, not policy".
> > >
> > > It's not a question of the kernel deciding what the right signal is.
> > > The kernel knows whether a signal is fatal to a particular process or not.
> > > The question is whether the killing process should do the work of reaping
> > > the dying process's resources sometimes, always or never.  Currently,
> > > that is never (the process reaps its own resources); Suren is suggesting
> > > sometimes, and I'm asking "Why not always?"
> >
> > FWIW, Suren's initial proposal is that the oom_reaper kthread do the
> > reaping, not the process sending the kill. Are you suggesting that
> > sending SIGKILL should spend a while in signal delivery reaping pages
> > before returning? I thought about just doing it this way, but I didn't
> > like the idea: it'd slow down mass-killing programs like killall(1).
> > Programs expect sending SIGKILL to be a fast operation that returns
> > immediately.
>
> I was thinking about this as well. And SYNC_SIGKILL would workaround the
> current expectations of how quick the current implementation is. The
> harder part would what is the actual semantic. Does the kill wait until
> the target task is TASK_DEAD or is there an intermediate step that would
> we could call it end of the day and still have a reasonable semantic
> (e.g. the original pid is really not alive anymore).

I think Daniel's proposal was trying to address that. With an input of
how many pages user wants to reclaim asynchronously and return value
of how much was actually reclaimed it contains the condition when to
stop and the reply how successful we could accomplish that. Since it
returns the number of pages reclaimed I assume the call does not
return until it reaped enough pages.

> --
> Michal Hocko
> SUSE Labs

