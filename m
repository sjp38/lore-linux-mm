Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84780C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 09:59:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3040D2184E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 09:59:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="JYDMbaf0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3040D2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCFB26B0003; Wed, 20 Mar 2019 05:59:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7EE36B0006; Wed, 20 Mar 2019 05:59:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6CFE6B0007; Wed, 20 Mar 2019 05:59:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5986B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 05:59:22 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id c2so1510922ioh.11
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 02:59:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=s2voj6kjaLi6fKovfCR/88xY1mnaSXnV0VQQW9aYLas=;
        b=tyE/L7CZBP20KKibLvaMm5R/uaOqI+DDcY/PFFFUmeY5gkdkStZcL8PcJkJV9tCJr4
         JOrfTcwQInDWP1pLKsN803S5uhRx6dho0Y4Rm0CIMBmgr3mDRi5ATxWs0rc4dd0+HQDq
         I1zaWfhmRd8UV0niouCROSkuyjZbAtlStRs0iRBjGDLmDhW6mFXo6cE8YD4K7a0hoNR7
         3O+Y57oNxjeIYahboDlsmjDw9POx5fFzRwSH2jax602yPl65/ECkzUProghswKnlAucM
         sI2Y2EqxW+x13z5/I/QnF3sYPcEBjLxtv5G0drj5A074STONxGcESE3AxPQ32rU7oaT9
         PWNg==
X-Gm-Message-State: APjAAAWs60THhgdCmYjVKqmDP3WgJziojnFSSKn3oV1bFQeua4yS4Dhg
	R0BMcteK/epCKp64kBaEfodwZ4AKVPUWKWOQQruqZAmidh3e8erFMIfojOu1BEVOXvgkjgnwyS9
	e2k45AETssYuwDroqe6aRBntaeu8NB/PSaJfyXMOR8vlRf5RmiX/N8gNDTKS/LnEoTA==
X-Received: by 2002:a02:a399:: with SMTP id y25mr4637073jak.58.1553075962409;
        Wed, 20 Mar 2019 02:59:22 -0700 (PDT)
X-Received: by 2002:a02:a399:: with SMTP id y25mr4637050jak.58.1553075961703;
        Wed, 20 Mar 2019 02:59:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553075961; cv=none;
        d=google.com; s=arc-20160816;
        b=Xwu7lwAXcJttxt0cfaNdqlcy75bRA//EgYzpX0PsFZK6L/S1MTiZEhoABAeZ4ejpfN
         iqZvqQcXbC1qww1mw8SDihInKN/DMX2SPu7mOseEi04CKxVzHsfhUyQalwTnzIK80MWk
         dCP1gfbCZwX3r5luz9zkEqd9bLEUYwoFVWECpUggKU+nFJoPLgE2QliZVC6dP1ZsbXIx
         sZijyMl3FeS2hVGEfD17MXd5xuuc0Q5AmNL/JRBjndCijGRRWq0ALlgdLRQ92HMVyGMe
         JNOIHbi08scou6hv0okMyIwZJim4rutoNcIIHsdLR2baX5pKiwTNu/DeAVaBibqKKuOK
         g2Vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=s2voj6kjaLi6fKovfCR/88xY1mnaSXnV0VQQW9aYLas=;
        b=z/HlepqhGbwNCN5/eCgW5mjIeFt44L70KNvoWQooA+NDO0aW5b4A2xUWnLzAghibmG
         Vr2T89UFso5JJ0UkmC2LOc9yHOIrwIguGgd+WyovNTzuqzDOAuh5KQSAvkxlCtS5AbyJ
         +R/iyUeMXKAdPHr6NC01fvAPtgKdMah6IOjYD+J8gF2pkdigKKugSpaqMdYfy7Vq2One
         3mOjp0dM5BHCWSGTkS+t8+pDe1bDOVvYHMlCNWjSmewzbzGqtLnlAIdccEDeNqUAzNW/
         38wldStav7LGoYcp+B+cickAMo/dcoF4KWHvOGcyGhSNOWbbWMbBRhazlxG+c9Rqqixc
         Au4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JYDMbaf0;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o9sor4543573jam.6.2019.03.20.02.59.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 02:59:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JYDMbaf0;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=s2voj6kjaLi6fKovfCR/88xY1mnaSXnV0VQQW9aYLas=;
        b=JYDMbaf0YUF3eOTaoaFwUe3CxvxxMo7gejjtbDw95GMO9vUIsR2u4jhbxb/8nQ0fy6
         m6wn+rcYWlW6YHJoSOyz7Uu9aTKGqXNqqFU4zf7N1SmOgxrDGfHoQ6UR6uU9EEU8EeyG
         zFbxfCNX6lr3uAZ8X4mfsdaj1z7cTD2wl+WP/5kWf5g5c7IUOHtTCuUbNRj+rAgCHXWI
         /lR62pUrei+SwFhBxmHZG6HNaaCZVtlq3bQf6Mk7Zf1QoT+1TxUFo90O2RLX3kVXUzEA
         b6phamX/1j02VTV4LGuMZQQuc35jaIE34WG6kQOYNEXk1R88iO+L6KAWgq9xE8c9KTjn
         qCwQ==
X-Google-Smtp-Source: APXvYqyq3qgpYQBtHCrpio74vOfqV9roX8R/fvAEM9gdqE0d/5SmhT4xZ4ZXx0J15TTgRIGJ9xKgFwo+wZYUVtGwSbc=
X-Received: by 2002:a02:84ab:: with SMTP id f40mr4094497jai.72.1553075961022;
 Wed, 20 Mar 2019 02:59:21 -0700 (PDT)
MIME-Version: 1.0
References: <000000000000db3d130584506672@google.com> <d9e4e36d-1e7a-caaf-f96e-b05592405b5f@virtuozzo.com>
In-Reply-To: <d9e4e36d-1e7a-caaf-f96e-b05592405b5f@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 20 Mar 2019 10:59:09 +0100
Message-ID: <CACT4Y+Zj=35t2djhKoq+e1SH3Zu3389Pns7xX6MiMWZ=PFpShA@mail.gmail.com>
Subject: Re: kernel panic: corrupted stack end in wb_workfn
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: syzbot <syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com>, 
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

On Wed, Mar 20, 2019 at 10:56 AM Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
> On 3/17/19 11:49 PM, syzbot wrote:
> > syzbot has bisected this bug to:
> >
> > commit c981f254cc82f50f8cb864ce6432097b23195b9c
> > Author: Al Viro <viro@zeniv.linux.org.uk>
> > Date:   Sun Jan 7 18:19:09 2018 +0000
> >
> >     sctp: use vmemdup_user() rather than badly open-coding memdup_user()
> >
> > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=137bcecf200000
> > start commit:   c981f254 sctp: use vmemdup_user() rather than badly open-c..
> > git tree:       upstream
> > final crash:    https://syzkaller.appspot.com/x/report.txt?x=10fbcecf200000
> > console output: https://syzkaller.appspot.com/x/log.txt?x=177bcecf200000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=5e7dc790609552d7
> > dashboard link: https://syzkaller.appspot.com/bug?extid=ec1b7575afef85a0e5ca
> > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=16a9a84b400000
> > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17199bb3400000
> >
> > Reported-by: syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com
> > Fixes: c981f254 ("sctp: use vmemdup_user() rather than badly open-coding memdup_user()")
>
> From bisection log:
>
>         testing release v4.17
>         testing commit 29dcea88779c856c7dc92040a0c01233263101d4 with gcc (GCC) 8.1.0
>         run #0: crashed: kernel panic: corrupted stack end in wb_workfn
>         run #1: crashed: kernel panic: corrupted stack end in worker_thread
>         run #2: crashed: kernel panic: Out of memory and no killable processes...
>         run #3: crashed: kernel panic: corrupted stack end in wb_workfn
>         run #4: crashed: kernel panic: corrupted stack end in wb_workfn
>         run #5: crashed: kernel panic: corrupted stack end in wb_workfn
>         run #6: crashed: kernel panic: corrupted stack end in wb_workfn
>         run #7: crashed: kernel panic: corrupted stack end in wb_workfn
>         run #8: crashed: kernel panic: Out of memory and no killable processes...
>         run #9: crashed: kernel panic: corrupted stack end in wb_workfn
>         testing release v4.16
>         testing commit 0adb32858b0bddf4ada5f364a84ed60b196dbcda with gcc (GCC) 8.1.0
>         run #0: OK
>         run #1: OK
>         run #2: OK
>         run #3: OK
>         run #4: OK
>         run #5: crashed: kernel panic: Out of memory and no killable processes...
>         run #6: OK
>         run #7: crashed: kernel panic: Out of memory and no killable processes...
>         run #8: OK
>         run #9: OK
>         testing release v4.15
>         testing commit d8a5b80568a9cb66810e75b182018e9edb68e8ff with gcc (GCC) 8.1.0
>         all runs: OK
>         # git bisect start v4.16 v4.15
>
> Why bisect started between 4.16 4.15 instead of 4.17 4.16?

Because 4.16 was still crashing and 4.15 was not crashing. 4.15..4.16
looks like the right range, no?


>         testing commit c14376de3a1befa70d9811ca2872d47367b48767 with gcc (GCC) 8.1.0
>         run #0: crashed: kernel panic: Out of memory and no killable processes...
>         run #1: crashed: kernel panic: Out of memory and no killable processes...
>         run #2: crashed: kernel panic: Out of memory and no killable processes...
>         run #3: crashed: kernel panic: Out of memory and no killable processes...
>         run #4: OK
>         run #5: OK
>         run #6: crashed: WARNING: ODEBUG bug in netdev_freemem
>         run #7: crashed: no output from test machine
>         run #8: OK
>         run #9: OK
>         # git bisect bad c14376de3a1befa70d9811ca2872d47367b48767
>
> Why c14376de3a1befa70d9811ca2872d47367b48767 is bad? There was no stack corruption.
> It looks like the syzbot were bisecting a different bug - "kernel panic: Out of memory and no killable processes..."
> And bisection for that bug seems to be correct. kvmalloc() in vmemdup_user() may eat up all memory unlike kmalloc which is limited by KMALLOC_MAX_SIZE (4MB usually).

Please see https://github.com/google/syzkaller/blob/master/docs/syzbot.md#bisection
for answer.

