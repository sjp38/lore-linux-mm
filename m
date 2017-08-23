Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 859892802FE
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 11:58:42 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id e2so4140696pgf.7
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:58:42 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m22si1325686plk.368.2017.08.23.08.58.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 08:58:39 -0700 (PDT)
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
References: <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net>
 <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A377@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwavpFfKNW9NVgNhLggqhii-guc5aX1X5fxrPK+==id0g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A8AB@SHSMSX103.ccr.corp.intel.com>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <6e8b81de-e985-9222-29c5-594c6849c351@linux.intel.com>
Date: Wed, 23 Aug 2017 08:58:37 -0700
MIME-Version: 1.0
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F0775378A8AB@SHSMSX103.ccr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liang, Kan" <kan.liang@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 08/23/2017 07:49 AM, Liang, Kan wrote:
>> On Tue, Aug 22, 2017 at 12:55 PM, Liang, Kan <kan.liang@intel.com> wrote:
>>>
>>>> So I propose testing the attached trivial patch.
>>>
>>> It doesna??t work.
>>> The call stack is the same.
>>
>> So I would have expected the stack trace to be the same, and I would even
>> expect the CPU usage to be fairly similar, because you'd see repeating from
>> the callers (taking the fault again if the page is - once again - being migrated).
>>
>> But I was hoping that the wait queues would be shorter because the loop for
>> the retry would be bigger.
>>
>> Oh well.
>>
>> I'm slightly out of ideas. Apparently the yield() worked ok (apart from not
>> catching all cases), and maybe we could do a version that waits on the page
>> bit in the non-contended case, but yields under contention?
>>
>> IOW, maybe this is the best we can do for now? Introducing that
>> "wait_on_page_migration()" helper might allow us to tweak this a bit as
>> people come up with better ideas..
> 
> The "wait_on_page_migration()" helper works well in the overnight testing.
> 


Linus,

Will you still consider the original patch as a fail safe mechanism?

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
