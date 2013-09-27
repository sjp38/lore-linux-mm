Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id CE99D6B0082
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:45:03 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so2607314pbb.28
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:45:03 -0700 (PDT)
Message-ID: <1380289495.17366.91.camel@joe-AO722>
Subject: Re: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
From: Joe Perches <joe@perches.com>
Date: Fri, 27 Sep 2013 06:44:55 -0700
In-Reply-To: <20130927112323.GJ3657@laptop.programming.kicks-ass.net>
References: <1380147049.3467.67.camel@schen9-DESK>
	 <CAGQ1y=7Ehkr+ot3tDZtHv6FR6RQ9fXBVY0=LOyWjmGH_UjH7xA@mail.gmail.com>
	 <1380226007.2170.2.camel@buesod1.americas.hpqcorp.net>
	 <1380226997.2602.11.camel@j-VirtualBox>
	 <1380228059.2170.10.camel@buesod1.americas.hpqcorp.net>
	 <1380229794.2602.36.camel@j-VirtualBox>
	 <1380231702.3467.85.camel@schen9-DESK>
	 <1380235333.3229.39.camel@j-VirtualBox>
	 <1380236265.3467.103.camel@schen9-DESK> <20130927060213.GA6673@gmail.com>
	 <20130927112323.GJ3657@laptop.programming.kicks-ass.net>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Jason Low <jason.low2@hp.com>, Davidlohr Bueso <davidlohr@hp.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, 2013-09-27 at 13:23 +0200, Peter Zijlstra wrote:
> checkpatch.pl should really warn about that; and it appears there
> code in there for that; however:
> 
> # grep -C3 smp_mb scripts/checkpatch.pl 
[]
> # check for memory barriers without a comment.
>                 if ($line =~ /\b(mb|rmb|wmb|read_barrier_depends|smp_mb|smp_rmb|smp_wmb|smp_read_barrier_depends)\(/) {
>                         if (!ctx_has_comment($first_line, $linenr)) {
>                                 CHK("MEMORY_BARRIER",
>                                     "memory barrier without comment\n" . $herecurr);
[]
> # scripts/checkpatch.pl -f kernel/mutex.c 2>&1 | grep memory
> #
> 
> so that appears to be completely broken :/
> 
> Joe, any clue what's up with that?

It's a CHK test, so it's only tested with --strict

$ scripts/checkpatch.pl -f --strict kernel/mutex.c 2>&1 | grep memory
CHECK: memory barrier without comment
CHECK: memory barrier without comment

It could be changed to WARN so it's always on.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
