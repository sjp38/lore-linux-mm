Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3DF6D440460
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 04:34:50 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id b16so1437666lfb.21
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 01:34:50 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id r144si2447027lff.288.2017.11.09.01.34.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 01:34:48 -0800 (PST)
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too long
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171026114100.tfb3xemvumg2a7su@dhcp22.suse.cz>
 <91bdbdea-3f33-b7c0-8345-d0fa8c7f1cf1@sonymobile.com>
 <20171109085249.guihvx5tzm77u3qk@dhcp22.suse.cz>
From: peter enderborg <peter.enderborg@sony.com>
Message-ID: <ef81333e-0e19-c6f6-a960-093dc60fb75c@sony.com>
Date: Thu, 9 Nov 2017 10:34:46 +0100
MIME-Version: 1.0
In-Reply-To: <20171109085249.guihvx5tzm77u3qk@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, peter enderborg <peter.enderborg@sonymobile.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

On 11/09/2017 09:52 AM, Michal Hocko wrote:
> I am not sure. I would rather see a tracepoint to mark the allocator
> entry. This would allow both 1) measuring the allocation latency (to
> compare it to the trace_mm_page_alloc and 2) check for stalls with
> arbitrary user defined timeout (just print all allocations which haven't
> passed trace_mm_page_alloc for the given amount of time).

Traces are not that expensive, but there are more than few in calls in this path. And Im trying to
keep it as small that it can used for maintenance versions too.

This is suggestion is a quick way of keeping the current solution for the ones that are interested
the slow allocations. If we are going for a solution with a time-out parameter from the user what
interface do you suggest to do this configuration. A filter parameter for the event?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
