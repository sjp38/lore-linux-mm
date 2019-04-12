Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 925F7C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:20:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3323220818
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:20:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="d6VGPVSD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3323220818
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA3C76B026B; Fri, 12 Apr 2019 10:20:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C53706B026C; Fri, 12 Apr 2019 10:20:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF30A6B026D; Fri, 12 Apr 2019 10:20:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8949F6B026B
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 10:20:35 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id r14so4003877vkd.18
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 07:20:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Hu0E9YTHRBKUOOI+2XbC7EkogUynbjLRnmfDiE1W9AI=;
        b=B2jR7HzzBVKU5vDnBS56lg23qs6nqrHkVwCoAk3q0ILiyQSQ8lLym70hHzSE6+ORrH
         2biVUP9SO4d5r4kFgnQpb7Q6q/IN4gP/YWwbFvZG/bZp0O310kGeHRQtqWWa5w4oFNSk
         irCjmtlnPBxnDG3OD8o0SyzEFyQ0pZ/N2ebER94noNFfJnrtWdyVEF76Ckbu+90Tu57y
         eT36c1GJKHTH6gwlAy0uU6uKFIxcc8HX+C+s4YAAI4FyhYLsq2j4IsGqRj5ZCiQgCwUv
         AshGB05VU1Q/T3rmT+XdHCqmpPmjSEFVeJqK2lmJ1gY0UyuORb7wWO253vHgg/0DZomf
         hFSw==
X-Gm-Message-State: APjAAAWWtUC2TXXVqi3pEcLn6/CDLQkZ3k7sBpFbm1WJDxQMYtT8doA/
	AgELD4qKriqB7oCZiK+PqQUsFlGZ3Iix2vLjgJf8EzSbtDRyxpDdcZKrmG5x9smDME1d8CLLmq9
	FwUn0V5gGGYwYCeYkO/qHQSV2w4j22+DW5lpjafzIoXQSEqUoc72PvGLW2OWwcvOD4w==
X-Received: by 2002:a67:844d:: with SMTP id g74mr32203670vsd.40.1555078835241;
        Fri, 12 Apr 2019 07:20:35 -0700 (PDT)
X-Received: by 2002:a67:844d:: with SMTP id g74mr32203612vsd.40.1555078834453;
        Fri, 12 Apr 2019 07:20:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555078834; cv=none;
        d=google.com; s=arc-20160816;
        b=Q5+s6U1a1Goa167F2vtwi2YtOwxXmGf3GOXj7UwlzslTobaogMVwBskSFAWhvmUHGl
         IhmDjgzDdtjNk6yFXcw1upraaTdhi07rIUx4R1hPwHcjzNFKuOePek1i9Q1/ofjRNZmt
         +O45+F+jMeK/6akE4Eb93tSPWPQq4bZYXA/4W8tLoJrXxQi1KAvqhBCYfJcGwVbVxcO1
         NgowlESzFE4UJcrz5ywX4Li/610P15i+8SLK+LxmsEHaFlRyrf+2g+o+M+4UCSAaxDlF
         9eS0cAu9mLVo0iGujHhOJa7aoNKrDOxRQXLZFBBtWoCaPG+i8RB9ugZ7GY9hWNn7rO92
         DlOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Hu0E9YTHRBKUOOI+2XbC7EkogUynbjLRnmfDiE1W9AI=;
        b=U7E8H09JBQ9Zq0E9cQzjlIXSO2KfZ18HupuZR+IVYY8aEUKK4Ar76sfqGqv1LZTWsA
         h++K0mklMRPzq4F2yYO2tJZLqYos3mUfIkHIJ2qkfGIl6onuV5vxS4tQV269K/LC3R8P
         IFouQeuxuwdW/hTTddezuQDJbsdjTd+JR6Ck9DQtkVUS0rksrKyFccTMR/Y3LYtW1VMS
         4WCpYQR8Cy7V5Z/4TYmw8okUiSKdz5WrDx/AKeMAjgCydFlcZXuOI+sTu70eMHlkuUrJ
         N+J3PtSe1qXed1Q55yLnLFV2pORRwJMfCiH9qc3e6DujY4u9yrXi95BqLU8M5aS0Vaic
         qaUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=d6VGPVSD;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r144sor18163844vke.3.2019.04.12.07.20.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 07:20:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=d6VGPVSD;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Hu0E9YTHRBKUOOI+2XbC7EkogUynbjLRnmfDiE1W9AI=;
        b=d6VGPVSDoYdeFeQh4b4EVL+visgZAsaKSJHQItQbuS36z4pY5JJiNCRw6zEW0NLzIp
         FlTGMYc13cootXo/0LS3ej4OnxDSTLfdEVcCX6k72HUOBruustw/yTNzyBuc4obvEbGG
         oBh38BVUFtC9FQeXcyFE0ZVe3TEfbAk1pBWb5JAEskeIhfnmlWmdU+X+D9M6wJu4i8iI
         slVu3Dg+Myc+S6KuxmDOofw0n0agj1Zo1HlODGQttpePEg4kyK4bY3IJnjklUmat35CT
         PxqlgNpzQ5SlyuRg13HOs8iYMHJnRoQXCoX5OYdMXhnH/RscD0347S3QJ4Q5Dq+HRNDO
         uAzg==
X-Google-Smtp-Source: APXvYqwiGRKZMC3mDd0UulpVF9L9mqlsgBKCyB0rCbbLdmBNwZp0rAFCeKd9wI5EaIW62F8pSahpGa9oggVN+0N3br0=
X-Received: by 2002:a1f:32c7:: with SMTP id y190mr32538150vky.15.1555078833745;
 Fri, 12 Apr 2019 07:20:33 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org> <CAJuCfpGQ8c-OCws-zxZyqKGy1CfZpjxDKMH__qAm5FFXBcnWOw@mail.gmail.com>
 <CAKOZuetFU4tXE27bxA86zzDfNSCbw83p8fPxfkQ_d_Em0C04Sg@mail.gmail.com>
 <20190411173649.GF22763@bombadil.infradead.org> <CAKOZuet8-en+tMYu_QqVCxmkak44T7MnmRgfJBot0+P_A+Qzkw@mail.gmail.com>
 <20190412064925.GB13373@dhcp22.suse.cz> <CAJuCfpEHhcrGFxsCmPsZu=aPmYDB0yCeb2Fhs405eH3os-amuQ@mail.gmail.com>
In-Reply-To: <CAJuCfpEHhcrGFxsCmPsZu=aPmYDB0yCeb2Fhs405eH3os-amuQ@mail.gmail.com>
From: Daniel Colascione <dancol@google.com>
Date: Fri, 12 Apr 2019 07:20:21 -0700
Message-ID: <CAKOZuessAYS9Vq8GKf2ykx7T-JhRBmUOtFfs_08OAE3FvP0BWQ@mail.gmail.com>
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
To: Suren Baghdasaryan <surenb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, 
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

On Fri, Apr 12, 2019 at 7:15 AM Suren Baghdasaryan <surenb@google.com> wrote:
>
> On Thu, Apr 11, 2019 at 11:49 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 11-04-19 10:47:50, Daniel Colascione wrote:
> > > On Thu, Apr 11, 2019 at 10:36 AM Matthew Wilcox <willy@infradead.org> wrote:
> > > >
> > > > On Thu, Apr 11, 2019 at 10:33:32AM -0700, Daniel Colascione wrote:
> > > > > On Thu, Apr 11, 2019 at 10:09 AM Suren Baghdasaryan <surenb@google.com> wrote:
> > > > > > On Thu, Apr 11, 2019 at 8:33 AM Matthew Wilcox <willy@infradead.org> wrote:
> > > > > > >
> > > > > > > On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > > > > > > > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > > > > > > > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > > > > > > > victim process. The usage of this flag is currently limited to SIGKILL
> > > > > > > > signal and only to privileged users.
> > > > > > >
> > > > > > > What is the downside of doing expedited memory reclaim?  ie why not do it
> > > > > > > every time a process is going to die?
> > > > > >
> > > > > > I think with an implementation that does not use/abuse oom-reaper
> > > > > > thread this could be done for any kill. As I mentioned oom-reaper is a
> > > > > > limited resource which has access to memory reserves and should not be
> > > > > > abused in the way I do in this reference implementation.
> > > > > > While there might be downsides that I don't know of, I'm not sure it's
> > > > > > required to hurry every kill's memory reclaim. I think there are cases
> > > > > > when resource deallocation is critical, for example when we kill to
> > > > > > relieve resource shortage and there are kills when reclaim speed is
> > > > > > not essential. It would be great if we can identify urgent cases
> > > > > > without userspace hints, so I'm open to suggestions that do not
> > > > > > involve additional flags.
> > > > >
> > > > > I was imagining a PI-ish approach where we'd reap in case an RT
> > > > > process was waiting on the death of some other process. I'd still
> > > > > prefer the API I proposed in the other message because it gets the
> > > > > kernel out of the business of deciding what the right signal is. I'm a
> > > > > huge believer in "mechanism, not policy".
> > > >
> > > > It's not a question of the kernel deciding what the right signal is.
> > > > The kernel knows whether a signal is fatal to a particular process or not.
> > > > The question is whether the killing process should do the work of reaping
> > > > the dying process's resources sometimes, always or never.  Currently,
> > > > that is never (the process reaps its own resources); Suren is suggesting
> > > > sometimes, and I'm asking "Why not always?"
> > >
> > > FWIW, Suren's initial proposal is that the oom_reaper kthread do the
> > > reaping, not the process sending the kill. Are you suggesting that
> > > sending SIGKILL should spend a while in signal delivery reaping pages
> > > before returning? I thought about just doing it this way, but I didn't
> > > like the idea: it'd slow down mass-killing programs like killall(1).
> > > Programs expect sending SIGKILL to be a fast operation that returns
> > > immediately.
> >
> > I was thinking about this as well. And SYNC_SIGKILL would workaround the

SYNC_SIGKILL (which, I presume, blocks in kill(2)) was proposed in
many occasions while we discussed pidfd waits over the past six months
or so. We've decided to just make pidfds pollable instead. The kernel
already has several ways to express the idea that a task should wait
for another task to die, and I don't think we need another. If you
want a process that's waiting for a task to exit to help reap that
task, great --- that's an option we've talked about --- but we don't
need new interface to do it, since the kernel already has all the
information it needs.

> > current expectations of how quick the current implementation is. The
> > harder part would what is the actual semantic. Does the kill wait until
> > the target task is TASK_DEAD or is there an intermediate step that would
> > we could call it end of the day and still have a reasonable semantic
> > (e.g. the original pid is really not alive anymore).
>
> I think Daniel's proposal was trying to address that. With an input of
> how many pages user wants to reclaim asynchronously and return value
> of how much was actually reclaimed it contains the condition when to
> stop and the reply how successful we could accomplish that. Since it
> returns the number of pages reclaimed I assume the call does not
> return until it reaped enough pages.

Right. I want to punt as much "policy" as possible to userspace. Just
using a user thread to do the reaping not only solves the policy
problem (since it's userspace that controls priority, affinity,
retries, and so on), but also simplifies the implementation
kernel-side. I can imagine situations where, depending on device
energy state or even charger or screen state we might want to reap
more or less aggressively, or not at all. I wouldn't want to burden
the kernel with having to get that right when userspace could make the
decision.

