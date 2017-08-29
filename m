Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 82DBE6B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 12:57:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n73so6934207pfj.9
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 09:57:27 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id w24si2718134pfl.24.2017.08.29.09.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 09:57:26 -0700 (PDT)
Subject: Re: [PATCH 2/2 v2] sched/wait: Introduce lock breaker in
 wake_up_page_bit
References: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
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
 <bd2d09ea-47d1-c0a7-8d4d-604bb4bc28bc@linux.intel.com>
 <CA+55aFx3WY00yvEDBg7TagX4h_-QO71=HAq5GAT8awtewRXONQ@mail.gmail.com>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <aa4f7099-1eb9-17f8-973d-8a10a7db1d94@linux.intel.com>
Date: Tue, 29 Aug 2017 09:57:24 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFx3WY00yvEDBg7TagX4h_-QO71=HAq5GAT8awtewRXONQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 08/29/2017 09:24 AM, Linus Torvalds wrote:
> On Tue, Aug 29, 2017 at 9:13 AM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
>>
>> It is affecting not a production use, but the customer's acceptance
>> test for their systems.  So I suspect it is a stress test.
> 
> Can you gently poke them and ask if they might make theie stress test
> code available?
> 
> Tell them that we have a fix, but right now it's delayed into 4.14
> because we have no visibility into what it is that it actually fixes,
> and whether it's all that critical or just some microbenchmark.
> 

Thanks. We'll do that.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
