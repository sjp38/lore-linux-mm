Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 648F66B025E
	for <linux-mm@kvack.org>; Fri, 20 May 2016 09:44:46 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id g83so47761511oib.0
        for <linux-mm@kvack.org>; Fri, 20 May 2016 06:44:46 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v24si6274090otd.118.2016.05.20.06.44.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 May 2016 06:44:45 -0700 (PDT)
Subject: Re: [PATCH v3] mm,oom: speed up select_bad_process() loop.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
	<20160520075035.GF19172@dhcp22.suse.cz>
	<201605202051.EBC82806.QLVMOtJOOFFFSH@I-love.SAKURA.ne.jp>
	<20160520120954.GA5215@dhcp22.suse.cz>
	<201605202241.CHG21813.FHtSFVJFMOQOLO@I-love.SAKURA.ne.jp>
In-Reply-To: <201605202241.CHG21813.FHtSFVJFMOQOLO@I-love.SAKURA.ne.jp>
Message-Id: <201605202244.JIC51502.FVOFOLJOQMSHtF@I-love.SAKURA.ne.jp>
Date: Fri, 20 May 2016 22:44:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, oleg@redhat.com

Tetsuo Handa wrote:
> > > By the way, I noticed that mem_cgroup_out_of_memory() might have a bug about its
> > > return value. It returns true if hit OOM_SCAN_ABORT after chosen != NULL, false
> > > if hit OOM_SCAN_ABORT before chosen != NULL. Which is expected return value?
> > 
> > true. Care to send a patch?
> 
> I don't know what memory_max_write() wants to do when it found a TIF_MEMDIE thread
> in the given memcg. Thus, I can't tell whether setting chosen to NULL (which means
> mem_cgroup_out_of_memory() returns false) is the expected behavior.
> 
Oops. "true" not "True" in this case meant "1" !?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
