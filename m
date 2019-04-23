Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E596C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 18:26:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC9BD208E4
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 18:26:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="J7VF7hk4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC9BD208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 618D26B0007; Tue, 23 Apr 2019 14:26:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C8476B0008; Tue, 23 Apr 2019 14:26:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 506726B000A; Tue, 23 Apr 2019 14:26:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30EDE6B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 14:26:54 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id t18so9538213qtr.8
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:26:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=OtqIojgBZWLcL030ijYokkgA69/5WMe/h5HYfs6VoxY=;
        b=rrcETJNsDuE8tqXNiBhVehrAJZVCx7MiLUkl+I28rL31kAJygshiZZwNHVa+76V9bA
         3zhYC761kjl4B1dCjsa+mp6gnZdxlTRCWNvKYdrL5cVbFN2tmzN3Xjpa9+bHM2F7Lbfl
         7HLdntqJUcss9lwKRDqnhB4/pmcxuQL2GckP4iEC92IyXsThCYkvCq1tOgx2VjSu71bC
         zmb94UbJz2E2N2KrLqjZJzBbZ2DpW53o5Vt3sKJne5c6CO59GJzDVjGOP4b2PxlH4GKw
         EMHqANNfOIIEa0wAWyZnBDXxhFXRAbUI1Irt4xV9v4/MJaGBYQGm2s79OqptCAlmB44P
         F8Ig==
X-Gm-Message-State: APjAAAXM2Mg28YIVtlyFVdcB5AozXGfrEu6HDUacuZpaIdg3g8Ul4GTC
	xGgQjQhfys87Ic/8uuk99OwJCRs4oHonZFYAe/Pd8KnSNsziPrbPeKtbmNWdQKafs6qW+2dn/mf
	ir9fTvTNkepQLBfbkaZtMNoWjg3jMMNnjsu04h5yJfKAAARwydFuXAfY0tQCnQvNqug==
X-Received: by 2002:a05:620a:1214:: with SMTP id u20mr20279727qkj.254.1556044013866;
        Tue, 23 Apr 2019 11:26:53 -0700 (PDT)
X-Received: by 2002:a05:620a:1214:: with SMTP id u20mr20279666qkj.254.1556044013022;
        Tue, 23 Apr 2019 11:26:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556044013; cv=none;
        d=google.com; s=arc-20160816;
        b=uvo1e4aSJTjv82DBzyZkpN/LJRFcocIdyiVkXkl0fIqeFTCkRoKdfX5I7PMfZ+Ung/
         /zsbKGAU01OXztWFckztfvNlhIUJFA8WyBSme/1jI5OKZbgufrTyp2PFm+HTzf5Gw3p6
         1VmwBsEoEHZqZPFXQ9BsK8hYi7dG4jROcoZmrrqX6uVTqygfwFLqAgfItQu7dXS5MkOG
         WK/vv8n2CXZji28br48JTHMkZA0XSwi+90cfbr961xrIGMuTI3zxhKApC5VA26hRrYq/
         4eOfh+YZmrTibLK2+ot1q58nwR0CkKA+BuCxVKGIasrBbbqzl5umwqKckOVB/SJqt87x
         rxLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=OtqIojgBZWLcL030ijYokkgA69/5WMe/h5HYfs6VoxY=;
        b=bR02JJbBqKQOej1lKGFHx6PxeiFh8hJkHVU7hOKxrJfDG0/PnCvpq0qpQ8nYF8IVB2
         xA8ENsIbFdc/uK19J8k6jJIzyG2Iu1U+wHLVBsBVDS9lR88H1sLwq8jBvqpgCSDngeqr
         o5ln78/CnjQvdJRFC+6H1SyU/lt+X/JKIJ8Rc/P0xDwhdON2bVCUiXtdO5DuN2fn2zh/
         LlMFyF1Aw/eH9thhitNxeKbfJOitrXjesJRqafROgbX+6Jh1+LHmwn/kcnUrb1IlInM5
         EidVsT8z3PVSuuZSEGpxPQpj6wUiE5DXWQZc+Gv4pTS8WtTuA30FKm+lPRNnHSR4iTW2
         rcNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=J7VF7hk4;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 24sor13682157qtp.57.2019.04.23.11.26.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 11:26:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=J7VF7hk4;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=OtqIojgBZWLcL030ijYokkgA69/5WMe/h5HYfs6VoxY=;
        b=J7VF7hk4wa/wc+DUocIPySCQ9HByKlvDs8RDH/GXUdjG7gy7yC3ztAdkbhajUAT3Wy
         K34I8knTed+VrFeFXscJPYD52D5aSMM6tSHAHh5LvDd/TDncVkn+GAyi40UUyEK/VmQo
         Kiw/VfdMRj/+7mTi6lErb3Yfxbgogq6UMWGVSXkXfu2BYrfzRsMK5BfSkaxhsm96p+gu
         NmJJAQabhf6Y9haViQvKmRVQX00wogJt+dVOcRoR+6iXoRve8DI5fiNnIKYQpu1UAW0J
         1gFOA2Slh7nE/GE6eE39ofEGt3bQZNV3eMQy8hRfQ5/f1AsSOJ72EiRqhQvpCK8jbKno
         gzpw==
X-Google-Smtp-Source: APXvYqxqedtS93enduv8kH3z4axRKMXqvrUZ4LSHl4bW7NE/Zy5h9InJQED80QRwfbvkbfjCuaZg1kISic9jmTEyB3M=
X-Received: by 2002:ac8:16c1:: with SMTP id y1mr7325475qtk.369.1556044012738;
 Tue, 23 Apr 2019 11:26:52 -0700 (PDT)
MIME-Version: 1.0
References: <CALvZod4V+56pZbPkFDYO3+60Xr0_ZjiSgrfJKs_=Bd4AjdvFzA@mail.gmail.com>
 <20190423155827.GR18914@techsingularity.net> <CALvZod7-_RgMiA-X2MdmrizWiPf3L4CtJdcbCFWiy9ZDFEc+Sw@mail.gmail.com>
 <CAHbLzkp1HY0+x6ug8d43rpyQZqB9-Vh_vgbVF5-pcM=3FVVsWA@mail.gmail.com> <CALvZod5X7d38BO4byaWaKScibsJJPEj8KZx6t5Od1EXRvn_aOg@mail.gmail.com>
In-Reply-To: <CALvZod5X7d38BO4byaWaKScibsJJPEj8KZx6t5Od1EXRvn_aOg@mail.gmail.com>
From: Yang Shi <shy828301@gmail.com>
Date: Tue, 23 Apr 2019 11:26:40 -0700
Message-ID: <CAHbLzkoLKs32u3_6a9XgtN3nrH-VVVv7pokFg60d2yG6XXi=9A@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Proactive Memory Reclaim
To: Shakeel Butt <shakeelb@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, lsf-pc@lists.linux-foundation.org, 
	Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Roman Gushchin <guro@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 10:12 AM Shakeel Butt <shakeelb@google.com> wrote:
>
> On Tue, Apr 23, 2019 at 9:50 AM Yang Shi <shy828301@gmail.com> wrote:
> >
> > Hi Shakeel,
> >
> > This sounds interesting. Actually, we have something similar designed
> > in-house (called "cold" page reclaim). But, we mainly targeted to cold
> > page cache rather than anonymous page for the time being, and it does
> > in cgroup scope. We are extending it to anonymous page now.
> >
> > Look forward to discussing with you.
> >
>
> Hi Yang,
>
> Thanks for the info. Is this per-cgroup "cold page reclaim" is
> triggered by the job themselves? Are the jobs trying to avoid memcg

No, it is triggered by admin or cluster management.

> limit reclaim by proactively reclaiming their own memory?

Yes, kind of. And, it also helps to avoid global direct reclaim.

>
> Shakeel

