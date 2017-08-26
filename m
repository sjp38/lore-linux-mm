Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B33BD6810D7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 20:31:54 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 4so2048556oie.8
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 17:31:54 -0700 (PDT)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id g5si6252127oif.82.2017.08.25.17.31.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 17:31:53 -0700 (PDT)
Received: by mail-oi0-x244.google.com with SMTP id d66so833372oib.3
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 17:31:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFx67j0u=GNRKoCWpsLRDcHdrjfVvWRS067wLUSfzstgoQ@mail.gmail.com>
References: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
 <cd8ce7fbca9c126f7f928b8fa48d7a9197955b45.1503677178.git.tim.c.chen@linux.intel.com>
 <CA+55aFyErsNw8bqTOCzcrarDZBdj+Ev=1N3sV-gxtLTH03bBFQ@mail.gmail.com>
 <f10f4c25-49c0-7ef5-55c2-769c8fd9bf90@linux.intel.com> <CA+55aFzNikMsuPAaExxT1Z8MfOeU6EhSn6UPDkkz-MRqamcemg@mail.gmail.com>
 <CA+55aFx67j0u=GNRKoCWpsLRDcHdrjfVvWRS067wLUSfzstgoQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 25 Aug 2017 17:31:52 -0700
Message-ID: <CA+55aFzy981a8Ab+89APi6Qnb9U9xap=0A6XNc+wZsAWngWPzA@mail.gmail.com>
Subject: Re: [PATCH 2/2 v2] sched/wait: Introduce lock breaker in wake_up_page_bit
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Aug 25, 2017 at 4:03 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Let this be a lesson in just *how* little tested, and *how* crap that
> patch probably still is.

I haven't had time to look at it any more (trying to merge the pull
requests that came in today instead), but the more I think about it,
the more I think it was a mistake to do that page_wait_struct
allocation on the stack.

It made it way more fragile and complicated, having to rewrite things
so carefully. A simple slab cache would likely be a lot cleaner and
simpler.

So even if that thing can be made to work, it's probably not worth the pain.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
