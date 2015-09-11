Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id AE6F06B0038
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 09:51:54 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so65363119wic.0
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 06:51:54 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id x5si4372200wiy.3.2015.09.11.06.51.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Sep 2015 06:51:53 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so65362499wic.0
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 06:51:53 -0700 (PDT)
Date: Fri, 11 Sep 2015 15:51:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] android, lmk: Send SIGKILL before setting TIF_MEMDIE.
Message-ID: <20150911135151.GK3417@dhcp22.suse.cz>
References: <1441517135-4980-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1509091454020.20924@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1509091454020.20924@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, gregkh@linuxfoundation.org, linux-mm@kvack.org

On Wed 09-09-15 14:55:59, David Rientjes wrote:
> On Sun, 6 Sep 2015, Tetsuo Handa wrote:
> 
> > It was observed that setting TIF_MEMDIE before sending SIGKILL at
> > oom_kill_process() allows memory reserves to be depleted by allocations
> > which are not needed for terminating the OOM victim.
> > 
> 
> I don't understand what you are trying to fix.  Sending a SIGKILL first 
> does not guarantee that it is handling that signal before accessing memory 
> reserves. 

Yes it doesn't guarantee that but it kicks the task from userspace so
that it cannot deplete the memory reserves from the _userspace_ under
its controll. It still can consume some amount of memory from the kernel
but that shouldn't be under control of the task.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
