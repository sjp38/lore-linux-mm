Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DF2EA6B055B
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 10:47:52 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g71so2701234wmg.13
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 07:47:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q15si97199wrg.277.2017.08.01.07.47.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 07:47:51 -0700 (PDT)
Date: Tue, 1 Aug 2017 16:47:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Possible race condition in oom-killer
Message-ID: <20170801144749.GA15780@dhcp22.suse.cz>
References: <20170728132952.GQ2274@dhcp22.suse.cz>
 <201707282255.BGI87015.FSFOVQtMOHLJFO@I-love.SAKURA.ne.jp>
 <20170728140706.GT2274@dhcp22.suse.cz>
 <201707291331.JGI18780.OtJVLFMHFOFSOQ@I-love.SAKURA.ne.jp>
 <20170801121411.GG15774@dhcp22.suse.cz>
 <201708012316.CFF21387.VMFtLFJHFOQOOS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708012316.CFF21387.VMFtLFJHFOQOOS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mjaggi@caviumnetworks.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 01-08-17 23:16:13, Tetsuo Handa wrote:
> Michal Hocko wrote:
> >                       Once we merge [1] then the oom victim wouldn't
> > need to get TIF_MEMDIE to access memory reserves.
> > 
> > [1] http://lkml.kernel.org/r/20170727090357.3205-2-mhocko@kernel.org
> 
> False. We are not setting oom_mm to all thread groups (!CLONE_THREAD) sharing
> that mm (CLONE_VM). Thus, one thread from each thread group sharing that mm
> will have to call out_of_memory() in order to set oom_mm, and they will find
> task_will_free_mem() returning false due to MMF_OOM_SKIP already set, and
> after all goes to next OOM victim selection.

Once the patch is merged we can mark_oom_victim all of them as well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
