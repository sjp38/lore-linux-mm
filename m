Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD31DC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 13:57:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 587002184E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 13:57:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bXNPB7zv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 587002184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E40006B0003; Wed, 20 Mar 2019 09:57:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC6526B0006; Wed, 20 Mar 2019 09:57:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8D326B0007; Wed, 20 Mar 2019 09:57:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id A49436B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 09:57:14 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id 186so2111784iox.15
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 06:57:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CvlQrhVNZGltu5KQzuGmLoTLALk87KzB9BrSGatvLTs=;
        b=IhukflzhvwmeSLEOYHygnZzneyz+6F0aqDRWLoS0BWpHOhRrWdhVaGzfXFBDm1uAxT
         4zTaLV5mXhE+3ulgdX7sDLpu8VqhjKHProXCyQZ7CAiRIeQz3FnrqcPAPb9Zi2UjZVLR
         ryhRKi6k7/HPDCbALWE12P2NXWeSredKhMYGBgxIFQbFSz3cCnxy2alAACjBRvVkEERK
         aSKCSny3Xb9lGdhYx1TfpWmgtuPnuB+7RFNKdY2f+2wDFZSLGem12vzDS6EeXAZvw30s
         dCVy4tj0Phm8bUDXx8z9/dK3r6lSTr5wfHizQ/BhQCb+aaiXeqF1EqEuViNGNmEadFi+
         LEcw==
X-Gm-Message-State: APjAAAWZmocS2gAF50AqsjQDcnU2uBcq/jtetCGD2nE3bLvqOHjUJoNO
	jdFsS5LdFhuW+Yng1PHHy+9KBMzlgqUalG75OFGPxPtz+4to5ZXrH9tG1tuYaIMNaie4iXDWi/I
	Xle3uFxJLXtetWrcLDTK0xQtv7/MBguRh/vqFV1oFSB/pyx2adVuhOQ/lDKb1h40t2Q==
X-Received: by 2002:a6b:d304:: with SMTP id s4mr4869720iob.228.1553090234394;
        Wed, 20 Mar 2019 06:57:14 -0700 (PDT)
X-Received: by 2002:a6b:d304:: with SMTP id s4mr4869692iob.228.1553090233656;
        Wed, 20 Mar 2019 06:57:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553090233; cv=none;
        d=google.com; s=arc-20160816;
        b=TSwk21gwQH0MULHm0Yn5HiUanGA0MacT15H6ZpoB69nGo5KcTuwUlITlWrT/1A7JZx
         q6+HAbrbKF88vld8kvGC8d+0CPxmDSWE8U1sHDtoWkpskX78U2WIg0IKlDToJdQcKj3F
         a8SFg70teMmZAdZqCb2azsu8nEncTzc78nEgAI3zO+1+0FFCf4nSr8kSCpK07kUAVXWn
         t/aWyrrT3Q7C6iufF6ODMuK4QF/4bcL/EBp53MqGT2hR3Jovd02fjynHGu6xPehmAb6e
         DodNBe81iccMcdvyOndFbTRuA2FtPep1QnZbScfnP54vXA7wNZTN6MWKnZ/JNTMkEEA0
         ScHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CvlQrhVNZGltu5KQzuGmLoTLALk87KzB9BrSGatvLTs=;
        b=eIgg8NI5mdnRDtNZdNojz1mLhL80l5Ttr2dyY95ryI38ya6IBqSioL2Vzg2EWKkB6M
         t1E7x4tkBiWkgFQGuCQ6wX7+5FCT8nGO1nWHPyGpm5cRbQ3eYgmwRJvKlXdjUNuQT2kV
         FOShl6UQM/yUrCDd6UbW/2Tmj7GHnbpP+qwtvABheWbF7pDIcoiu5SmIxFHYYLXq88Tc
         6lLMFDA4ujaDQeJ4/WioLYWrFUaePL6a4RYKPoZClX3S8ddDskbAbOpuFJ9RDVC4R4mm
         vH0C33Sie/i/IxvrULAITqQ/FpLXstcm0VVoAt8lh3Zr1KfQRpRlbpezjgVb1PuCOVjj
         qyYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bXNPB7zv;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i71sor3964688iti.25.2019.03.20.06.57.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 06:57:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bXNPB7zv;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CvlQrhVNZGltu5KQzuGmLoTLALk87KzB9BrSGatvLTs=;
        b=bXNPB7zvPkRgcOAPSdlMSVdFMXKiD4p7E6PFK0UazdmwlGIGsVM969QA2CwMUo9N/n
         obbqOhB4/UpqWlegShtLyImJKsquRqfqgO39N7IbLXzxPbDy8K2PHAEsF0DUssKOXnBv
         sIxvubYhUf3W0NnOugvcVe0dFeNe1YUUwBj9/Yk8QATccjDtqjdO7mswCld32ebhE9Qp
         jjUFJ9PKczP385NR7ngZkXQ8DDGhEY5BMwvCP1GiWitdUjoOsduwk70+ykWyV2D5RmjK
         46vSp82W0e+1OlkPxUcisjVLwQd47j0ICHede79NSGhjSLBJoDTCC8SEqY0VVOqMJYGm
         29Nw==
X-Google-Smtp-Source: APXvYqxdt1A/jMZrV2buAz0e10n701wfuyKaiMQX4b+XZS0YUErmcrU9kOjXrZFjlWOddN3qBDNvx1aBg+c6+Gk2/38=
X-Received: by 2002:a24:3b01:: with SMTP id c1mr4319010ita.144.1553090233000;
 Wed, 20 Mar 2019 06:57:13 -0700 (PDT)
MIME-Version: 1.0
References: <000000000000db3d130584506672@google.com> <d9e4e36d-1e7a-caaf-f96e-b05592405b5f@virtuozzo.com>
 <CACT4Y+Zj=35t2djhKoq+e1SH3Zu3389Pns7xX6MiMWZ=PFpShA@mail.gmail.com>
 <426293c3-bf63-88ad-06fb-83927ab0d7c0@I-love.SAKURA.ne.jp>
 <CACT4Y+Zh8eA50egLquE4LPffTCmF+30QR0pKTpuz_FpzsXVmZg@mail.gmail.com> <315c8ff3-fd03-f2ca-c546-ca7dc5c14669@virtuozzo.com>
In-Reply-To: <315c8ff3-fd03-f2ca-c546-ca7dc5c14669@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 20 Mar 2019 14:57:01 +0100
Message-ID: <CACT4Y+axojyHxk5K34YuLUyj+NJ05+FC3n8ozseHC91B1qn5ZQ@mail.gmail.com>
Subject: Re: kernel panic: corrupted stack end in wb_workfn
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
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

On Wed, Mar 20, 2019 at 2:33 PM Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>
>
>
> On 3/20/19 1:38 PM, Dmitry Vyukov wrote:
> > On Wed, Mar 20, 2019 at 11:24 AM Tetsuo Handa
> > <penguin-kernel@i-love.sakura.ne.jp> wrote:
> >>
> >> On 2019/03/20 18:59, Dmitry Vyukov wrote:
> >>>> From bisection log:
> >>>>
> >>>>         testing release v4.17
> >>>>         testing commit 29dcea88779c856c7dc92040a0c01233263101d4 with gcc (GCC) 8.1.0
> >>>>         run #0: crashed: kernel panic: corrupted stack end in wb_workfn
> >>>>         run #1: crashed: kernel panic: corrupted stack end in worker_thread
> >>>>         run #2: crashed: kernel panic: Out of memory and no killable processes...
> >>>>         run #3: crashed: kernel panic: corrupted stack end in wb_workfn
> >>>>         run #4: crashed: kernel panic: corrupted stack end in wb_workfn
> >>>>         run #5: crashed: kernel panic: corrupted stack end in wb_workfn
> >>>>         run #6: crashed: kernel panic: corrupted stack end in wb_workfn
> >>>>         run #7: crashed: kernel panic: corrupted stack end in wb_workfn
> >>>>         run #8: crashed: kernel panic: Out of memory and no killable processes...
> >>>>         run #9: crashed: kernel panic: corrupted stack end in wb_workfn
> >>>>         testing release v4.16
> >>>>         testing commit 0adb32858b0bddf4ada5f364a84ed60b196dbcda with gcc (GCC) 8.1.0
> >>>>         run #0: OK
> >>>>         run #1: OK
> >>>>         run #2: OK
> >>>>         run #3: OK
> >>>>         run #4: OK
> >>>>         run #5: crashed: kernel panic: Out of memory and no killable processes...
> >>>>         run #6: OK
> >>>>         run #7: crashed: kernel panic: Out of memory and no killable processes...
> >>>>         run #8: OK
> >>>>         run #9: OK
> >>>>         testing release v4.15
> >>>>         testing commit d8a5b80568a9cb66810e75b182018e9edb68e8ff with gcc (GCC) 8.1.0
> >>>>         all runs: OK
> >>>>         # git bisect start v4.16 v4.15
> >>>>
> >>>> Why bisect started between 4.16 4.15 instead of 4.17 4.16?
> >>>
> >>> Because 4.16 was still crashing and 4.15 was not crashing. 4.15..4.16
> >>> looks like the right range, no?
> >>
> >> No, syzbot should bisect between 4.16 and 4.17 regarding this bug, for
> >> "Stack corruption" can't manifest as "Out of memory and no killable processes".
> >>
> >> "kernel panic: Out of memory and no killable processes..." is completely
> >> unrelated to "kernel panic: corrupted stack end in wb_workfn".
> >
> >
> > Do you think this predicate is possible to code?
>
> Something like bellow probably would work better than current behavior.
>
> For starters, is_duplicates() might just compare 'crash' title with 'target_crash' title and its duplicates titles.

Lots of bugs (half?) manifest differently. On top of this, titles
change as we go back in history. On top of this, if we see a different
bug, it does not mean that the original bug is also not there.
This will sure solve some subset of cases better then the current
logic. But I feel that that subset is smaller then what the current
logic solves.

> syzbot has some knowledge about duplicates with different crash titles when people use "syz dup" command.

This is very limited set of info. And in the end I think we've seen
all bug types being duped on all other bugs types pair-wise, and at
the same time we've seen all bug types being not dups to all other bug
types. So I don't see where this gets us.
And again as we go back in history all these titles change.

> Also it might be worth to experiment with using neural networks to identify duplicates.
>
>
> target_crash = 'kernel panic: corrupted stack end in wb_workfn'
> test commit:
>         bad = false;
>         skip = true;
>         foreach run:
>                 run_started, crashed, crash := run_repro();
>
>                 //kernel built, booted, reproducer launched successfully
>                 if (run_started)
>                         skip = false;
>                 if (crashed && is_duplicates(crash, target_crash))
>                         bad = true;
>
>         if (skip)
>                 git bisect skip;
>         else if (bad)
>                 git bisect bad;
>         else
>                 git bisect good;

