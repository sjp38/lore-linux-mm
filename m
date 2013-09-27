Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id BFE566B0032
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 02:02:20 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so2168756pdi.27
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 23:02:20 -0700 (PDT)
Received: by mail-ee0-f54.google.com with SMTP id e53so994417eek.27
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 23:02:16 -0700 (PDT)
Date: Fri, 27 Sep 2013 08:02:13 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
Message-ID: <20130927060213.GA6673@gmail.com>
References: <cover.1380144003.git.tim.c.chen@linux.intel.com>
 <1380147049.3467.67.camel@schen9-DESK>
 <CAGQ1y=7Ehkr+ot3tDZtHv6FR6RQ9fXBVY0=LOyWjmGH_UjH7xA@mail.gmail.com>
 <1380226007.2170.2.camel@buesod1.americas.hpqcorp.net>
 <1380226997.2602.11.camel@j-VirtualBox>
 <1380228059.2170.10.camel@buesod1.americas.hpqcorp.net>
 <1380229794.2602.36.camel@j-VirtualBox>
 <1380231702.3467.85.camel@schen9-DESK>
 <1380235333.3229.39.camel@j-VirtualBox>
 <1380236265.3467.103.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1380236265.3467.103.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Jason Low <jason.low2@hp.com>, Davidlohr Bueso <davidlohr@hp.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


* Tim Chen <tim.c.chen@linux.intel.com> wrote:

> > If we prefer to optimize this a bit though, perhaps we can first move 
> > the node->lock = 0 so that it gets executed after the "if (likely(prev 
> > == NULL)) {}" code block and then delete "node->lock = 1" inside the 
> > code block.
> 
> I suppose we can save one single assignment. The gain is probably not 
> noticeable as once we set node->next to NULL, node->locked is likely in 
> local cache line and the assignment operation is cheap.

Would be nice to have this as a separate, add-on patch. Every single 
instruction removal that has no downside is an upside!

You can add a comment that explains it.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
