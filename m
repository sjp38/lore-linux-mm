Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8F06B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 08:35:29 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id d1so1237318wiv.2
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 05:35:29 -0700 (PDT)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com. [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id am1si1631102wjc.38.2014.10.22.05.35.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 05:35:28 -0700 (PDT)
Received: by mail-wg0-f45.google.com with SMTP id m15so3728081wgh.16
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 05:35:27 -0700 (PDT)
Date: Wed, 22 Oct 2014 14:35:23 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC][PATCH 0/6] Another go at speculative page faults
Message-ID: <20141022123523.GA24499@gmail.com>
References: <20141020215633.717315139@infradead.org>
 <20141021162340.GA5508@gmail.com>
 <20141021172527.GH3219@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141021172527.GH3219@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, Oct 21, 2014 at 06:23:40PM +0200, Ingo Molnar wrote:
> > 
> > * Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > My Ivy Bridge EP (2*10*2) has a ~58% improvement in pagefault throughput:
> > > 
> > > PRE:
> > >        149,441,555      page-faults                  ( +-  1.25% )
> > >
> > > POST:
> > >        236,442,626      page-faults                  ( +-  0.08% )
> > 
> > > My Ivy Bridge EX (4*15*2) has a ~78% improvement in pagefault throughput:
> > > 
> > > PRE:
> > >        105,789,078      page-faults                 ( +-  2.24% )
> > >
> > > POST:
> > >        187,751,767      page-faults                 ( +-  2.24% )
> > 
> > I guess the 'PRE' and 'POST' numbers should be flipped around?
> 
> Nope, its the number of page-faults serviced in a fixed amount of time
> (60 seconds), therefore higher is better.

Ah, okay!

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
