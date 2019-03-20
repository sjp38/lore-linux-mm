Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15B88C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 10:42:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B934F2184E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 10:42:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dCn/aejq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B934F2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 695EF6B0003; Wed, 20 Mar 2019 06:42:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6444B6B0006; Wed, 20 Mar 2019 06:42:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55C896B0007; Wed, 20 Mar 2019 06:42:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6116B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 06:42:49 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id j127so1766390itj.7
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:42:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hcRJyjpf1Os+dJaolVe49RgmT+5cszRgDCVwAxJ0n0o=;
        b=LRHeo+YiOq3GCpsixugeow+Kc80hsTDB1vHQ2coBSoa7+DxPGMLAQ0k8Pdka2lQmaA
         dW+hU4eLxnmXT4+zVxFs5dcdtJsNiQEfB20joT3t8vfAVUE9an98YA/52axpNxBKI8ui
         VRNZjpn7spKSb9kP2qS3cLPXlFY9zRjzAg5RcGdV9r3eo6r7MRXqYPqjRsQx8lCcqDqu
         qqv/GuR2yKIGcoOggxyYO82f2LqFyue8/WYANRqyV6uw6W+YZqgFVmjI/jKEgJWmgG3e
         MSN9j4EVsL1SFIMDM6LkPRI5Z/WTDSdiEO9rgukjN4HjfAlrS5LtvS0jCH1ZBK0kM9xI
         R/zg==
X-Gm-Message-State: APjAAAXZ9EfgzQtFJJPPVds8sb8FQN7ITRc5IlfoBYa0JTHigWj1ZSeN
	WCMlQDFbyn4gVl6zcSQrrgUHs5oLDWIRYvKmJ4eUO+yxZ+m6UVHx6gJNBriAT04Ajvll0Dhk/mE
	Cui2FkoE2+a0Zosl8DTxxTBy1iBBV4Zm3KqQvLy/1uGwlKIj5xo5r2M8Y1eawgJloJg==
X-Received: by 2002:a6b:15c5:: with SMTP id 188mr4864931iov.40.1553078568956;
        Wed, 20 Mar 2019 03:42:48 -0700 (PDT)
X-Received: by 2002:a6b:15c5:: with SMTP id 188mr4864903iov.40.1553078568250;
        Wed, 20 Mar 2019 03:42:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553078568; cv=none;
        d=google.com; s=arc-20160816;
        b=iBoMaV8JCSyJIkXSXzaL2ONEFogJiVrjR8RKUjhGHzAjEqzFku7X2U+eS6XsvQ71OQ
         KQ8ey1RA17kVL2K8IVEDIArFFKo//fO+STtEPdqiKejZzESIH03fdXydznrprw3ptJRq
         9hF+8X7v7Nstempea40gZ8/wtvP5uIiM3kvWnN8dcXtYPa4L5ZI7iDGmQXgg4oLUToJJ
         68oUEVEzOOsZ3frVuH7xuafnnUuF8qKm79LIgI5wj1yqF+lLae+2AKmNt7w66+jDWxtv
         XRjGIr4U8KAIufRKWPR7IJnXXX3P/Qan9PlD7ktGu7YnF0ADeV+9Hmclu58Tf/tvPOI0
         pg9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hcRJyjpf1Os+dJaolVe49RgmT+5cszRgDCVwAxJ0n0o=;
        b=Ecaf0wakXgb6sKRwKMsqn2lguWyg20jUcUWKmQeq5OjUHErfiwNNquRmvuZfJ6k/ec
         lcxWS4DenOwZsvWL7W+EniGV8dURefChsqgMf2LA9gLkr0mJdHtfEXecFXhBPpdmazDZ
         uTCltEIVCo8YcVoWWqNWVmJ5qXVdlzUx1CebT+oIzoYNVoVzetmp0ZFSmrm8/KLX8djr
         29n2qOvUPCCZOWOxgFLjFE+nrvd6juIN0bxUQo8HOzhuZYTsbSAh8p2Jidjc/3UrA4CU
         B2YEX7MqMlWN38EGSIUKSMRuAqOIWABsj6QmyJDR9V2SKHLdT3Mf/0N4CdARw6oF7cBq
         N9lw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="dCn/aejq";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i17sor1077753iol.22.2019.03.20.03.42.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 03:42:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="dCn/aejq";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hcRJyjpf1Os+dJaolVe49RgmT+5cszRgDCVwAxJ0n0o=;
        b=dCn/aejqzrOp2WKxTwq/E2q4ZQe5ezVUloPkEz/OKE/qjj1mOYEqYUmimO810pIJ+U
         RIF9iElA5ZHfbnOZM8VkouD8O4dDbFRtiqz/FYb+Dgg4XN27hOJOQTcuWabryiYXrcCw
         mHShwR4k8ruf6hD6aJk6HxpZBKoWmmN+5Myg9rR5x0ZBEHYD+gvxN95MIC4SLvTnefzU
         liUpF4/YunuRUFelrz9xfIaZxT3AMlEaGvPtzAZj1trQzA0F0lWmreA80Mmm+omZvGar
         0WmQYvG5ZEuPtACYumZ36jDhhRZOoQwpcMAp+ZPPCvXtIPvUhB0cTQtQzWzMUkWVrMgp
         1JLg==
X-Google-Smtp-Source: APXvYqzjMWw1VAe6d0dwLUq9BqrdXjp1tDL6LI2XgDfmt5Gaf1BAro95sT8+BQTH/BIxxPU/7xp5c9SPzJR5QPKrtOY=
X-Received: by 2002:a5d:834a:: with SMTP id q10mr4426278ior.271.1553078567797;
 Wed, 20 Mar 2019 03:42:47 -0700 (PDT)
MIME-Version: 1.0
References: <000000000000db3d130584506672@google.com> <d9e4e36d-1e7a-caaf-f96e-b05592405b5f@virtuozzo.com>
 <CACT4Y+Zj=35t2djhKoq+e1SH3Zu3389Pns7xX6MiMWZ=PFpShA@mail.gmail.com>
 <426293c3-bf63-88ad-06fb-83927ab0d7c0@I-love.SAKURA.ne.jp> <CACT4Y+Zh8eA50egLquE4LPffTCmF+30QR0pKTpuz_FpzsXVmZg@mail.gmail.com>
In-Reply-To: <CACT4Y+Zh8eA50egLquE4LPffTCmF+30QR0pKTpuz_FpzsXVmZg@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 20 Mar 2019 11:42:36 +0100
Message-ID: <CACT4Y+Z2FL=t8cHceXMGvG2QfChKdJYprVvBonu9X+jJaL0HMQ@mail.gmail.com>
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

On Wed, Mar 20, 2019 at 11:38 AM Dmitry Vyukov <dvyukov@google.com> wrote:
>
> On Wed, Mar 20, 2019 at 11:24 AM Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> >
> > On 2019/03/20 18:59, Dmitry Vyukov wrote:
> > >> From bisection log:
> > >>
> > >>         testing release v4.17
> > >>         testing commit 29dcea88779c856c7dc92040a0c01233263101d4 with gcc (GCC) 8.1.0
> > >>         run #0: crashed: kernel panic: corrupted stack end in wb_workfn
> > >>         run #1: crashed: kernel panic: corrupted stack end in worker_thread
> > >>         run #2: crashed: kernel panic: Out of memory and no killable processes...
> > >>         run #3: crashed: kernel panic: corrupted stack end in wb_workfn
> > >>         run #4: crashed: kernel panic: corrupted stack end in wb_workfn
> > >>         run #5: crashed: kernel panic: corrupted stack end in wb_workfn
> > >>         run #6: crashed: kernel panic: corrupted stack end in wb_workfn
> > >>         run #7: crashed: kernel panic: corrupted stack end in wb_workfn
> > >>         run #8: crashed: kernel panic: Out of memory and no killable processes...
> > >>         run #9: crashed: kernel panic: corrupted stack end in wb_workfn
> > >>         testing release v4.16
> > >>         testing commit 0adb32858b0bddf4ada5f364a84ed60b196dbcda with gcc (GCC) 8.1.0
> > >>         run #0: OK
> > >>         run #1: OK
> > >>         run #2: OK
> > >>         run #3: OK
> > >>         run #4: OK
> > >>         run #5: crashed: kernel panic: Out of memory and no killable processes...
> > >>         run #6: OK
> > >>         run #7: crashed: kernel panic: Out of memory and no killable processes...
> > >>         run #8: OK
> > >>         run #9: OK
> > >>         testing release v4.15
> > >>         testing commit d8a5b80568a9cb66810e75b182018e9edb68e8ff with gcc (GCC) 8.1.0
> > >>         all runs: OK
> > >>         # git bisect start v4.16 v4.15
> > >>
> > >> Why bisect started between 4.16 4.15 instead of 4.17 4.16?
> > >
> > > Because 4.16 was still crashing and 4.15 was not crashing. 4.15..4.16
> > > looks like the right range, no?
> >
> > No, syzbot should bisect between 4.16 and 4.17 regarding this bug, for
> > "Stack corruption" can't manifest as "Out of memory and no killable processes".
> >
> > "kernel panic: Out of memory and no killable processes..." is completely
> > unrelated to "kernel panic: corrupted stack end in wb_workfn".
>
>
> Do you think this predicate is possible to code? Looking at the
> examples we have, distinguishing different bugs does not look feasible
> to me. If the predicate is not accurate, you just trade one set of
> false positives to another set of false positives and then you at the
> beginning of an infinite slippery slope refining it.
> Also, if we see a different bug (assuming we can distinguish them),
> does it mean that the original bug is not present? Or it's also
> present, but we just hit the other one first? This also does not look
> feasible to answer. And if you give a wrong answer, bisection goes the
> wrong way and we are where we started. Just with more complex code and
> things being even harder to explain to other people.
> I mean, yes, I agree, kernel bug bisection won't be perfect. But do
> you see anything actionable here?

I see the larger long term bisection quality improvement (for syzbot
and for everybody else) in doing some actual testing for each kernel
commit before it's being merged into any kernel tree, so that we have
less of these a single program triggers 3 different bugs, stray
unrelated bugs, broken release boots, etc. I don't see how reliable
bisection is possible without that.

