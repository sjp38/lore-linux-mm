Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4416B00B0
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 10:05:09 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so2614514pbb.33
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 07:05:08 -0700 (PDT)
Message-ID: <1380290700.17366.95.camel@joe-AO722>
Subject: Re: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
From: Joe Perches <joe@perches.com>
Date: Fri, 27 Sep 2013 07:05:00 -0700
In-Reply-To: <20130927134802.GA15690@laptop.programming.kicks-ass.net>
References: <1380226007.2170.2.camel@buesod1.americas.hpqcorp.net>
	 <1380226997.2602.11.camel@j-VirtualBox>
	 <1380228059.2170.10.camel@buesod1.americas.hpqcorp.net>
	 <1380229794.2602.36.camel@j-VirtualBox>
	 <1380231702.3467.85.camel@schen9-DESK>
	 <1380235333.3229.39.camel@j-VirtualBox>
	 <1380236265.3467.103.camel@schen9-DESK> <20130927060213.GA6673@gmail.com>
	 <20130927112323.GJ3657@laptop.programming.kicks-ass.net>
	 <1380289495.17366.91.camel@joe-AO722>
	 <20130927134802.GA15690@laptop.programming.kicks-ass.net>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Jason Low <jason.low2@hp.com>, Davidlohr Bueso <davidlohr@hp.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, 2013-09-27 at 15:48 +0200, Peter Zijlstra wrote:
> On Fri, Sep 27, 2013 at 06:44:55AM -0700, Joe Perches wrote:
> > It's a CHK test, so it's only tested with --strict
> > 
> > $ scripts/checkpatch.pl -f --strict kernel/mutex.c 2>&1 | grep memory
> > CHECK: memory barrier without comment
> > CHECK: memory barrier without comment
> > 
> > It could be changed to WARN so it's always on.
> 
> Yes please, we can't be too careful with memory barriers.

I'll send the patch separately.

It seems a pretty noisy test.
There are 13 hits just in arch/x86/kernel/

$ ./scripts/checkpatch.pl -f arch/x86/kernel/*.c | grep -A3 "memory barrier"
WARNING: memory barrier without comment
#685: FILE: x86/kernel/alternative.c:685:
+	smp_wmb();

--
WARNING: memory barrier without comment
#401: FILE: x86/kernel/kvm.c:401:
+		rmb();

WARNING: memory barrier without comment
#403: FILE: x86/kernel/kvm.c:403:
+		rmb();

--
WARNING: memory barrier without comment
#702: FILE: x86/kernel/kvm.c:702:
+	smp_wmb();

WARNING: memory barrier without comment
#704: FILE: x86/kernel/kvm.c:704:
+	smp_wmb();

--
WARNING: memory barrier without comment
#62: FILE: x86/kernel/ldt.c:62:
+	wmb();

WARNING: memory barrier without comment
#64: FILE: x86/kernel/ldt.c:64:
+	wmb();

--
WARNING: memory barrier without comment
#204: FILE: x86/kernel/smpboot.c:204:
+	wmb();

WARNING: memory barrier without comment
#265: FILE: x86/kernel/smpboot.c:265:
+	wmb();

--
WARNING: memory barrier without comment
#557: FILE: x86/kernel/smpboot.c:557:
+	mb();

--
WARNING: memory barrier without comment
#1065: FILE: x86/kernel/smpboot.c:1065:
+	mb();

--
WARNING: memory barrier without comment
#1321: FILE: x86/kernel/smpboot.c:1321:
+	mb();

WARNING: memory barrier without comment
#1399: FILE: x86/kernel/smpboot.c:1399:
+		mb();



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
