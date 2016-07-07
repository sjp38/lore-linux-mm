Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C68B26B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 12:10:14 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id u201so38125479oie.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 09:10:14 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 34si839976ote.295.2016.07.07.09.10.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 09:10:14 -0700 (PDT)
Subject: Re: [PATCH 6/8] mm,oom_reaper: Stop clearing TIF_MEMDIE on remote thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
	<201607031140.BDG64095.VJFOOLHSFMFtOQ@I-love.SAKURA.ne.jp>
	<20160707140604.GN5379@dhcp22.suse.cz>
In-Reply-To: <20160707140604.GN5379@dhcp22.suse.cz>
Message-Id: <201607080110.FHF78128.VOOLFOQFJFSHtM@I-love.SAKURA.ne.jp>
Date: Fri, 8 Jul 2016 01:10:02 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

Michal Hocko wrote:
> On Sun 03-07-16 11:40:41, Tetsuo Handa wrote:
> > >From 00b7a14653c9700429f89e4512f6000a39cce59d Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Sat, 2 Jul 2016 23:03:03 +0900
> > Subject: [PATCH 6/8] mm,oom_reaper: Stop clearing TIF_MEMDIE on remote thread.
> > 
> > Since oom_has_pending_mm() controls whether to select next OOM victim,
> > we no longer need to clear TIF_MEMDIE on remote thread. Therefore,
> > revert related changes in commit 36324a990cf578b5 ("oom: clear TIF_MEMDIE
> > after oom_reaper managed to unmap the address space") and
> > commit e26796066fdf929c ("oom: make oom_reaper freezable") and
> > commit 74070542099c66d8 ("oom, suspend: fix oom_reaper vs.
> > oom_killer_disable race").
> 
> The last revert is not safe. See
> http://lkml.kernel.org/r/1467365190-24640-3-git-send-email-mhocko@kernel.org

Why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
