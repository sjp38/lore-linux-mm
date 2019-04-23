Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82E11C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 22:04:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BF172148D
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 22:04:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tzCpCF0w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BF172148D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDF106B0003; Tue, 23 Apr 2019 18:04:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8DBE6B0005; Tue, 23 Apr 2019 18:04:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA3896B0007; Tue, 23 Apr 2019 18:04:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5CAEF6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 18:04:30 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id r193so951060wmf.1
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 15:04:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jZC/4ItOVUtJQ+79h55VBuyoecLY1VD6QB7XNFzKepY=;
        b=ayGoTqMnMX9jQfVB0SOZ+u2ZOM3yfaQrBg0dOkwZQxRlADBaFq2Xmw42mfXMGP1YO8
         VlUbjuN4g7QzDX+8027pRDC26cRyFZK1ylcS3cL3FF1wmkIx4sgbSKHRIbcrdOMgLdjy
         sqcPe2yknkisJdcMlZAoFZIgis8PJkz8RFaSz1rCpZpWUgUXnlT2/lIvtI3b2ffXAxtL
         s/ukho41plJOaCXAn2AF3bKzUHmGp3/rMa1Hc90fTwKhNSKYYO0E7EpbxYJJRJmYCoa2
         SdzVGKh62rawvF215EX6HGrZrtlPuQZxdCT8LFH/dPBcUXDsMb9mLzzWQAqiajz9z9+x
         RFYw==
X-Gm-Message-State: APjAAAXfrmQfQ56wdffehUEubsB993aF+VJvpRqnfPX84xE/f9Ovk4Mh
	79qsT53ybgV5jx6calmFT1azyDcIfxL58/xbYkXcA2MZo+p5usl5l3fozqj3yiaGM1+gniQO+3w
	RxxSM5ZneH2h41YtfVxRZ5ULlkhWWTennMCn/Ujfr/8F6XHeZ9d5RLYyx5ayXPVN7oQ==
X-Received: by 2002:adf:8051:: with SMTP id 75mr19815130wrk.2.1556057069719;
        Tue, 23 Apr 2019 15:04:29 -0700 (PDT)
X-Received: by 2002:adf:8051:: with SMTP id 75mr19815094wrk.2.1556057068709;
        Tue, 23 Apr 2019 15:04:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556057068; cv=none;
        d=google.com; s=arc-20160816;
        b=CvY43cweHwOO2vAWQ0u27+gNG4DLmBJK2HmWUVnfxm9XKTiBJb8i2dB7w7sQT0KbmZ
         FrXr0XVVh774L5XCSyXKnYMfunGRa/FCObv04PZJTpszv64Ul15fTW6HVbrcKTHlUpNZ
         dXwjxQ1mc8GMeqEeGOfmdDPlfAAfb8P9qj3WfSyckqZSxzNbkIIeN1j8rfKGa+YdIr+X
         0tGPvLFaDb+4qfYEPKSHrgYnZW3ZTEDlBJ1vsG5UjA2fRiP2zn3nipQdN1FMLAlmJrAC
         f98oLjyKfK42wd1/VVmM3yhuUIH5sQigGSWpF4uvoER9r1khX4RhKxmHzlLaOWcPWCD9
         l23Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jZC/4ItOVUtJQ+79h55VBuyoecLY1VD6QB7XNFzKepY=;
        b=C8GOAIV1ILrsCJnSvDalxJJSukpmqudNGdG3wK6qFB/KHdVStpTEGsckE058clVzLK
         II8r2bF2m9UfAeuF18dVODJTUaC92R+FFCsEa7TxHrtsj5CJX/O0qtLAjXst0YH4wQuy
         tWmpdxp67JWn64+HqThv1ocEcYUK9TgPa+8GTGGOQXeV76VsXHD036epVDHpSATxP95p
         AfIhxcYdPkQjyUjgsf2ipnbRhWXjKyIG8ONF7JiROH9vsOr2GceYtJLkn6cWUYOlNTwr
         1fOHLchcnu2raU0E3HMznQt2ka2kCOvzddtKvdeA8pJpho+pI6/ALXeIP3iy2njGQa39
         ef3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tzCpCF0w;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b14sor8049280wrx.15.2019.04.23.15.04.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 15:04:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tzCpCF0w;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jZC/4ItOVUtJQ+79h55VBuyoecLY1VD6QB7XNFzKepY=;
        b=tzCpCF0wrgrwrB1zNzdTSWqZJZtPT5jg2cfCav4HePaqnERSTShv3eGdZVUDmscfSu
         ocq+nACMPdTHXG5lbYxM4Xy/oMMyAsVPiClBsOK8T+vZ8cJ7vUwz6g9QQAoQ/vG+8bOE
         d9nDviioOXG254mh7gonjrZrFGvcZk8ZS+8B9v7ZxsAl0jJjRdGvawm/3jGncSbSB3jN
         DnREFnXpIefUkYvjNDiaMWlLOwVP1Kq457gqqrisnIQEJjilmBr9DozQ+2zWXFdtyTVP
         VvEcMHJQjIlwzY+TmExzFSVPUdf2j1HgDSak9qKSy9Slqdw5ALoYpn91OxUZuuMA3vU8
         4/5Q==
X-Google-Smtp-Source: APXvYqzFwGk/Q3GFo4pzd+9S/kswffZAzLsmwGbcRP5IEGZsIgApFZpjObvPw1WKUJVyq8yBPNkKaAUCpHAVwxqSeaw=
X-Received: by 2002:a5d:4f8b:: with SMTP id d11mr18020065wru.150.1556057067584;
 Tue, 23 Apr 2019 15:04:27 -0700 (PDT)
MIME-Version: 1.0
References: <CAA25o9TV7B5Cej_=snuBcBnNFpfixBEQduTwQZOH0fh5iyXd=A@mail.gmail.com>
In-Reply-To: <CAA25o9TV7B5Cej_=snuBcBnNFpfixBEQduTwQZOH0fh5iyXd=A@mail.gmail.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 23 Apr 2019 15:04:16 -0700
Message-ID: <CAJuCfpHGcDM8c19g_AxWa4FSx++YbTSE70CGW4TiKvrdAg3R+w@mail.gmail.com>
Subject: Re: PSI vs. CPU overhead for client computing
To: Luigi Semenzato <semenzato@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Luigi,

On Tue, Apr 23, 2019 at 11:58 AM Luigi Semenzato <semenzato@google.com> wrote:
>
> I and others are working on improving system behavior under memory
> pressure on Chrome OS.  We use zram, which swaps to a
> statically-configured compressed RAM disk.  One challenge that we have
> is that the footprint of our workloads is highly variable.  With zram,
> we have to set the size of the swap partition at boot time.  When the
> (logical) swap partition is full, we're left with some amount of RAM
> usable by file and anonymous pages (we can ignore the rest).  We don't
> get to control this amount dynamically.  Thus if the workload fits
> nicely in it, everything works well.  If it doesn't, then the rate of
> anonymous page faults can be quite high, causing large CPU overhead
> for compression/decompression (as well as for other parts of the MM).
>
> In Chrome OS and Android, we have the luxury that we can reduce
> pressure by terminating processes (tab discard in Chrome OS, app kill
> in Android---which incidentally also runs in parallel with Chrome OS
> on some chromebooks).  To help decide when to reduce pressure, we
> would like to have a reliable and device-independent measure of MM CPU
> overhead.  I have looked into PSI and have a few questions.  I am also
> looking for alternative suggestions.
>
> PSI measures the times spent when some and all tasks are blocked by
> memory allocation.  In some experiments, this doesn't seem to
> correlate too well with CPU overhead (which instead correlates fairly
> well with page fault rates).  Could this be because it includes
> pressure from file page faults?

This might be caused by thrashing (see:
https://elixir.bootlin.com/linux/v5.1-rc6/source/mm/filemap.c#L1114).

>  Is there some way of interpreting PSI
> numbers so that the pressure from file pages is ignored?

I don't think so but I might be wrong. Notice here
https://elixir.bootlin.com/linux/v5.1-rc6/source/mm/filemap.c#L1111
you could probably use delayacct to distinguish file thrashing,
however remember that PSI takes into account the number of CPUs and
the number of currently non-idle tasks in its pressure calculations,
so the raw delay numbers might not be very useful here.

> What is the purpose of "some" and "full" in the PSI measurements?  The
> chrome browser is a multi-process app and there is a lot of IPC.  When
> process A is blocked on memory allocation, it cannot respond to IPC
> from process B, thus effectively both processes are blocked on
> allocation, but we don't see that.

I don't think PSI would account such an indirect stall when A is
waiting for B and B is blocked on memory access. B's stall will be
accounted for but I don't think A's blocked time will go into PSI
calculations. The process inter-dependencies are probably out of scope
for PSI.

> Also, there are situations in
> which some "uninteresting" process keep running.  So it's not clear we
> can rely on "full".  Or maybe I am misunderstanding?  "Some" may be a
> better measure, but again it doesn't measure indirect blockage.

Johannes explains the SOME and FULL calculations here:
https://elixir.bootlin.com/linux/v5.1-rc6/source/kernel/sched/psi.c#L76
and includes couple examples with the last one showing FULL>0 and some
tasks still running.

> The kernel contains various cpustat measurements, including some
> slightly esoteric ones such as CPUTIME_GUEST and CPUTIME_GUEST_NICE.
> Would adding a CPUTIME_MEM be out of the question?
>
> Thanks!
>

Just my 2 cents and Johannes being the author might have more to say here.

