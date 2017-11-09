Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id C1E29440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 05:20:06 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id x6so1378163otd.14
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 02:20:06 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 125si1154826oih.436.2017.11.09.02.20.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 02:20:05 -0800 (PST)
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too long
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171026114100.tfb3xemvumg2a7su@dhcp22.suse.cz>
	<91bdbdea-3f33-b7c0-8345-d0fa8c7f1cf1@sonymobile.com>
	<20171109085249.guihvx5tzm77u3qk@dhcp22.suse.cz>
	<ef81333e-0e19-c6f6-a960-093dc60fb75c@sony.com>
	<20171109100920.f7ox4nc63dr44gva@dhcp22.suse.cz>
In-Reply-To: <20171109100920.f7ox4nc63dr44gva@dhcp22.suse.cz>
Message-Id: <201711091919.IDD04628.FSQOJFVLOOtFMH@I-love.SAKURA.ne.jp>
Date: Thu, 9 Nov 2017 19:19:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, peter.enderborg@sony.com
Cc: peter.enderborg@sonymobile.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, pmladek@suse.com, sergey.senozhatsky@gmail.com, vbabka@suse.cz, yuwang.yuwang@alibaba-inc.com

Michal Hocko wrote:
> On Thu 09-11-17 10:34:46, peter enderborg wrote:
> > On 11/09/2017 09:52 AM, Michal Hocko wrote:
> > > I am not sure. I would rather see a tracepoint to mark the allocator
> > > entry. This would allow both 1) measuring the allocation latency (to
> > > compare it to the trace_mm_page_alloc and 2) check for stalls with
> > > arbitrary user defined timeout (just print all allocations which haven't
> > > passed trace_mm_page_alloc for the given amount of time).
> > 
> > Traces are not that expensive, but there are more than few in calls
> > in this path. And Im trying to keep it as small that it can used for
> > maintenance versions too.
> >
> > This is suggestion is a quick way of keeping the current solution for
> > the ones that are interested the slow allocations. If we are going
> > for a solution with a time-out parameter from the user what interface
> > do you suggest to do this configuration. A filter parameter for the
> > event?
> 
> I meant to do all that in postprocessing. So no specific API is needed,
> just parse the output. Anyway, it seems that the printk will be put in
> shape in a forseeable future so we might preserve the stall warning
> after all. It is the show_mem part which is interesting during that
> warning.

I don't know whether printk() will be put in shape in a foreseeable future.
The rule that "do not try to printk() faster than the kernel can write to
consoles" will remain no matter how printk() changes. Unless asynchronous
approach like https://lwn.net/Articles/723447/ is used, I think we can't
obtain useful information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
