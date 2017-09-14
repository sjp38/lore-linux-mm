Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB1F66B0253
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 22:28:01 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id g32so971095ioj.0
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 19:28:01 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g21sor1346694ioc.194.2017.09.13.19.28.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Sep 2017 19:28:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <a9e74f64-dee6-dc23-128e-8ef8c7383d77@linux.intel.com>
References: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
 <CA+55aFyErsNw8bqTOCzcrarDZBdj+Ev=1N3sV-gxtLTH03bBFQ@mail.gmail.com>
 <f10f4c25-49c0-7ef5-55c2-769c8fd9bf90@linux.intel.com> <CA+55aFzNikMsuPAaExxT1Z8MfOeU6EhSn6UPDkkz-MRqamcemg@mail.gmail.com>
 <CA+55aFx67j0u=GNRKoCWpsLRDcHdrjfVvWRS067wLUSfzstgoQ@mail.gmail.com>
 <CA+55aFzy981a8Ab+89APi6Qnb9U9xap=0A6XNc+wZsAWngWPzA@mail.gmail.com>
 <CA+55aFwyCSh1RbJ3d5AXURa4_r5OA_=ZZKQrFX0=Z1J3ZgVJ5g@mail.gmail.com>
 <CA+55aFy18WCqZGwkxH6dTZR9LD9M5nXWqEN8DBeZ4LvNo4Y0BQ@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F077537A07E9@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFzotfXc07UoVtxvDpQOP8tEt8pgxeYe+cGs=BDUC_A4pA@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F077537A1C19@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwECeY-x=_du67qAxkta_0LeUw_BQA1kP337SBV3znN2Q@mail.gmail.com>
 <bd2d09ea-47d1-c0a7-8d4d-604bb4bc28bc@linux.intel.com> <CA+55aFx3WY00yvEDBg7TagX4h_-QO71=HAq5GAT8awtewRXONQ@mail.gmail.com>
 <a9e74f64-dee6-dc23-128e-8ef8c7383d77@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 13 Sep 2017 19:27:59 -0700
Message-ID: <CA+55aFx1aBJeq0AsRBsq_mguBz4Qo1fRygn-a19BcMvBA=J=ug@mail.gmail.com>
Subject: Re: [PATCH 2/2 v2] sched/wait: Introduce lock breaker in wake_up_page_bit
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Sep 13, 2017 at 7:12 PM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
>
> BTW, will you be merging these 2 patches in 4.14?

Yes, and thanks for reminding me.

In fact, would you mind sending me the latest versions, rather than me
digging them out of the disaster area that is my mailbox and possibly
picking an older version?

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
