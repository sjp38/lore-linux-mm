Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3076B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 09:05:19 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x23so249873163pgx.6
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 06:05:19 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 30si43530379plc.16.2016.12.12.06.05.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Dec 2016 06:05:18 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161209144624.GB4334@dhcp22.suse.cz>
	<201612102024.CBB26549.SJFOOtOVMFFQHL@I-love.SAKURA.ne.jp>
	<20161212090702.GD18163@dhcp22.suse.cz>
	<20161212114903.GM3506@pathway.suse.cz>
	<20161212130046.GB3185@dhcp22.suse.cz>
In-Reply-To: <20161212130046.GB3185@dhcp22.suse.cz>
Message-Id: <201612122305.FIJ13590.FMLFSOtOVHFJOQ@I-love.SAKURA.ne.jp>
Date: Mon, 12 Dec 2016 23:05:14 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, pmladek@suse.com
Cc: linux-mm@kvack.org, sergey.senozhatsky@gmail.com

Michal Hocko wrote:
> On Mon 12-12-16 12:49:03, Petr Mladek wrote:
> > On Mon 2016-12-12 10:07:03, Michal Hocko wrote:
> > > On Sat 10-12-16 20:24:57, Tetsuo Handa wrote:
> [...]
> > > > The introduction of uncontrolled
> > > > 
> > > >   warn_alloc(gfp_mask, "page allocation stalls for %ums, order:%u", ...);
> > 
> > I am just curious that there would be so many messages.
> > If I get it correctly, this warning is printed
> > once every 10 second. Or am I wrong?
> 
> Yes it is once per 10s per allocation context. Tetsuo's test case is
> generating hundreds of such allocation paths which are hitting the
> warn_alloc path. So they can meet there and generate a lot of output.

Excuse me, but most processes in this testcase
( http://lkml.kernel.org/r/201612080029.IBD55588.OSOFOtHVMLQFFJ@I-love.SAKURA.ne.jp )
are blocked on locks. I guess at most few dozens of threads are in allocation paths.

It would be possible to try to keep as many threads as possible inside allocation
paths if I try different test cases. But not so interesting thing for a system with
only 4 CPUs. Maybe interesting if 256 CPUs or more...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
