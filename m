Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FBCAC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 10:38:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E01EB21871
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 10:38:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="QJ0Hixfu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E01EB21871
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AA936B0003; Wed, 20 Mar 2019 06:38:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75BA66B0006; Wed, 20 Mar 2019 06:38:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6486D6B0007; Wed, 20 Mar 2019 06:38:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6786B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 06:38:33 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id y6so1858330itj.5
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:38:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jmTWTsjVde8Buo2u+HYWbLOnOnpUNQfeTfb58oufkzI=;
        b=p+czPZsi0ej6qIqSBC6e5Rbw3LO2mkXfLE454Q1O2DdofDwbau/0hErpRF2rtA/5XQ
         EmbbsDit8/kffjVUse+5gey/7MzoOTtDdx/WGhEECauUo+4ywkplbPQhSjhqK6KjHm5+
         oTwc6MnsWDeafcoGllRJGvDMO2+2ZAPGmcEkg9QUdTsd5VjTIlYvQjCW2qxOxhifjBMy
         F2taQ9KsyAeQ4zkeg6gS1TP5gaX2vRGtMCH+HqoMgpRX0y/BC0ZgHiS8/RTr51sO7Jmz
         opJsIEGLcAHOFPGPIZtdFWenfmQVyC9GS4XLTH/LRezRw+dc4xV86H+UELMnodVT24CB
         5uGg==
X-Gm-Message-State: APjAAAUKA5w/TmFZe6QEu60JglD4ItFEQEa+ugh/jEtxq3M2h0DDug3c
	t9Ce+BRLzfsVkPoK8e+SiLoblY3OvNFItNpVKrSb47B3njjKNuBOwMd7EpHjHAzO47axKyGmY28
	aKuNAHrYOu+JqWvA2qwofIjPo4d18qsd144P/ehEmsY7qKxbivgFncqGoTv3umUJpfg==
X-Received: by 2002:a5e:981a:: with SMTP id s26mr5076394ioj.90.1553078312895;
        Wed, 20 Mar 2019 03:38:32 -0700 (PDT)
X-Received: by 2002:a5e:981a:: with SMTP id s26mr5076360ioj.90.1553078312214;
        Wed, 20 Mar 2019 03:38:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553078312; cv=none;
        d=google.com; s=arc-20160816;
        b=dCJVTYFWD/EViz5Ur5oPx0XjZGThgxO6ziu6r0x0yaViKXsxY3Ar0m7SFf9aAMvYIN
         Xq7FsmjODnQE6qG9jHVTqUOAK1LYHeSG4dt1qfbccg7UNYOYK0OzE55M2t71l8PDrw8v
         UQFXyNW9P5+IpK+UcK3mhPLx4Gk8VJDnEcRam/hJ1JE9IaroX0VfVkmOrWpGFiKHWm0R
         OfEy36W3X2UHEYDXV8y2H8w1XJgs0blHfrXCMD3U1YiKQe7VHIBMWG4OHPjhvWeZupzj
         cKD9a/ooILlPSzs6EZcbeDyezCPBZLVso79dHBdbh4vS9pK1nb9speIwHv+TC3mOiWJk
         /RCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jmTWTsjVde8Buo2u+HYWbLOnOnpUNQfeTfb58oufkzI=;
        b=hVwRQoY8OHG/7xuptu0BglxUxS+AoBlTdqHMQEfkaKGz6pZgcEKcw0XoAE3W0qLgV/
         A8DtGQEOG+g33clp/NSN+uBzJxZ49cber5hX1O6OFUufGHnfryoXmpBYHeagblQ9NaAo
         uQ6ugupY329psLqNMvUg4obHcoKymFSizzBfsnKWpGtSpZ1EbNkQCe/ULnsBY0XdV4EB
         E1vxM5QjFJ5G6Spe/ChMYyeMIo7lYqA5eEJghDql1FsS6ImRS86GlXSpPJbzJkpdsRqh
         xR0vA7sl0lnH1Ob/eyKMMrl71CpIfTtmyaNLbcw5+CV0pRWlPJ5nf9dgsHZCfjx7jY/K
         rL3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QJ0Hixfu;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v62sor4726503jaa.10.2019.03.20.03.38.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 03:38:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QJ0Hixfu;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jmTWTsjVde8Buo2u+HYWbLOnOnpUNQfeTfb58oufkzI=;
        b=QJ0Hixfu5hcP+OFD1pi83mFWhFYFQQSuLAY5azSzK1Z0hCoctBQFEUwJ3f+Y/VGYEs
         3PrcLIjfbZB1UJki9W2oG8Yvj7/3C8jMjCHX8G7+CvIhafbtBJUq/RVj7VtbdIQlLxyv
         IyabyWBUzqVe8JITAbfCLJ8ln9FqUkgcwKaXhMwHvHpGMR0AUoCE0zClrsX7pJPc2LOP
         Y7bIuhc4F9jTAxR/SGC2rNDbUNXrPorOtIJoaoQgmOaIs+INa7CDUpL7zCU/HQOuCrmt
         9UYNEZvjD7PjjoK7qcv0p5ONx5+qNWVQSKus6VlZjbyYmKVSreGt8Gpn5cVtS0uiOJBe
         sbIA==
X-Google-Smtp-Source: APXvYqy33umIL3MTXjGhjlwdTvUuLGhoU88o0cygKpqVUozi+RPmVzBEzCyLcYDMDt639xeDV//bSwRJbj7diqKadhU=
X-Received: by 2002:a05:6638:211:: with SMTP id e17mr3466378jaq.35.1553078311470;
 Wed, 20 Mar 2019 03:38:31 -0700 (PDT)
MIME-Version: 1.0
References: <000000000000db3d130584506672@google.com> <d9e4e36d-1e7a-caaf-f96e-b05592405b5f@virtuozzo.com>
 <CACT4Y+Zj=35t2djhKoq+e1SH3Zu3389Pns7xX6MiMWZ=PFpShA@mail.gmail.com> <426293c3-bf63-88ad-06fb-83927ab0d7c0@I-love.SAKURA.ne.jp>
In-Reply-To: <426293c3-bf63-88ad-06fb-83927ab0d7c0@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 20 Mar 2019 11:38:20 +0100
Message-ID: <CACT4Y+Zh8eA50egLquE4LPffTCmF+30QR0pKTpuz_FpzsXVmZg@mail.gmail.com>
Subject: Re: kernel panic: corrupted stack end in wb_workfn
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	syzbot <syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Qian Cai <cai@lca.pw>, 
	David Miller <davem@davemloft.net>, guro@fb.com, Johannes Weiner <hannes@cmpxchg.org>, 
	Josef Bacik <jbacik@fb.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-sctp@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, 
	Michal Hocko <mhocko@suse.com>, netdev <netdev@vger.kernel.org>, 
	Neil Horman <nhorman@tuxdriver.com>, Shakeel Butt <shakeelb@google.com>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Al Viro <viro@zeniv.linux.org.uk>, 
	Vladislav Yasevich <vyasevich@gmail.com>, Matthew Wilcox <willy@infradead.org>, 
	Xin Long <lucien.xin@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 11:24 AM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2019/03/20 18:59, Dmitry Vyukov wrote:
> >> From bisection log:
> >>
> >>         testing release v4.17
> >>         testing commit 29dcea88779c856c7dc92040a0c01233263101d4 with gcc (GCC) 8.1.0
> >>         run #0: crashed: kernel panic: corrupted stack end in wb_workfn
> >>         run #1: crashed: kernel panic: corrupted stack end in worker_thread
> >>         run #2: crashed: kernel panic: Out of memory and no killable processes...
> >>         run #3: crashed: kernel panic: corrupted stack end in wb_workfn
> >>         run #4: crashed: kernel panic: corrupted stack end in wb_workfn
> >>         run #5: crashed: kernel panic: corrupted stack end in wb_workfn
> >>         run #6: crashed: kernel panic: corrupted stack end in wb_workfn
> >>         run #7: crashed: kernel panic: corrupted stack end in wb_workfn
> >>         run #8: crashed: kernel panic: Out of memory and no killable processes...
> >>         run #9: crashed: kernel panic: corrupted stack end in wb_workfn
> >>         testing release v4.16
> >>         testing commit 0adb32858b0bddf4ada5f364a84ed60b196dbcda with gcc (GCC) 8.1.0
> >>         run #0: OK
> >>         run #1: OK
> >>         run #2: OK
> >>         run #3: OK
> >>         run #4: OK
> >>         run #5: crashed: kernel panic: Out of memory and no killable processes...
> >>         run #6: OK
> >>         run #7: crashed: kernel panic: Out of memory and no killable processes...
> >>         run #8: OK
> >>         run #9: OK
> >>         testing release v4.15
> >>         testing commit d8a5b80568a9cb66810e75b182018e9edb68e8ff with gcc (GCC) 8.1.0
> >>         all runs: OK
> >>         # git bisect start v4.16 v4.15
> >>
> >> Why bisect started between 4.16 4.15 instead of 4.17 4.16?
> >
> > Because 4.16 was still crashing and 4.15 was not crashing. 4.15..4.16
> > looks like the right range, no?
>
> No, syzbot should bisect between 4.16 and 4.17 regarding this bug, for
> "Stack corruption" can't manifest as "Out of memory and no killable processes".
>
> "kernel panic: Out of memory and no killable processes..." is completely
> unrelated to "kernel panic: corrupted stack end in wb_workfn".


Do you think this predicate is possible to code? Looking at the
examples we have, distinguishing different bugs does not look feasible
to me. If the predicate is not accurate, you just trade one set of
false positives to another set of false positives and then you at the
beginning of an infinite slippery slope refining it.
Also, if we see a different bug (assuming we can distinguish them),
does it mean that the original bug is not present? Or it's also
present, but we just hit the other one first? This also does not look
feasible to answer. And if you give a wrong answer, bisection goes the
wrong way and we are where we started. Just with more complex code and
things being even harder to explain to other people.
I mean, yes, I agree, kernel bug bisection won't be perfect. But do
you see anything actionable here?

