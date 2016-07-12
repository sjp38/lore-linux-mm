Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 366F86B025F
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 11:46:13 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id q2so34233461pap.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 08:46:13 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ut1si4580258pac.88.2016.07.12.08.46.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 08:46:12 -0700 (PDT)
Subject: Re: [PATCH 7/8] mm,oom: Stop clearing TIF_MEMDIE on remote thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<1468330163-4405-8-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160712145355.GQ14586@dhcp22.suse.cz>
In-Reply-To: <20160712145355.GQ14586@dhcp22.suse.cz>
Message-Id: <201607130045.JGE84085.FSQJHOOVLFtMOF@I-love.SAKURA.ne.jp>
Date: Wed, 13 Jul 2016 00:45:59 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

Michal Hocko wrote:
> On Tue 12-07-16 22:29:22, Tetsuo Handa wrote:
> > Since no kernel code path needs to clear TIF_MEMDIE flag on a remote
> > thread we can drop the task parameter and enforce that actually.
> > 
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Please wait with this one along with removing exit_oom_victim from the
> oom reaper after we settle with the rest of the series. I believe we
> really need to handle oom_killer_disable in the same batch and that
> sounds outside of the scope of this series.
> 
> I can even pick your patch and rebase it along with the rest that I have
> posted recently, unless you have objections of course.

I have no objections. Please insert my patches into your series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
