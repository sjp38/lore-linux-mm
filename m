Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E82976B026C
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 09:37:13 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f64so2219642pfd.6
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 06:37:13 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l1si2806259pli.690.2018.01.11.06.37.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 06:37:12 -0800 (PST)
Subject: Re: [mm? 4.15-rc7] Random oopses under memory pressure.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180110124519.GU1732@dhcp22.suse.cz>
	<201801102237.BED34322.QOOJMFFFHVLSOt@I-love.SAKURA.ne.jp>
	<20180111135721.GC1732@dhcp22.suse.cz>
	<201801112311.EHI90152.FLJMQOStVHFOFO@I-love.SAKURA.ne.jp>
	<20180111142148.GD1732@dhcp22.suse.cz>
In-Reply-To: <20180111142148.GD1732@dhcp22.suse.cz>
Message-Id: <201801112337.HHB95897.JHQOFFtMOOVSFL@I-love.SAKURA.ne.jp>
Date: Thu, 11 Jan 2018 23:37:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, linux-fsdevel@vger.kernel.org

Michal Hocko wrote:
> On Thu 11-01-18 23:11:12, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Wed 10-01-18 22:37:52, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > On Wed 10-01-18 20:49:56, Tetsuo Handa wrote:
> > > > > > Tetsuo Handa wrote:
> > > > > > > I can hit this bug with Linux 4.11 and 4.8. (i.e. at least all 4.8+ have this bug.)
> > > > > > > So far I haven't hit this bug with Linux 4.8-rc3 and 4.7.
> > > > > > > Does anyone know what is happening?
> > > > > > 
> > > > > > I simplified the reproducer and succeeded to reproduce this bug with both
> > > > > > i7-2630QM (8 core) and i5-4440S (4 core). Thus, I think that this bug is
> > > > > > not architecture specific.
> > > > > 
> > > > > Can you see the same with 64b kernel?
> > > > 
> > > > No. I can hit this bug with only x86_32 kernels.
> > > > But if the cause is not specific to 32b, this might be silent memory corruption.
> > > > 
> > > > > It smells like a ref count imbalance and premature page free to me. Can
> > > > > you try to bisect this?
> > > > 
> > > > Too difficult to bisect, but at least I can hit this bug with 4.8+ kernels.
> > 
> > The bug in 4.8 kernel might be different from the bug in 4.15-rc7 kernel.
> > 4.15-rc7 kernel hits the bug so trivially.
> 
> Maybe you want to disable the oom reaper to reduce chances of some issue
> there.

I already tried it for 4.15-rc7.
The bug can occur before the OOM killer is invoked for the first time after boot.
The OOM killer and the OOM reaper are not the culprit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
