Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6021D8D0039
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 21:31:49 -0500 (EST)
Received: by vxb41 with SMTP id 41so2903574vxb.14
        for <linux-mm@kvack.org>; Tue, 08 Feb 2011 18:31:42 -0800 (PST)
Message-ID: <4D51FCB0.9040101@vflare.org>
Date: Tue, 08 Feb 2011 21:32:16 -0500
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH V2 0/3] drivers/staging: zcache: dynamic page cache/swap
 compression
References: <20110207032407.GA27404@ca-server1.us.oracle.com> <1ddd01a8-591a-42bc-8bb3-561843b31acb@default>
In-Reply-To: <1ddd01a8-591a-42bc-8bb3-561843b31acb@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: gregkh@suse.de, Chris Mason <chris.mason@oracle.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, riel@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, sfr@canb.auug.org.au, wfg@mail.ustc.edu.cn, tytso@mit.edu, viro@ZenIV.linux.org.uk, hughd@google.com, hannes@cmpxchg.org, Matt <jackdachef@gmail.com>

On 02/08/2011 08:03 PM, Dan Magenheimer wrote:
>> (Historical note: This "new" zcache patchset supercedes both the
>> kztmem patchset and the "old" zcache patchset as described in:
>> http://lkml.org/lkml/2011/2/5/148)
>
> (In order to move discussion from the old kztmem patchset to
> the new zcache patchset, I am replying here to Matt's email
> sent at: https://lkml.org/lkml/2011/2/4/199 )
>
>> From: Matt [mailto:jackdachef@gmail.com]
>
<snip>

>
>> a?c Coming back to usage of compcache - how about the problem of 60%
>> memory fragmentation (according to compcache/zcache wiki,
>> http://code.google.com/p/compcache/wiki/Fragmentation) ?
>> Could the situation be improved with in-kernel "memory compaction" ?
>> I'm not a developer so I don't know exactly how lumpy reclaim/memory
>> compaction and xvmalloc would interact with each other
>
> Nitin is the expert on compcache and xvmalloc, so I will leave
> this question unanswered for now.
>


I'm currently in the process of designing a new allocator that gives 
predictable memory fragmentation guarantees (at the expense of extra CPU 
cycles). I've not yet posted details anywhere but many of the ideas are 
from the "Compact Fit" allocator: 
http://www.usenix.org/event/usenix08/tech/full_papers/craciunas/craciunas_html/

I'm not sure how much time it will take since I'm not yet done with some 
of the design details, and then userspace implementation, testing, 
profiling and finally kernel port. Add to that extra concurrency issues 
when integrating with zcache!

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
