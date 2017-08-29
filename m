Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1F5B56B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 12:13:32 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t3so7170356pgt.8
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 09:13:32 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id j5si2705570pgn.55.2017.08.29.09.13.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 09:13:30 -0700 (PDT)
Subject: Re: [PATCH 2/2 v2] sched/wait: Introduce lock breaker in
 wake_up_page_bit
References: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
 <cd8ce7fbca9c126f7f928b8fa48d7a9197955b45.1503677178.git.tim.c.chen@linux.intel.com>
 <CA+55aFyErsNw8bqTOCzcrarDZBdj+Ev=1N3sV-gxtLTH03bBFQ@mail.gmail.com>
 <f10f4c25-49c0-7ef5-55c2-769c8fd9bf90@linux.intel.com>
 <CA+55aFzNikMsuPAaExxT1Z8MfOeU6EhSn6UPDkkz-MRqamcemg@mail.gmail.com>
 <CA+55aFx67j0u=GNRKoCWpsLRDcHdrjfVvWRS067wLUSfzstgoQ@mail.gmail.com>
 <CA+55aFzy981a8Ab+89APi6Qnb9U9xap=0A6XNc+wZsAWngWPzA@mail.gmail.com>
 <CA+55aFwyCSh1RbJ3d5AXURa4_r5OA_=ZZKQrFX0=Z1J3ZgVJ5g@mail.gmail.com>
 <CA+55aFy18WCqZGwkxH6dTZR9LD9M5nXWqEN8DBeZ4LvNo4Y0BQ@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F077537A07E9@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFzotfXc07UoVtxvDpQOP8tEt8pgxeYe+cGs=BDUC_A4pA@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F077537A1C19@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwECeY-x=_du67qAxkta_0LeUw_BQA1kP337SBV3znN2Q@mail.gmail.com>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <bd2d09ea-47d1-c0a7-8d4d-604bb4bc28bc@linux.intel.com>
Date: Tue, 29 Aug 2017 09:13:29 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFwECeY-x=_du67qAxkta_0LeUw_BQA1kP337SBV3znN2Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Liang, Kan" <kan.liang@intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 08/29/2017 09:01 AM, Linus Torvalds wrote:
> On Tue, Aug 29, 2017 at 5:57 AM, Liang, Kan <kan.liang@intel.com> wrote:
>>>
>>> Attached is an ALMOST COMPLETELY UNTESTED forward-port of those two
>>> patches, now without that nasty WQ_FLAG_ARRIVALS logic, because we now
>>> always put the new entries at the end of the waitqueue.
>>
>> The patches fix the long wait issue.
>>
>> Tested-by: Kan Liang <kan.liang@intel.com>
> 
> Ok. I'm not 100% comfortable applying them at rc7, so let me think
> about it. There's only one known load triggering this, and by "known"
> I mean "not really known" since we don't even know what the heck it
> does outside of intel and whoever your customer is.
> 
> So I suspect I'll apply the patches next merge window, and we can
> maybe mark them for stable if this actually ends up mattering.
> 
> Can you tell if the problem is actually hitting _production_ use or
> was some kind of benchmark stress-test?
> 
> 

It is affecting not a production use, but the customer's acceptance
test for their systems.  So I suspect it is a stress test.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
