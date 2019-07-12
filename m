Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A156C742A1
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 01:47:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1FDF2084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 01:47:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="II0x1Qlt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1FDF2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C4378E010E; Thu, 11 Jul 2019 21:47:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44D6B8E00DB; Thu, 11 Jul 2019 21:47:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EFF38E010E; Thu, 11 Jul 2019 21:47:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3A08E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 21:47:52 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id 132so8861973iou.0
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 18:47:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IRJ3kHRWOZ6Oa/wZZvzUAN7hy8bsQmwl1E7zLBkE46k=;
        b=eE7hLLo0RQn9pw7VUmDY93qzO1gHoEAY2+xWAYYcO7cjBgMZ6hRY2GSKomGY9LjG23
         aYc7tblLB/bEYM2zIPNEBWm7R+cSQ8FWUh1SnXT0G6VSgrZ4jDKEI5+71s+WBkTNfTjE
         e3xDlF6Z9FBI0l9xRmuMN0a0jPOuVC5oeGmX7IYqnDS5E7tbQu02SLP0CxGtAyh8taFW
         fqIfUOM3S5A8eWSWsts3Rh+ts5YPwJHCQACcFrzU2AXgylFYV8H1533c6sDLScioDGek
         cssusv+BNvKE8em6NvkSUotM+yAOWAuPA6yTfsjtXYzKHI79UMpIf0vXZYtT+wlew4vR
         LrLg==
X-Gm-Message-State: APjAAAX4tYNytRw7f+Xj5o80BlOZM6avfRuUpjH67a8m2IidhdWuvrw6
	la96HmHFmwYEzTioxepPunYmmfw0D/nVYGHuBG8baJWu67E2KaSpuPIeN/Ju8H9aKnr6WdXM20N
	x258ZQRkT9u/D3kjnQd2dw0D3Stwt88MdcnLKC+Xtyk8RRlX5sZq2YKOGJpKiVO/6qg==
X-Received: by 2002:a5d:948f:: with SMTP id v15mr7389669ioj.93.1562896071744;
        Thu, 11 Jul 2019 18:47:51 -0700 (PDT)
X-Received: by 2002:a5d:948f:: with SMTP id v15mr7389618ioj.93.1562896070963;
        Thu, 11 Jul 2019 18:47:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562896070; cv=none;
        d=google.com; s=arc-20160816;
        b=CPVh7gmuaeIa50z5PEus4uBUABtwPHivIU+PHiEPY8auAyyn/5Ab9DJboY8gbn18N1
         LEEFSlWZJv7N38+RGFKM2c6tJr4rhIsda5W1by+M+udle5nzC/aqVlO8RM8B+btmaFEq
         vEIHqnSC5GRJO7WZE1K31PXKQG7xImq1kieaYROo0GWO6+4NUxMNV5ppC0Do6uHS0EXF
         xs7/sNIbPw/LeGNI48KRYSyn90HW7ckfrsg3YAINiqnoqLu67/lwPCMoc4ggo/tQyXkZ
         LV3DaMTlIyeYTo5W7bBLcel69wHo9YT1H8W5kZeRp2s/2EFNf9hhamWfgwzqJ2TqnAri
         R1Lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IRJ3kHRWOZ6Oa/wZZvzUAN7hy8bsQmwl1E7zLBkE46k=;
        b=iM3FAa+rBCO7QSELYxIAaph6AD1kN/0y5hwdZ7fKJ8AXxHcOBbQJCsvJpNftBg6SdA
         dDX7IAeIKB92HAnPVwCK5cO6ZD5Be6MkFvsNWhhjmUNolws83aDl7GhPDLjzhrjWyZ4S
         c8c4RddATRwLsjKSf2wTOh73d3aMj+EXpImakqc9Wy0zh4VtQFUPH9F2rrpFkjQn9rr0
         Fd1F7hRcC64b77ht7WeHbaNIouHa2LcQrIf7nZBnPjV8lsbB6DNP+1y37MHpT5rfBZpS
         s7mwiMF0xBjmVURlt84qyrk7gNE48uVj7NH4YdwMJQjp7rbEh4PpfurBdP+6GjFwsi92
         XTDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=II0x1Qlt;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x189sor5991891iof.129.2019.07.11.18.47.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jul 2019 18:47:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=II0x1Qlt;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IRJ3kHRWOZ6Oa/wZZvzUAN7hy8bsQmwl1E7zLBkE46k=;
        b=II0x1QltVBuMzYD3RNaHDe+2L0p4lYgtQgxxcoUNASYf93aT9Js9DXm5Z4MLEcoxjd
         VjtjVOmRI6DCAjUYaXkkGYSAnta+kPn8eZ30hLriIgQaI8425xmI6AweQRTZzS3szmU7
         2FzaV2xo9Jl1xBD2TFV2aVXpViuxHO93e6/MZNlAZMkGwwQZl8xdMfN8wUtWoK5hiqA9
         3h8atkkR/7q1YoKjj07UstxRTYL3qO2Xbj8PARRreXyMJDv9NkPQrRDIzaqPevXyG6VP
         pyA1nvFiw/5/GIzcgVUdAO/lCVt7l2QniPrdy/D443Ga3hzCKXKrPvRBaExKjspyNczL
         x4Rw==
X-Google-Smtp-Source: APXvYqxsdJdBsHucJgwLZsRovdj5hZWk/eQOMWlof4n1CohnPFS7L9Jjkrm0Kpk5L6sUEzEWBNHTNmWEBgCnFZCelJE=
X-Received: by 2002:a6b:5115:: with SMTP id f21mr8033905iob.173.1562896070622;
 Thu, 11 Jul 2019 18:47:50 -0700 (PDT)
MIME-Version: 1.0
References: <1562851979-10610-1-git-send-email-laoar.shao@gmail.com> <20190711164215.7e8fdcf635ac29f2d2572438@linux-foundation.org>
In-Reply-To: <20190711164215.7e8fdcf635ac29f2d2572438@linux-foundation.org>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 12 Jul 2019 09:47:14 +0800
Message-ID: <CALOAHbDC+JWaXfMwG97PEsEB4f0vRkx7JsDRN8m47x1DMVuuFg@mail.gmail.com>
Subject: Re: [PATCH v2] mm/memcontrol: keep local VM counters in sync with the
 hierarchical ones
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 7:42 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Thu, 11 Jul 2019 09:32:59 -0400 Yafang Shao <laoar.shao@gmail.com> wrote:
>
> > After commit 815744d75152 ("mm: memcontrol: don't batch updates of local VM stats and events"),
> > the local VM counters is not in sync with the hierarchical ones.
> >
> > Bellow is one example in a leaf memcg on my server (with 8 CPUs),
> >       inactive_file 3567570944
> >       total_inactive_file 3568029696
> > We can find that the deviation is very great, that is because the 'val' in
> > __mod_memcg_state() is in pages while the effective value in
> > memcg_stat_show() is in bytes.
> > So the maximum of this deviation between local VM stats and total VM
> > stats can be (32 * number_of_cpu * PAGE_SIZE), that may be an unacceptable
> > great value.
> >
> > We should keep the local VM stats in sync with the total stats.
> > In order to keep this behavior the same across counters, this patch updates
> > __mod_lruvec_state() and __count_memcg_events() as well.
>
> hm.
>
> So the local counters are presently more accurate than the hierarchical
> ones because the hierarchical counters use batching.  And the proposal
> is to make the local counters less accurate so that the inaccuracies
> will match.
>
> It is a bit counter intuitive to hear than worsened accuracy is a good
> thing!  We're told that the difference may be "unacceptably great" but
> we aren't told why.  Some additional information to support this
> surprising assertion would be useful, please.  What are the use-cases
> which are harmed by this difference and how are they harmed?
>

Hi Andrew,

Both local counter and the hierachical one are exposed to user.
In a leaf memcg, the local counter should be equal with the hierarchical one,
if they are different, the user may wondering what's wrong in this memcg.
IOW, the difference makes these counters not reliable, if they are not
reliable we can't use them to help us anylze issues.
Another method is making the hierachical counter as accurate as the
local one, but that will consume more CPU cycles,
because we have to calculate all the descendants' counter, that may
not scalable as some counters are in the critical path.


> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -691,12 +691,15 @@ void __mod_memcg_state(struct mem_cgroup *memcg, int idx, int val)
> >       if (mem_cgroup_disabled())
> >               return;
> >
> > -     __this_cpu_add(memcg->vmstats_local->stat[idx], val);
> > -
> >       x = val + __this_cpu_read(memcg->vmstats_percpu->stat[idx]);
> >       if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
> >               struct mem_cgroup *mi;
> >
> > +             /*
> > +              * Batch local counters to keep them in sync with
> > +              * the hierarchical ones.
> > +              */
> > +             __this_cpu_add(memcg->vmstats_local->stat[idx], x);
>
> Given that we are no longer batching updates to the local counters, I
> wonder if it is still necessary to accumulate the counters on a per-cpu
> basis.  ie, can we now do
>
>                 atomic_long_add(memcg->vmstats_local->stat[idx], x);
>
> and remove the loop in memcg_events_local()?
>
As explained in the commit 815744d75152, that may cause performance
hit by bouncing the additional cachelines
from the new hierarchical statistics counters.

Thanks
Yafang

