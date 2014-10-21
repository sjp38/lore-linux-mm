Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id E21D76B0088
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 13:25:37 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id hi2so11602234wib.3
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 10:25:36 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id m6si13442071wiy.107.2014.10.21.10.25.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 10:25:35 -0700 (PDT)
Date: Tue, 21 Oct 2014 19:25:27 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 0/6] Another go at speculative page faults
Message-ID: <20141021172527.GH3219@twins.programming.kicks-ass.net>
References: <20141020215633.717315139@infradead.org>
 <20141021162340.GA5508@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141021162340.GA5508@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 21, 2014 at 06:23:40PM +0200, Ingo Molnar wrote:
> 
> * Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > My Ivy Bridge EP (2*10*2) has a ~58% improvement in pagefault throughput:
> > 
> > PRE:
> >        149,441,555      page-faults                  ( +-  1.25% )
> >
> > POST:
> >        236,442,626      page-faults                  ( +-  0.08% )
> 
> > My Ivy Bridge EX (4*15*2) has a ~78% improvement in pagefault throughput:
> > 
> > PRE:
> >        105,789,078      page-faults                 ( +-  2.24% )
> >
> > POST:
> >        187,751,767      page-faults                 ( +-  2.24% )
> 
> I guess the 'PRE' and 'POST' numbers should be flipped around?

Nope, its the number of page-faults serviced in a fixed amount of time
(60 seconds), therefore higher is better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
