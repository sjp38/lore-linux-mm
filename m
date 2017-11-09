Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A91E2440460
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 05:09:24 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id 198so3717319wmg.8
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 02:09:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t33si2965804edd.129.2017.11.09.02.09.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 02:09:23 -0800 (PST)
Date: Thu, 9 Nov 2017 11:09:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too long
Message-ID: <20171109100920.f7ox4nc63dr44gva@dhcp22.suse.cz>
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171026114100.tfb3xemvumg2a7su@dhcp22.suse.cz>
 <91bdbdea-3f33-b7c0-8345-d0fa8c7f1cf1@sonymobile.com>
 <20171109085249.guihvx5tzm77u3qk@dhcp22.suse.cz>
 <ef81333e-0e19-c6f6-a960-093dc60fb75c@sony.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ef81333e-0e19-c6f6-a960-093dc60fb75c@sony.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sony.com>
Cc: peter enderborg <peter.enderborg@sonymobile.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

On Thu 09-11-17 10:34:46, peter enderborg wrote:
> On 11/09/2017 09:52 AM, Michal Hocko wrote:
> > I am not sure. I would rather see a tracepoint to mark the allocator
> > entry. This would allow both 1) measuring the allocation latency (to
> > compare it to the trace_mm_page_alloc and 2) check for stalls with
> > arbitrary user defined timeout (just print all allocations which haven't
> > passed trace_mm_page_alloc for the given amount of time).
> 
> Traces are not that expensive, but there are more than few in calls
> in this path. And Im trying to keep it as small that it can used for
> maintenance versions too.
>
> This is suggestion is a quick way of keeping the current solution for
> the ones that are interested the slow allocations. If we are going
> for a solution with a time-out parameter from the user what interface
> do you suggest to do this configuration. A filter parameter for the
> event?

I meant to do all that in postprocessing. So no specific API is needed,
just parse the output. Anyway, it seems that the printk will be put in
shape in a forseeable future so we might preserve the stall warning
after all. It is the show_mem part which is interesting during that
warning.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
