Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF456B0036
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 03:36:54 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id xa12so872968pbc.24
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 00:36:54 -0700 (PDT)
Received: from psmtp.com ([74.125.245.205])
        by mx.google.com with SMTP id n5si4254763pav.98.2013.11.01.00.36.52
        for <linux-mm@kvack.org>;
        Fri, 01 Nov 2013 00:36:53 -0700 (PDT)
Received: by mail-ee0-f43.google.com with SMTP id b47so1828474eek.16
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 00:36:50 -0700 (PDT)
Date: Fri, 1 Nov 2013 08:36:48 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC GIT PULL] NUMA-balancing memory corruption fixes
Message-ID: <20131101073648.GD21471@gmail.com>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
 <20131024122646.GB2402@suse.de>
 <20131031095143.GA9692@gmail.com>
 <CA+55aFyDve4RtZ6n11ghFcq1kmzs52OB+xetZjyP1q3RparUkw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyDve4RtZ6n11ghFcq1kmzs52OB+xetZjyP1q3RparUkw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tom Weber <l_linux-kernel@mail2news.4t2.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Thu, Oct 31, 2013 at 2:51 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> >
> > ( If you think this is too dangerous for too little benefit then
> >   I'll drop this separate tree and will send the original commits in
> >   the merge window. )
> 
> Ugh. I hate hate hate the timing, and this is much larger and 
> scarier than what I'd like at this point, but I don't see the 
> point to delaying this either.

Yeah, it's pretty close to worst-case timing. I tried to accelerate 
the fixes as much as I dared, I wasn't even back from the KS yet but 
at another conference, doing all preparation and testing remotely
:-/ Still the timing sucks.

> So I'm pulling them. And then I may end up doing an rc8 after all.

Thanks for pulling them!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
