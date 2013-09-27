Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9134E6B00B4
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 10:19:12 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so2628570pbc.17
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 07:19:12 -0700 (PDT)
Date: Fri, 27 Sep 2013 16:18:45 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
Message-ID: <20130927141845.GB15690@laptop.programming.kicks-ass.net>
References: <1380228059.2170.10.camel@buesod1.americas.hpqcorp.net>
 <1380229794.2602.36.camel@j-VirtualBox>
 <1380231702.3467.85.camel@schen9-DESK>
 <1380235333.3229.39.camel@j-VirtualBox>
 <1380236265.3467.103.camel@schen9-DESK>
 <20130927060213.GA6673@gmail.com>
 <20130927112323.GJ3657@laptop.programming.kicks-ass.net>
 <1380289495.17366.91.camel@joe-AO722>
 <20130927134802.GA15690@laptop.programming.kicks-ass.net>
 <1380290700.17366.95.camel@joe-AO722>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1380290700.17366.95.camel@joe-AO722>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Jason Low <jason.low2@hp.com>, Davidlohr Bueso <davidlohr@hp.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, Sep 27, 2013 at 07:05:00AM -0700, Joe Perches wrote:
> On Fri, 2013-09-27 at 15:48 +0200, Peter Zijlstra wrote:
> > On Fri, Sep 27, 2013 at 06:44:55AM -0700, Joe Perches wrote:
> > > It's a CHK test, so it's only tested with --strict
> > > 
> > > $ scripts/checkpatch.pl -f --strict kernel/mutex.c 2>&1 | grep memory
> > > CHECK: memory barrier without comment
> > > CHECK: memory barrier without comment
> > > 
> > > It could be changed to WARN so it's always on.
> > 
> > Yes please, we can't be too careful with memory barriers.
> 
> I'll send the patch separately.
> 
> It seems a pretty noisy test.
> There are 13 hits just in arch/x86/kernel/

Urgh. that wants fixing. We really need to stop getting more and that's
where checkpatch is good at.

At very very bare minimum the comment should mention where the pairing
barrier is; but ideally it should describe the actual ordering.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
