Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41E386810C3
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 12:44:18 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a186so1951829pge.5
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 09:44:18 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id w69si4969756pgd.447.2017.08.25.09.44.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 09:44:17 -0700 (PDT)
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
References: <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A377@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwavpFfKNW9NVgNhLggqhii-guc5aX1X5fxrPK+==id0g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A8AB@SHSMSX103.ccr.corp.intel.com>
 <6e8b81de-e985-9222-29c5-594c6849c351@linux.intel.com>
 <CA+55aFzbom=qFc2pYk07XhiMBn083EXugSUHmSVbTuu8eJtHVQ@mail.gmail.com>
 <CA+55aFzxisTJS+Z7q+Dp9oRgvMpXEQRedYFu7-k_YXEE-=htgA@mail.gmail.com>
 <85fb2a78-cbb7-dceb-12e8-7d18519c30a0@linux.intel.com>
 <CA+55aFwOxWWgL3Xdh_m3pbeoYedqBkpvLiJNcEYWUvOAzmB3zQ@mail.gmail.com>
 <20170824204448.if2mve3iy5k425di@techsingularity.net>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <63454831-3259-c758-d164-3b2ff2a04b7e@linux.intel.com>
Date: Fri, 25 Aug 2017 09:44:06 -0700
MIME-Version: 1.0
In-Reply-To: <20170824204448.if2mve3iy5k425di@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 08/24/2017 01:44 PM, Mel Gorman wrote:
> On Thu, Aug 24, 2017 at 11:16:15AM -0700, Linus Torvalds wrote:
>> On Thu, Aug 24, 2017 at 10:49 AM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
>>>
>>> These changes look fine.  We are testing them now.
>>> Does the second patch in the series look okay to you?
>>
>> I didn't really have any reaction to that one, as long as Mel&co are
>> ok with it, I'm fine with it.
>>
> 
> I've no strong objections or concerns. I'm disappointed that the
> original root cause for this could not be found but hope that eventually a
> reproducible test case will eventually be available. Despite having access
> to a 4-socket box, I was still unable to create a workload that caused
> large delays on wakeup. I'm going to have to stop as I don't think it's
> possible to create on that particular machine for whatever reason.
> 

Kan helped to test the updated patch 1 from Linus.  It worked fine.
I've refreshed the patch set that includes all the changes
and send a version 2 refresh of the patch set separately.

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
