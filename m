Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C2AC76B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 13:10:29 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id v18so370302444qtv.0
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 10:10:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w6si2129983qkc.67.2016.07.03.10.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jul 2016 10:10:28 -0700 (PDT)
Date: Sun, 3 Jul 2016 19:10:22 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/8] mm,oom_reaper: Remove pointless kthread_run()
 failure check.
Message-ID: <20160703171022.GA31065@redhat.com>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
 <201607031136.GGI52642.OMLFFOHQtFVJOS@I-love.SAKURA.ne.jp>
 <20160703124246.GA23902@redhat.com>
 <201607040103.DEB48914.HQFFJFOOOVtSLM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607040103.DEB48914.HQFFJFOOOVtSLM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

On 07/04, Tetsuo Handa wrote:
>
> Oleg Nesterov wrote:
> > On 07/03, Tetsuo Handa wrote:
> > >
> > > If kthread_run() in oom_init() fails due to reasons other than OOM
> > > (e.g. no free pid is available), userspace processes won't be able to
> > > start as well.
> >
> > Why?
> >
> > The kernel will boot with or without your change, but
> >
> > > Therefore, trying to continue with error message is
> > > also pointless.
> >
> > Can't understand...
> >
> > I think this warning makes sense. And since you removed the oom_reaper_the
> > check in wake_oom_reaper(), the kernel will leak every task_struct passed
> > to wake_oom_reaper() ?
>
> We are trying to prove that OOM livelock is impossible for CONFIG_MMU=y
> kernels (as long as OOM killer is invoked) because the OOM reaper always
> gives feedback to the OOM killer, right? Then, preserving code which
> continues without OOM reaper no longer makes sense.
>
> In the past discussion, I suggested Michal to use BUG_ON() or panic()
> ( http://lkml.kernel.org/r/20151127123525.GG2493@dhcp22.suse.cz ). At that
> time, we chose continue with pr_err(). If you think that kthread_run()
> failure in oom_init() will ever happen, I can change my patch to call
> BUG_ON() or panic(). I don't like continuing without OOM reaper.

And probably this makes sense, but

> Anyway, [PATCH 8/8] in this series removes get_task_struct().
> Thus, the kernel won't leak every task_struct after all.

which I can't read yet. I am still trying to clone linux-net, currently
my internet connection is very slow.

Anyway, this means that this 1/1 patch depends on 8/8, but 0/8 says

	[PATCH 1/8] can be sent to current linux.git as a clean up.

IOW, this patch doesn't look correct without other changes?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
