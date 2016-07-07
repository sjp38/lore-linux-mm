Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id F09236B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 12:54:24 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a2so14792593lfe.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 09:54:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 203si1797079wmk.116.2016.07.07.09.54.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 09:54:23 -0700 (PDT)
Date: Thu, 7 Jul 2016 18:54:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 6/8] mm,oom_reaper: Stop clearing TIF_MEMDIE on remote
 thread.
Message-ID: <20160707165421.GP5379@dhcp22.suse.cz>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
 <201607031140.BDG64095.VJFOOLHSFMFtOQ@I-love.SAKURA.ne.jp>
 <20160707140604.GN5379@dhcp22.suse.cz>
 <201607080110.FHF78128.VOOLFOQFJFSHtM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607080110.FHF78128.VOOLFOQFJFSHtM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Fri 08-07-16 01:10:02, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sun 03-07-16 11:40:41, Tetsuo Handa wrote:
> > > >From 00b7a14653c9700429f89e4512f6000a39cce59d Mon Sep 17 00:00:00 2001
> > > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Date: Sat, 2 Jul 2016 23:03:03 +0900
> > > Subject: [PATCH 6/8] mm,oom_reaper: Stop clearing TIF_MEMDIE on remote thread.
> > > 
> > > Since oom_has_pending_mm() controls whether to select next OOM victim,
> > > we no longer need to clear TIF_MEMDIE on remote thread. Therefore,
> > > revert related changes in commit 36324a990cf578b5 ("oom: clear TIF_MEMDIE
> > > after oom_reaper managed to unmap the address space") and
> > > commit e26796066fdf929c ("oom: make oom_reaper freezable") and
> > > commit 74070542099c66d8 ("oom, suspend: fix oom_reaper vs.
> > > oom_killer_disable race").
> > 
> > The last revert is not safe. See
> > http://lkml.kernel.org/r/1467365190-24640-3-git-send-email-mhocko@kernel.org
> 
> Why?

Because there is no guarantee of calling exit_oom_victim and thus
oom_disable making a forward progress. The changelog referenced above
tries to explain that.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
