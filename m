Return-Path: <SRS0=+lVK=PP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A45CC43387
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 05:58:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8DA62070B
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 05:58:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MzLeUA9X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8DA62070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C27E8E0007; Mon,  7 Jan 2019 00:58:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 271ED8E0001; Mon,  7 Jan 2019 00:58:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 189168E0007; Mon,  7 Jan 2019 00:58:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id E57648E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 00:58:15 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id x3so6359154itb.6
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 21:58:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ri/9cAQ4o6M2ErMtq9RazYzpci6FuAaDDs9D+J9lSlM=;
        b=NQUikO0u6Y/kr1nnmYnt7FTbzDSkTJX/8+gJc2vkzWpNdMwP359n/l8a0WEJ8hvv2g
         6EPHA5D3HpN1HRwMnZytgcZD/SBV4HP2q0HtEj5K1gRPfMNMr4rPrKL4YS+YNmrTi2aK
         J7S6S43ONg1HZssUlcMA9lqnI5f33m3PDTVhYJ4ZK52gXBv5fGSZk1BEsMNvxU/QJ9Fh
         cWxNm1/rpKFZERV02xbOpiG7xPSg6FOmpzRP3+DAOE1oEr93okI3K/jxkhhbv1W0NAg7
         E3FOiJaP3Y0PxJqZHK5sGhPQf6UjbT/GzKEpAAjcAk2ght1YMIMeel3mS4pK7YLVGW04
         qC5g==
X-Gm-Message-State: AA+aEWbSfROSCSihwI0voKGfY64xDII8peV5r3ieqpvMZGx7x9mOYeKS
	eMcmdU2L9bOY+1GzvaCcQRKQL5Q1mDGeVpYNhH/mfK3lAyttxxdm2nsUzl7ruGoNeYNc6z9VWET
	JbncKpmdzSURHL6jfBuh4XqTkenBmGkzlAr+cKhTxU8DPZjMwCO+LzJaKLnkgArekwNMwxWhT2O
	4AiVikwrI/zYYtMqfljYetArvWW+86WLTVGS+jT4N4c2fOaViaCFgFcTOgkY54HuVedG/1MDSZZ
	6htrjbfxMtoenYIUHlyLeHaBuleIIlVHkZt+VEszpeqAhIjqcPMPcX7EYMeJFVEyUVD3yBwJ3J+
	k1NCvy2LzVgcTJ4vPjKOlxns7Ur4/Y7uNAfg7loQDYu+GU9s7vNN6F6opcfaMD4Vb1mhlc9Bz+G
	7
X-Received: by 2002:a02:3da:: with SMTP id e87mr37255599jae.78.1546840695606;
        Sun, 06 Jan 2019 21:58:15 -0800 (PST)
X-Received: by 2002:a02:3da:: with SMTP id e87mr37255579jae.78.1546840694564;
        Sun, 06 Jan 2019 21:58:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546840694; cv=none;
        d=google.com; s=arc-20160816;
        b=fzaT9l0KtNJP/6eLSDGghdxKO6QUeIyC4zS+yNUgfmBR9ikPV9kAJ3GrOAGkkHVwcx
         +Xi7YLlHELOI/zy2gHaAkYTx/7ZY4QDkkw0iSZfjZq6M6g1bdou9Ciji7DgaSWn4DMet
         hDPkf1otw2jJ4zxH5qQsZYxDiM4gxdYtvoloJmXPG9pErK5IsA9HMXntpqSjjkaPeQOu
         8q2O/uahTZIHhbsQv2N+/HwXKz4iwJzdDrh6f4i/gvuNEZi2h5gy+nAbQt4NzNwKKV1f
         TwosDYhEmUww3xlqtioQMIhrEoaaxMyLv44JZfXG5jOOLEC0IiBQWMZKCLifL3mJMDD/
         oi1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ri/9cAQ4o6M2ErMtq9RazYzpci6FuAaDDs9D+J9lSlM=;
        b=GKe4LvZQN/UB3GAHAq8ScLCG6x3ref1wBKkAjGAylBJRGCpI1rzdyxatLpDaShpd7d
         MHTpYy2hR1U2gWahreRoG4N38GOnsjn24PDseLngqk4REPocbMfDjJyIO0M8M1GcmQLQ
         ZEJRaV8MguqDo1GRhi0UboOfLsX8qltF0Whas0UUDewL5VkJfRX5iv09OM3qHdl7a5qy
         xmoKimXYnE512ejdInwDWOWeUaoAq161lcCcgmK2peQ3pIzfMOsqi9l/rBMTyED3xjOx
         Wojnv0D3jjeN3KfTvpj5QXFprmJNDbS+8DexWvzHdDENTxcm+z2yYlOHNvhDrH65qH83
         +aKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MzLeUA9X;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s21sor12706234iol.146.2019.01.06.21.58.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 06 Jan 2019 21:58:14 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MzLeUA9X;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ri/9cAQ4o6M2ErMtq9RazYzpci6FuAaDDs9D+J9lSlM=;
        b=MzLeUA9Xq+wrrW9rhTDwGZNBoY41yGEYA7OuHciwxxyPhaomfSD0rL+SDv5VwvsMAu
         DMl5en0sxK8jC1SH65UOFrl/Dsw7tL7ESV9mQ6jHLi8qfsXxPKzwNtnzs0wDjhnJlGFM
         5DZgXmrcQ2PPprV6YCE6TXFSyX+fxyUEkNUbnNSXGWeITxmR//AKEsY6+MigAZ54PkFM
         qR7ebhMFlnoA1UC+wcUrSHnSLp5EZm1wAGVytMekj2TNC/SUJSO9noSC0WRR4u8bzCDB
         OYS5+Se3vvwnTT7qgdnnZOmOIfgAN/dr+PyNXlJJjD3utPzRYQCuYYfQGATMVGNK57k9
         ra7A==
X-Google-Smtp-Source: ALg8bN4WdFyMRAfh7I4rR0HqwtROXQJhK9gFOSPn6ypd4eI2mXTiyP1fbWHbqadAL53Z+ONUBOkjjifa3xMuPWTlQXY=
X-Received: by 2002:a5d:8491:: with SMTP id t17mr41948434iom.11.1546840694038;
 Sun, 06 Jan 2019 21:58:14 -0800 (PST)
MIME-Version: 1.0
References: <1546771139-9349-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <e1a38e21-d5fe-dee3-7081-bc1a12965a68@i-love.sakura.ne.jp> <20190106201941.49f6dc4a4d2e9d15b575f88a@linux-foundation.org>
In-Reply-To: <20190106201941.49f6dc4a4d2e9d15b575f88a@linux-foundation.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 7 Jan 2019 06:58:01 +0100
Message-ID:
 <CACT4Y+Y=V-yRQN6YV_wXT0gejbQKTtUu7wrRmuPVojaVv6NFsQ@mail.gmail.com>
Subject: Re: [PATCH] lockdep: Add debug printk() for downgrade_write() warning.
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux-MM <linux-mm@kvack.org>, 
	Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, 
	Will Deacon <will.deacon@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190107055801.jQmpkBACGPySxg2uNEKzX5JTrk8DKQYExwq04W38PEI@z>

On Mon, Jan 7, 2019 at 5:19 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Sun, 6 Jan 2019 19:56:59 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> > syzbot is frequently hitting downgrade_write(&mm->mmap_sem) warning from
> > munmap() request, but I don't know why it is happening. Since lockdep is
> > not printing enough information, let's print more. This patch is meant for
> > linux-next.git only and will be removed after the problem is solved.
> >
> > --- a/kernel/locking/lockdep.c
> > +++ b/kernel/locking/lockdep.c
> > @@ -50,6 +50,7 @@
> >  #include <linux/random.h>
> >  #include <linux/jhash.h>
> >  #include <linux/nmi.h>
> > +#include <linux/rwsem.h>
> >
> >  #include <asm/sections.h>
> >
> > @@ -3550,6 +3551,24 @@ static int __lock_downgrade(struct lockdep_map *lock, unsigned long ip)
> >       curr->lockdep_depth = i;
> >       curr->curr_chain_key = hlock->prev_chain_key;
> >
> > +#if defined(CONFIG_RWSEM_XCHGADD_ALGORITHM) && defined(CONFIG_DEBUG_AID_FOR_SYZBOT)
> > +     if (hlock->read && curr->mm) {
> > +             struct rw_semaphore *sem = container_of(lock,
> > +                                                     struct rw_semaphore,
> > +                                                     dep_map);
> > +
> > +             if (sem == &curr->mm->mmap_sem) {
> > +#if defined(CONFIG_RWSEM_SPIN_ON_OWNER)
> > +                     pr_warn("mmap_sem: hlock->read=%d count=%ld current=%px, owner=%px\n",
> > +                             hlock->read, atomic_long_read(&sem->count),
> > +                             curr, READ_ONCE(sem->owner));
> > +#else
> > +                     pr_warn("mmap_sem: hlock->read=%d count=%ld\n",
> > +                             hlock->read, atomic_long_read(&sem->count));
> > +#endif
> > +             }
> > +     }
> > +#endif
> >       WARN(hlock->read, "downgrading a read lock");
> >       hlock->read = 1;
> >       hlock->acquire_ip = ip;
>
> I tossed it in there.
>
> But I wonder if anyone is actually running this code.  Because
>
> --- a/lib/Kconfig.debug~info-task-hung-in-generic_file_write_iter
> +++ a/lib/Kconfig.debug
> @@ -2069,6 +2069,12 @@ config IO_STRICT_DEVMEM
>
>           If in doubt, say Y.
>
> +config DEBUG_AID_FOR_SYZBOT
> +       bool "Additional debug code for syzbot"
> +       default n
> +       help
> +         This option is intended for testing by syzbot.
> +


Yes, syzbot always defines this option:

https://github.com/google/syzkaller/blob/master/dashboard/config/upstream-kasan.config#L14
https://github.com/google/syzkaller/blob/master/dashboard/config/upstream-kmsan.config#L9

It's meant specifically for such cases.

Tetsuo already got some useful information for past bugs using this feature.

