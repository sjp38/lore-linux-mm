Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 36D656B04A3
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 16:10:06 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b184so13807922oih.9
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 13:10:06 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id o66si5230557oih.10.2017.08.18.13.10.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 13:10:05 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id e124so10286829oig.0
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 13:10:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170818195858.GP28715@tassilo.jf.intel.com>
References: <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
 <20170818122339.24grcbzyhnzmr4qw@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net> <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170818195858.GP28715@tassilo.jf.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 18 Aug 2017 13:10:04 -0700
Message-ID: <CA+55aFxUMmHAQ1HZnFv20cM2Gh-VqH1oe833+ug0OORjqkqgqQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Aug 18, 2017 at 12:58 PM, Andi Kleen <ak@linux.intel.com> wrote:
>> which is hacky, but there's a rationale for it:
>>
>>  (a) avoid the crazy long wait queues ;)
>>
>>  (b) we know that migration is *supposed* to be CPU-bound (not IO
>> bound), so yielding the CPU and retrying may just be the right thing
>> to do.
>
> So this would degenerate into a spin when the contention is with
> other CPUs?
>
> But then if we guarantee that migration has flat latency curve
> and no long tail it may be reasonable.

Honestly, right now I'd say it's more of a "poath meant purely for
testing with some weak-ass excuse for why it might not be broken".

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
