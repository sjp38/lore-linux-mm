Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 94310440460
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 03:52:56 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id m16so8232245iod.11
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 00:52:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c3si5750963pld.233.2017.11.09.00.52.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 00:52:55 -0800 (PST)
Date: Thu, 9 Nov 2017 09:52:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too long
Message-ID: <20171109085249.guihvx5tzm77u3qk@dhcp22.suse.cz>
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171026114100.tfb3xemvumg2a7su@dhcp22.suse.cz>
 <91bdbdea-3f33-b7c0-8345-d0fa8c7f1cf1@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <91bdbdea-3f33-b7c0-8345-d0fa8c7f1cf1@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

[Please try to trim the context you are replying to]

On Wed 08-11-17 11:30:23, peter enderborg wrote:
[...]
> What about the idea to keep the function, but instead of printing only do a trace event.

I am not sure. I would rather see a tracepoint to mark the allocator
entry. This would allow both 1) measuring the allocation latency (to
compare it to the trace_mm_page_alloc and 2) check for stalls with
arbitrary user defined timeout (just print all allocations which haven't
passed trace_mm_page_alloc for the given amount of time).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
