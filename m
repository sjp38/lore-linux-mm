Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 57CE86B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 04:13:20 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l89so27209533lfi.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 01:13:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o26si792056wmi.60.2016.07.13.01.13.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 01:13:18 -0700 (PDT)
Date: Wed, 13 Jul 2016 10:13:17 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 7/8] mm,oom: Stop clearing TIF_MEMDIE on remote thread.
Message-ID: <20160713081317.GE28723@dhcp22.suse.cz>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1468330163-4405-8-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160712145355.GQ14586@dhcp22.suse.cz>
 <201607130045.JGE84085.FSQJHOOVLFtMOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607130045.JGE84085.FSQJHOOVLFtMOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Wed 13-07-16 00:45:59, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 12-07-16 22:29:22, Tetsuo Handa wrote:
> > > Since no kernel code path needs to clear TIF_MEMDIE flag on a remote
> > > thread we can drop the task parameter and enforce that actually.
> > > 
> > > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Acked-by: Michal Hocko <mhocko@suse.com>
> > 
> > Please wait with this one along with removing exit_oom_victim from the
> > oom reaper after we settle with the rest of the series. I believe we
> > really need to handle oom_killer_disable in the same batch and that
> > sounds outside of the scope of this series.
> > 
> > I can even pick your patch and rebase it along with the rest that I have
> > posted recently, unless you have objections of course.
> 
> I have no objections. Please insert my patches into your series.

Let's wait after the merge window closes and things calm down. In the
mean time it would be great to summarize pros and cons of the two
approach so that we can decide properly and have this for future
reference.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
