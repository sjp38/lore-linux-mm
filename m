Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56793C072A4
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 04:24:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3CF020675
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 04:24:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="cTctEi3a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3CF020675
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 479D26B0003; Wed, 22 May 2019 00:24:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42A516B0006; Wed, 22 May 2019 00:24:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F20F6B0007; Wed, 22 May 2019 00:24:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D8A1A6B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 00:24:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t58so1590584edb.22
        for <linux-mm@kvack.org>; Tue, 21 May 2019 21:24:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+NQu0NI8ncRqI8fsVQtJ0PPb5XIcqSyNmrQ1DHUlIgA=;
        b=azs1SRrUs/1vlelqvJrdVVktJg6CQzqTvtrf/DAAK7VaN6mknWvaFcR/6LS0TRyvpO
         MIW0D2qeRqlXCHZajMKIXpyOm9Snz0hDrMrG4tH+cIAt+orFb4Y1M/UmbrkaU6iFhOgX
         SqJgwOPzgSwzn8alWp8BCRlVj69kJURZoDhDwmEJ6HtXGODbyYQeJc70VamkJujM4f6j
         CVxHLCEUj1vlP8bb07PO0WSsUSbcTiyzBlPc3CeW3W771rsHuMmToncydgkppvw8vDql
         EUx+Robai0oFqvapvO+bfymN1w23szI0hKAWz+UVLZZscVtTTtECqNQ/RRuRrJsU2pkW
         KJ5w==
X-Gm-Message-State: APjAAAW+gya3QgbYzRhCyvdFe1AoXsbu94FkmOTkEOCaDt6xoPspcuPC
	t8li2dPds+hQoAETO+APrijzD+5GNsP00gNwu+j4MrSUgfOLAF7DuSfqIVR4KbF3Xcss2DeJh0N
	Vyvpl6DWCqdY99oCS6GQgbbh+bUCpKsoT1AkwneAwfyl+VmVKZy3PKovXpf7SqIFL1Q==
X-Received: by 2002:a17:906:1fcb:: with SMTP id e11mr60913370ejt.221.1558499043378;
        Tue, 21 May 2019 21:24:03 -0700 (PDT)
X-Received: by 2002:a17:906:1fcb:: with SMTP id e11mr60913337ejt.221.1558499042555;
        Tue, 21 May 2019 21:24:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558499042; cv=none;
        d=google.com; s=arc-20160816;
        b=gA+sVfyHWZf1QY33I/jqRHgPBMlAuhYJjvF9wwqUOZ8YRNTvfbVN0SRoU2LOTConNT
         Bgsw4alR1jmnMyf+ingRroG17FeyKpuGeLbRE2Sove0UgGf1P5u0lvCK2foe0IcxZFfw
         P+ItVcpP0k9dJBsi43EWecVF44FP82bTx4EVj68Jh+kiIYayjqTDafDZNqMiWtj/+EmB
         v0kLCWY0i8Oyma0tveLOyLwMNRnW/lsRL2dvgrs8ReqP3zviB21BdNJQLBRTwtP7ckXD
         p8evP+nYhutlavFMzkgpUJ5paelwsAu7syZE4nXEdaYPR91bRGPoxjOLXzFA7q+9m6NO
         K9ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+NQu0NI8ncRqI8fsVQtJ0PPb5XIcqSyNmrQ1DHUlIgA=;
        b=wgusqG+ZOrl6SWga0KZgXVt6gGjJwYOLt2WbnXCopn783hGnBjHIR7ywXo0Mn8N+dq
         TnydNfbcwS59sMYWn91q6CsUW2CgACbP7umtVpv0D3Sp2aYac8RqMY5vMVjXwygiMO7m
         rYBqtnfXB3VKj0EyuUYA57fT1LAd3O+uQaySyt89J1VeCExESF0axKpT1ALzKP93LkFP
         gN/8gj74xR3ZAxQiy1wCROBq0qb8pBb50vHqk/7Y4pARwyJ3kQ1XCUIB8CJRuzIJZM8q
         JmQJrIL+iDqmNzDbQd5xaFGT2vq9US9Q8cYsF0hTppp/Y94101S0WZPoEIlTwaGXlCLK
         GJMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cTctEi3a;
       spf=pass (google.com: domain of bgeffon@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bgeffon@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y47sor11530479edc.29.2019.05.21.21.24.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 21:24:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of bgeffon@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cTctEi3a;
       spf=pass (google.com: domain of bgeffon@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bgeffon@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+NQu0NI8ncRqI8fsVQtJ0PPb5XIcqSyNmrQ1DHUlIgA=;
        b=cTctEi3aTljPqIa9jevUUtkhUYP6k7DFrA/xHnftumm9ApHTJKy3N++7Ueoj0t2YuR
         GqtafLyvkH2P4JExAvskMZj3A+phaDWwFHrdXLM5Q9UZw4i4ZPRvt4R4WScaJZ0QxMvh
         rsoFhFnx/DRaxyTPlryjIEHTPtMsJi8CGRuw9mz8pc53fXK5Y5dHApQF2uGnifIy/9aA
         KDgZVDf2tH57ieUxk0C9OSNHKLsLTL6tAD+m436cT3jECDzLtJfQnw69G5l+euN9240+
         5vYHG/3HNGySzVeHP4I7Bw7WhrwBfcwQIX7ZmqYPgwOsow8gxFB1vjkoBZHwClOkmyoW
         2aYw==
X-Google-Smtp-Source: APXvYqyRHcfinxI7Xw/i+5OLohhLHbRhnK8lQ37zl+2Edp8bEtKpoEyaN6XkTY8Aox/DgqYZ2vbzhn7fg2fKtixYDMo=
X-Received: by 2002:a50:9264:: with SMTP id j33mr85821109eda.125.1558499041640;
 Tue, 21 May 2019 21:24:01 -0700 (PDT)
MIME-Version: 1.0
References: <20190520035254.57579-1-minchan@kernel.org> <dbe801f0-4bbe-5f6e-9053-4b7deb38e235@arm.com>
 <CAEe=Sxka3Q3vX+7aWUJGKicM+a9Px0rrusyL+5bB1w4ywF6N4Q@mail.gmail.com>
 <1754d0ef-6756-d88b-f728-17b1fe5d5b07@arm.com> <CALvZod6ioRxSi7tHB-uSTxN1-hsxD+8O3mfFAjaqdsimjUVmcw@mail.gmail.com>
In-Reply-To: <CALvZod6ioRxSi7tHB-uSTxN1-hsxD+8O3mfFAjaqdsimjUVmcw@mail.gmail.com>
From: Brian Geffon <bgeffon@google.com>
Date: Tue, 21 May 2019 21:23:35 -0700
Message-ID: <CADyq12xG5AO-bAniiMwrW+7W4jBdJVsacVC_gbOq_g4zQ=X12g@mail.gmail.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
To: Shakeel Butt <shakeelb@google.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, Tim Murray <timmurray@google.com>, 
	Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Daniel Colascione <dancol@google.com>, Sonny Rao <sonnyrao@google.com>, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To expand on the ChromeOS use case we're in a very similar situation
to Android. For example, the Chrome browser uses a separate process
for each individual tab (with some exceptions) and over time many tabs
remain open in a back-grounded or idle state. Given that we have a lot
of information about the weight of a tab, when it was last active,
etc, we can benefit tremendously from per-process reclaim. We're
working on getting real world numbers but all of our initial testing
shows very promising results.


On Tue, May 21, 2019 at 5:57 AM Shakeel Butt <shakeelb@google.com> wrote:
>
> On Mon, May 20, 2019 at 7:55 PM Anshuman Khandual
> <anshuman.khandual@arm.com> wrote:
> >
> >
> >
> > On 05/20/2019 10:29 PM, Tim Murray wrote:
> > > On Sun, May 19, 2019 at 11:37 PM Anshuman Khandual
> > > <anshuman.khandual@arm.com> wrote:
> > >>
> > >> Or Is the objective here is reduce the number of processes which get killed by
> > >> lmkd by triggering swapping for the unused memory (user hinted) sooner so that
> > >> they dont get picked by lmkd. Under utilization for zram hardware is a concern
> > >> here as well ?
> > >
> > > The objective is to avoid some instances of memory pressure by
> > > proactively swapping pages that userspace knows to be cold before
> > > those pages reach the end of the LRUs, which in turn can prevent some
> > > apps from being killed by lmk/lmkd. As soon as Android userspace knows
> > > that an application is not being used and is only resident to improve
> > > performance if the user returns to that app, we can kick off
> > > process_madvise on that process's pages (or some portion of those
> > > pages) in a power-efficient way to reduce memory pressure long before
> > > the system hits the free page watermark. This allows the system more
> > > time to put pages into zram versus waiting for the watermark to
> > > trigger kswapd, which decreases the likelihood that later memory
> > > allocations will cause enough pressure to trigger a kill of one of
> > > these apps.
> >
> > So this opens up bit of LRU management to user space hints. Also because the app
> > in itself wont know about the memory situation of the entire system, new system
> > call needs to be called from an external process.
> >
> > >
> > >> Swapping out memory into zram wont increase the latency for a hot start ? Or
> > >> is it because as it will prevent a fresh cold start which anyway will be slower
> > >> than a slow hot start. Just being curious.
> > >
> > > First, not all swapped pages will be reloaded immediately once an app
> > > is resumed. We've found that an app's working set post-process_madvise
> > > is significantly smaller than what an app allocates when it first
> > > launches (see the delta between pswpin and pswpout in Minchan's
> > > results). Presumably because of this, faulting to fetch from zram does
> >
> > pswpin      417613    1392647     975034     233.00
> > pswpout    1274224    2661731    1387507     108.00
> >
> > IIUC the swap-in ratio is way higher in comparison to that of swap out. Is that
> > always the case ? Or it tend to swap out from an active area of the working set
> > which faulted back again.
> >
> > > not seem to introduce a noticeable hot start penalty, not does it
> > > cause an increase in performance problems later in the app's
> > > lifecycle. I've measured with and without process_madvise, and the
> > > differences are within our noise bounds. Second, because we're not
> >
> > That is assuming that post process_madvise() working set for the application is
> > always smaller. There is another challenge. The external process should ideally
> > have the knowledge of active areas of the working set for an application in
> > question for it to invoke process_madvise() correctly to prevent such scenarios.
> >
> > > preemptively evicting file pages and only making them more likely to
> > > be evicted when there's already memory pressure, we avoid the case
> > > where we process_madvise an app then immediately return to the app and
> > > reload all file pages in the working set even though there was no
> > > intervening memory pressure. Our initial version of this work evicted
> >
> > That would be the worst case scenario which should be avoided. Memory pressure
> > must be a parameter before actually doing the swap out. But pages if know to be
> > inactive/cold can be marked high priority to be swapped out.
> >
> > > file pages preemptively and did cause a noticeable slowdown (~15%) for
> > > that case; this patch set avoids that slowdown. Finally, the benefit
> > > from avoiding cold starts is huge. The performance improvement from
> > > having a hot start instead of a cold start ranges from 3x for very
> > > small apps to 50x+ for larger apps like high-fidelity games.
> >
> > Is there any other real world scenario apart from this app based ecosystem where
> > user hinted LRU management might be helpful ? Just being curious. Thanks for the
> > detailed explanation. I will continue looking into this series.
>
> Chrome OS is another real world use-case for this user hinted LRU
> management approach by proactively reclaiming reclaim from tabs not
> accessed by the user for some time.

