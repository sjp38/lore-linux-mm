Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 91E6D6B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 03:25:15 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id f134so21520914lfg.6
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 00:25:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m62si2400490wmc.0.2016.10.21.00.25.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 21 Oct 2016 00:25:14 -0700 (PDT)
Subject: Re: [RFC] fs/proc/meminfo: introduce Unaccounted statistic
References: <20161020121149.9935-1-vbabka@suse.cz>
 <20161020133358.GN14609@dhcp22.suse.cz> <20161020225929.GP23194@dastard>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <70fe5da3-c739-58ce-0531-299b48e0ca9e@suse.cz>
Date: Fri, 21 Oct 2016 09:25:10 +0200
MIME-Version: 1.0
In-Reply-To: <20161020225929.GP23194@dastard>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>

On 10/21/2016 12:59 AM, Dave Chinner wrote:
> On Thu, Oct 20, 2016 at 03:33:58PM +0200, Michal Hocko wrote:
>> On Thu 20-10-16 14:11:49, Vlastimil Babka wrote:
>> [...]
>> > Hi, I'm wondering if people would find this useful. If you think it is, and
>> > to not make performance worse, I could also make sure in proper submission
>> > that values are not read via global_page_state() multiple times etc...
>>
>> I definitely find this information useful and hate to do the math all
>> the time but on the other hand this is quite fragile and I can imagine
>> we can easily forget to add something there and provide a misleading
>> information to the userspace. So I would be worried with a long term
>> maintainability of this.
>
> This will result in valid memory usage by subsystems like the XFS
> buffer cache being reported as "unaccounted". Given this cache
> (whose size is shrinker controlled) can grow to gigabytes in size
> under various metadata intensive workloads, there's every chance
> that such reporting will make users incorrectly think they have a
> massive memory leak....

Is the XFS buffer cache accounted (and visible) somewhere then? I'd say getting 
such large consumers to become visible on the same level as others would be 
another advantage...

And yeah, I can even recall a bug report, where I had to do the calculation 
myself and it looked like a big leak, and it took some effort to connect it to 
xfs buffers. I'd very much welcome for it to be more obvious.

Vlastimil

> Cheers,
>
> Dave.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
