Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67EFBC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:27:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 262BE2086D
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:27:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="kPF7hmaf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 262BE2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2B436B027A; Tue,  6 Aug 2019 12:27:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE6366B027C; Tue,  6 Aug 2019 12:27:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CA136B027D; Tue,  6 Aug 2019 12:27:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0C06B027A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:27:19 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id u17so15791385wmd.6
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:27:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Ks68pV+pQcpLEmyiOxXRz96t/W4aSnKi5+iAyNyk/gE=;
        b=ZhxguL2gGsDtCzY6tFvbF/suw0mA5UoLlr4XtIgru4lvlbMibUCHI0AmslIiJ7sqXG
         tBle+RlBuH1/uIFq5IBzLY/KjfuuWi89Az8CHAx0hG3IE0JYxmz/47GK/v7VRlAwdGfX
         yPf9Vzqeh0dHCT5rnU3u2ewQE9TLgBkveqzIOSXTUCc6GFwWQEsCW5Je3i/adIVE25u9
         6gsyXfhSYLsHvMbauYtFEqrNU+umhMkSdAY8tyxv0yKafO9M7vi7uRiczNC1p6tpb7yH
         mTVL2BgrQkIEMumabPOTwnnz0ZqRoOgODlhQKD6TA8LS53Gyln/st8vowNzwn/MHnpAb
         HsgQ==
X-Gm-Message-State: APjAAAXPf36QxEe76yFDUhEGg6YAcRocPUD/FZnMkprfYe3KAhbSn5od
	emRqzkFRusRjKaO0bwOwOiEDZW54oUy0jbG0oWjtL/SMAKJ5nqYvaKSqllUpdlgHR5Mn9Czmtyp
	CiQBjzB5v9YCQ1V1QSlIIXGVLwEcRRfZYzaYiEu7T1sb7Boy5hdnXWwI9DC1wXgEWDA==
X-Received: by 2002:a05:600c:21d4:: with SMTP id x20mr5130602wmj.61.1565108838850;
        Tue, 06 Aug 2019 09:27:18 -0700 (PDT)
X-Received: by 2002:a05:600c:21d4:: with SMTP id x20mr5130549wmj.61.1565108837734;
        Tue, 06 Aug 2019 09:27:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565108837; cv=none;
        d=google.com; s=arc-20160816;
        b=0MmK18aSXX/DktP48A3cjYZG7KSsqP/8jVlf4SFj3fatuhXgDatKkXaaYPjXvBLXo1
         NhDIWTSFUx1BWwfmB7xauktyEcVn5A///XLQ+UWJpWKTPP78tAHrXJAo+ENtRSLlqjtw
         G3XIuhSjz3Qrk3Baz3L+zmDZlCRJS7FMFS74zFle9StXBumtrrLNRsffmRjO2+Gfb8AQ
         ewl7I7DNaXx1/mVSXNV0TF6ktkLsyGf8M19OG3uzuBAfXfUwiSixtrHGWYO12Ew5ee+y
         QNyV8EpDs/HMpQ0iWhOihUD/aoYUqKP39V8NG0unzDGFGoreEtLcj6Cmo7j4cUMam9DU
         PKLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Ks68pV+pQcpLEmyiOxXRz96t/W4aSnKi5+iAyNyk/gE=;
        b=faQuO0G/nFZU5eIT41pX/Zhga89OMI7mIVlT+7ItrfriyXVdbV2TMP73jDvCc/4+8f
         IH6o+xXHJOQh61hbN8phu5EjyEwmqCjpRkSTyNcqOL85PA77TUGZLKfbxmzVpJjeZFw8
         2ppgit1qYAaqBNiGfH3AxZpoOiZNqsOjrjO413PL2SJVB9c9BvoCYhHFkX5HwOy2V9Z6
         T2UqK7v94woiocyxPvWuvh1Lkb4aPuAh5yXglGNUPMRtsxtAKdFuYj/H/MxcgHfbuqtf
         DMh0FUJHw6NO5JzP+RNAxUmjsSQ+ClQP/eFwo0qLyiGtrhu8KblWCH5H0G7nUWMNkiZu
         0yxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kPF7hmaf;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u18sor48841701wml.12.2019.08.06.09.27.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 09:27:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kPF7hmaf;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Ks68pV+pQcpLEmyiOxXRz96t/W4aSnKi5+iAyNyk/gE=;
        b=kPF7hmafGtpnVgV3WJzmD140fPZ6avB9wiei7DSrdAx9HzVAwNo/YTaYwSr/+hs23M
         2/QGGeppoE4nReQBnlBMru0ShdCxjI4+w6iCup4dH/BMo1y2+fDyYnZHO772HVj43dcV
         75URyF088CdpW/HWe3m0arYmMvP7ap8wSOpisWI7s+rQSHKoahLZZ5rYSJ28x9GcP+F1
         LfEiZR6X24HopMiCTspJO6/9yszxq5JS3Pw1Fpni0HhjelTngGgYqsdgmyv6F38Lv/6o
         kZbWRjPGH1GGOBu5Xfm2cV0qt/eLd6QW0GovJOTqITzpsy5+ujIWWBn4E07BNlkArQqP
         v02w==
X-Google-Smtp-Source: APXvYqxqH906LyRFrGKmI+Hu/5yd0tY4SJx3TP7vli5npqM8lWs74BhfL7iUa0EHu1RyEzfNfP//hvLYlxK55C3nLnU=
X-Received: by 2002:a7b:c947:: with SMTP id i7mr5778477wml.77.1565108837080;
 Tue, 06 Aug 2019 09:27:17 -0700 (PDT)
MIME-Version: 1.0
References: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com> <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
 <20190805193148.GB4128@cmpxchg.org> <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
 <398f31f3-0353-da0c-fc54-643687bb4774@suse.cz> <20190806142728.GA12107@cmpxchg.org>
 <20190806143608.GE11812@dhcp22.suse.cz>
In-Reply-To: <20190806143608.GE11812@dhcp22.suse.cz>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 6 Aug 2019 09:27:05 -0700
Message-ID: <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, 
	"Artem S. Tashkinov" <aros@gmx.com>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 7:36 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 06-08-19 10:27:28, Johannes Weiner wrote:
> > On Tue, Aug 06, 2019 at 11:36:48AM +0200, Vlastimil Babka wrote:
> > > On 8/6/19 3:08 AM, Suren Baghdasaryan wrote:
> > > >> @@ -1280,3 +1285,50 @@ static int __init psi_proc_init(void)
> > > >>         return 0;
> > > >>  }
> > > >>  module_init(psi_proc_init);
> > > >> +
> > > >> +#define OOM_PRESSURE_LEVEL     80
> > > >> +#define OOM_PRESSURE_PERIOD    (10 * NSEC_PER_SEC)
> > > >
> > > > 80% of the last 10 seconds spent in full stall would definitely be a
> > > > problem. If the system was already low on memory (which it probably
> > > > is, or we would not be reclaiming so hard and registering such a big
> > > > stall) then oom-killer would probably kill something before 8 seconds
> > > > are passed.
> > >
> > > If oom killer can act faster, than great! On small embedded systems you probably
> > > don't enable PSI anyway?

We use PSI triggers with 1 sec tracking window. PSI averages are less
useful on such systems because in 10 secs (which is the shortest PSI
averaging window) memory conditions can change drastically.

> > > > If my line of thinking is correct, then do we really
> > > > benefit from such additional protection mechanism? I might be wrong
> > > > here because my experience is limited to embedded systems with
> > > > relatively small amounts of memory.
> > >
> > > Well, Artem in his original mail describes a minutes long stall. Things are
> > > really different on a fast desktop/laptop with SSD. I have experienced this as
> > > well, ending up performing manual OOM by alt-sysrq-f (then I put more RAM than
> > > 8GB in the laptop). IMHO the default limit should be set so that the user
> > > doesn't do that manual OOM (or hard reboot) before the mechanism kicks in. 10
> > > seconds should be fine.
> >
> > That's exactly what I have experienced in the past, and this was also
> > the consistent story in the bug reports we have had.
> >
> > I suspect it requires a certain combination of RAM size, CPU speed,
> > and IO capacity: the OOM killer kicks in when reclaim fails, which
> > happens when all scanned LRU pages were locked and under IO. So IO
> > needs to be slow enough, or RAM small enough, that the CPU can scan
> > all LRU pages while they are temporarily unreclaimable (page lock).
> >
> > It may well be that on phones the RAM is small enough relative to CPU
> > size.
> >
> > But on desktops/servers, we frequently see that there is a wider
> > window of memory consumption in which reclaim efficiency doesn't drop
> > low enough for the OOM killer to kick in. In the time it takes the CPU
> > to scan through RAM, enough pages will have *just* finished reading
> > for reclaim to free them again and continue to make "progress".
> >
> > We do know that the OOM killer might not kick in for at least 20-25
> > minutes while the system is entirely unresponsive. People usually
> > don't wait this long before forcibly rebooting. In a managed fleet,
> > ssh heartbeat tests eventually fail and force a reboot.

Got it. Thanks for the explanation.

> > I'm not sure 10s is the perfect value here, but I do think the kernel
> > should try to get out of such a state, where interacting with the
> > system is impossible, within a reasonable amount of time.
> >
> > It could be a little too short for non-interactive number-crunching
> > systems...
>
> Would it be possible to have a module with tunning knobs as parameters
> and hook into the PSI infrastructure? People can play with the setting
> to their need, we wouldn't really have think about the user visible API
> for the tuning and this could be easily adopted as an opt-in mechanism
> without a risk of regressions.

PSI averages stalls over 10, 60 and 300 seconds, so implementing 3
corresponding thresholds would be easy. The patch Johannes posted can
be extended to support 3 thresholds instead of 1. I can take a stab at
it if Johannes is busy.
If we want more flexibility we could use PSI triggers with
configurable tracking window but that's more complex and probably not
worth it.

> I would really love to see a simple threshing watchdog like the one you
> have proposed earlier. It is self contained and easy to play with if the
> parameters are not hardcoded.
>
> --
> Michal Hocko
> SUSE Labs

