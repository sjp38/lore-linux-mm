Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D20BEC43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 17:31:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 028CF206BF
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 17:31:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="OqHCggXL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 028CF206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3E756B0003; Thu, 25 Apr 2019 13:31:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEE4F6B0005; Thu, 25 Apr 2019 13:31:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DC636B0006; Thu, 25 Apr 2019 13:31:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 486466B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:31:57 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id g18so487498wrs.17
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 10:31:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=LRdmWJDsSG1mH9oOmG3B0hE4NTtss8p86N1SZSmbqRw=;
        b=UpNGfDpcIXtG5gJ72AoMrApEvfzrTQEYBEEfVd5n6LBEQAe6/V0Ya+r/bPSXbkTCBY
         lLE/HQpLBl3PN0TTbInkHt6C4ig0y+8Ma5GUd3UdDqE3Wki6J1GRuhdp9ICJO+uzqjw3
         ejq7ejrCrQibwNCyW2Xg0/J/wv1QZJjfDCA22NfWXycUBAZJ574l3WDbETyoPtzB60GF
         VX+y1Q6kMZnYsQGi+fSqS/4T2YzhihUmxMZ4aUG+HecpA69Iy/nqjbOFftY+upXRa7IX
         AyQAFDzgnEUVXqGUCObf9y9Rw3g4ZVkoRDNpInMrxUHmc6UI+PTT2owil1tTMl1CqUBh
         8SrQ==
X-Gm-Message-State: APjAAAUkHmi0BTD0LEhotKvV6Xd86E4pqW2OJ7yo3tJqAH5lNiNI1Yj3
	AigKSDTKW/wIoxJ4pms5dqiT7wFn3Opxy++p20wV++RQUYr1vivbF3Jgp/8SU5NHWNUowYEVBDn
	ZNMWd9uQNxGPeLywpxCgoaS2gPylMS9if41wWR/cvT/Rn1ws8LtKpG2+RKQITRahh2g==
X-Received: by 2002:a05:6000:1242:: with SMTP id j2mr5933034wrx.274.1556213516526;
        Thu, 25 Apr 2019 10:31:56 -0700 (PDT)
X-Received: by 2002:a05:6000:1242:: with SMTP id j2mr5932974wrx.274.1556213515275;
        Thu, 25 Apr 2019 10:31:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556213515; cv=none;
        d=google.com; s=arc-20160816;
        b=qhXs9LL91lRDJw+JBFs0jQuvrKtIKWk/be4L613Jc0xpFb2ADPIMTNRchn6K0yFrJv
         sM0woOZpqyLlUm/4+/wCWr8VP8zUy6NxH78hmGd8ebt8oE/ivJ05/kdfBNJkR+GKSIsN
         SDl0sSY2lL1heds/zm00yxLXa7k+ZgPD2WDXbaL/nFpbudojs63b26L351TxeFtvJVAY
         atConR9uFBq5rMlgKX86PEwpZ7QRI9r5741SuXTvdV6XWtNCQUW4fiesj33Zm/McmVev
         O52muDItE4XvLWv4heImaCHeunpQZA5U+AwisZz40uK0BbKqggQsnJRO0Z00fJpbxz9j
         AUJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=LRdmWJDsSG1mH9oOmG3B0hE4NTtss8p86N1SZSmbqRw=;
        b=xtiqr9XK622hgOkYv9p3AQ/gFECbfF5s+X+5YBPrKEMg/QrpmxGJOFNG/2CTm55RUG
         1lJ8DSOYE2+WXOYWNaU4LBC0tUdXKnQ+tYD5lOZS5yZbQFA3IgiFg9LvFM2Wn9XAjZRe
         jV+9YRGOQzpOJYkwmdr29298bANIGXCJ9p/bCwfAqO0bOVdpgFVGyHyF/oFD/zcLsQIf
         jAxy1pl/FTkKYhbvTAQcVJ/PQaPJ5T4Jokg4I/YapqAjF4sdckRkJITEnA1zrZvY+HnQ
         KTflogZb/plddPJvogDy8xScaSz9ouo6g7KcwC0lTzEKZabGOqG8SBPDzZZnGG8UIK4+
         Bo4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=OqHCggXL;
       spf=pass (google.com: domain of semenzato@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=semenzato@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f187sor9773418wme.18.2019.04.25.10.31.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 10:31:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of semenzato@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=OqHCggXL;
       spf=pass (google.com: domain of semenzato@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=semenzato@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LRdmWJDsSG1mH9oOmG3B0hE4NTtss8p86N1SZSmbqRw=;
        b=OqHCggXLWkWK1r+i5DT0AzuoThvi9oEvSsIPEqCVFhk8sNuabDiGSmU6ckNAmL38o7
         dHg+MO4X/zge04tQVHwJIVrsOMhnybIcOmzbZ0xpMTFAu10r/jkeOrG07GEGeDqDoAIf
         z0Tq+XlsMt8xpWUPVS15of2maH727ld5o8Rk56nluIcqCZgOrRWDgcDkmhdEiU7QxBXE
         0RP+O36Il3IASCld40ZdsuvGBn3xYotjlBj0XQ+0i2zBSjVq9QOhxtJRf6e5HvGgr3Gy
         vnWYNFC9fn9cKv54d/kIncV1SsOnYNiLrLumFaMqj6tUMVI/86cXkN3BY8d3+EF8Va6Y
         ocag==
X-Google-Smtp-Source: APXvYqz6wqcuA3aMH0WchKbaDYRwTCOmRdBM1kTmPVhuXJ9Xn87LMTXGNdMPQzp7FyXuH352H6ebF1dsbumW7vzYD20=
X-Received: by 2002:a1c:5459:: with SMTP id p25mr4394437wmi.20.1556213514291;
 Thu, 25 Apr 2019 10:31:54 -0700 (PDT)
MIME-Version: 1.0
References: <CAA25o9TV7B5Cej_=snuBcBnNFpfixBEQduTwQZOH0fh5iyXd=A@mail.gmail.com>
 <CAJuCfpHGcDM8c19g_AxWa4FSx++YbTSE70CGW4TiKvrdAg3R+w@mail.gmail.com>
 <CAA25o9Rzcqts7oCpwyRq2yBALkHQVwgzgFDVYv08Z0UUhY+qhw@mail.gmail.com> <CAJuCfpHMEVHYpodjsote2Gp0y_G1=Hi66xzdhXfOgtcMMiiL9g@mail.gmail.com>
In-Reply-To: <CAJuCfpHMEVHYpodjsote2Gp0y_G1=Hi66xzdhXfOgtcMMiiL9g@mail.gmail.com>
From: Luigi Semenzato <semenzato@google.com>
Date: Thu, 25 Apr 2019 10:31:40 -0700
Message-ID: <CAA25o9Qc6A_v_ehDDen_AyDJHNR4ymEAvpoqCbvWzWzp0caUYA@mail.gmail.com>
Subject: Re: PSI vs. CPU overhead for client computing
To: Suren Baghdasaryan <surenb@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thank you, I can try to do that.

It's not trivial to get right though.  I have to find the right
compromise.  A horribly wrong patch won't be taken seriously, but a
completely correct one would be a bit too much work, given the
probability that it will get rejected.

Thanks also to Johannes for the clarification!

On Wed, Apr 24, 2019 at 7:49 AM Suren Baghdasaryan <surenb@google.com> wrote:
>
> On Tue, Apr 23, 2019 at 9:54 PM Luigi Semenzato <semenzato@google.com> wrote:
> >
> > Thank you very much Suren.
> >
> > On Tue, Apr 23, 2019 at 3:04 PM Suren Baghdasaryan <surenb@google.com> wrote:
> > >
> > > Hi Luigi,
> > >
> > > On Tue, Apr 23, 2019 at 11:58 AM Luigi Semenzato <semenzato@google.com> wrote:
> > > >
> > > > I and others are working on improving system behavior under memory
> > > > pressure on Chrome OS.  We use zram, which swaps to a
> > > > statically-configured compressed RAM disk.  One challenge that we have
> > > > is that the footprint of our workloads is highly variable.  With zram,
> > > > we have to set the size of the swap partition at boot time.  When the
> > > > (logical) swap partition is full, we're left with some amount of RAM
> > > > usable by file and anonymous pages (we can ignore the rest).  We don't
> > > > get to control this amount dynamically.  Thus if the workload fits
> > > > nicely in it, everything works well.  If it doesn't, then the rate of
> > > > anonymous page faults can be quite high, causing large CPU overhead
> > > > for compression/decompression (as well as for other parts of the MM).
> > > >
> > > > In Chrome OS and Android, we have the luxury that we can reduce
> > > > pressure by terminating processes (tab discard in Chrome OS, app kill
> > > > in Android---which incidentally also runs in parallel with Chrome OS
> > > > on some chromebooks).  To help decide when to reduce pressure, we
> > > > would like to have a reliable and device-independent measure of MM CPU
> > > > overhead.  I have looked into PSI and have a few questions.  I am also
> > > > looking for alternative suggestions.
> > > >
> > > > PSI measures the times spent when some and all tasks are blocked by
> > > > memory allocation.  In some experiments, this doesn't seem to
> > > > correlate too well with CPU overhead (which instead correlates fairly
> > > > well with page fault rates).  Could this be because it includes
> > > > pressure from file page faults?
> > >
> > > This might be caused by thrashing (see:
> > > https://elixir.bootlin.com/linux/v5.1-rc6/source/mm/filemap.c#L1114).
> > >
> > > >  Is there some way of interpreting PSI
> > > > numbers so that the pressure from file pages is ignored?
> > >
> > > I don't think so but I might be wrong. Notice here
> > > https://elixir.bootlin.com/linux/v5.1-rc6/source/mm/filemap.c#L1111
> > > you could probably use delayacct to distinguish file thrashing,
> > > however remember that PSI takes into account the number of CPUs and
> > > the number of currently non-idle tasks in its pressure calculations,
> > > so the raw delay numbers might not be very useful here.
> >
> > OK.
> >
> > > > What is the purpose of "some" and "full" in the PSI measurements?  The
> > > > chrome browser is a multi-process app and there is a lot of IPC.  When
> > > > process A is blocked on memory allocation, it cannot respond to IPC
> > > > from process B, thus effectively both processes are blocked on
> > > > allocation, but we don't see that.
> > >
> > > I don't think PSI would account such an indirect stall when A is
> > > waiting for B and B is blocked on memory access. B's stall will be
> > > accounted for but I don't think A's blocked time will go into PSI
> > > calculations. The process inter-dependencies are probably out of scope
> > > for PSI.
> >
> > Right, that's what I was also saying.  It would be near impossible to
> > figure it out.  It may also be that statistically it doesn't matter,
> > as long as the workload characteristics don't change dramatically.
> > Which unfortunately they might...
> >
> > > > Also, there are situations in
> > > > which some "uninteresting" process keep running.  So it's not clear we
> > > > can rely on "full".  Or maybe I am misunderstanding?  "Some" may be a
> > > > better measure, but again it doesn't measure indirect blockage.
> > >
> > > Johannes explains the SOME and FULL calculations here:
> > > https://elixir.bootlin.com/linux/v5.1-rc6/source/kernel/sched/psi.c#L76
> > > and includes couple examples with the last one showing FULL>0 and some
> > > tasks still running.
> >
> > Thank you, yes, those are good explanation.  I am still not sure how
> > to use this in our case.
> >
> > I thought about using the page fault rate as a proxy for the
> > allocation overhead.  Unfortunately it is difficult to figure out the
> > baseline, because: 1. it is device-dependent (that's not
> > insurmountable: we could compute a per-device baseline offline); 2.
> > the CPUs can go in and out of turbo mode, or temperature-throttling,
> > and the notion of a constant "baseline" fails miserably.
> >
> > > > The kernel contains various cpustat measurements, including some
> > > > slightly esoteric ones such as CPUTIME_GUEST and CPUTIME_GUEST_NICE.
> > > > Would adding a CPUTIME_MEM be out of the question?
> >
> > Any opinion on CPUTIME_MEM?
>
> I guess some description of how you plan to calculate it would be
> helpful. A simple raw delay counter might not be very useful, that's
> why PSI performs more elaborate calculations.
> Maybe posting a small RFC patch with code would get more attention and
> you can collect more feedback.
>
> > Thanks again!
> >
> > > > Thanks!
> > > >
> > >
> > > Just my 2 cents and Johannes being the author might have more to say here.

