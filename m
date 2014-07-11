Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 791E46B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 12:00:04 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so1717082pad.9
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 09:00:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.9])
        by mx.google.com with ESMTPS id d10si1442201pdp.284.2014.07.11.09.00.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jul 2014 09:00:03 -0700 (PDT)
Date: Fri, 11 Jul 2014 17:59:58 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: + shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
 added to -mm tree
Message-ID: <20140711155958.GR20603@laptop.programming.kicks-ass.net>
References: <alpine.LSU.2.11.1407092358090.18131@eggly.anvils>
 <53BE8B1B.3000808@oracle.com>
 <53BECBA4.3010508@oracle.com>
 <alpine.LSU.2.11.1407101033280.18934@eggly.anvils>
 <53BED7F6.4090502@oracle.com>
 <alpine.LSU.2.11.1407101131310.19154@eggly.anvils>
 <53BEE345.4090203@oracle.com>
 <20140711082500.GB20603@laptop.programming.kicks-ass.net>
 <53BFD708.1040305@oracle.com>
 <alpine.LSU.2.11.1407110745430.2054@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1407110745430.2054@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, davej@redhat.com, koct9i@gmail.com, lczerner@redhat.com, stable@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 11, 2014 at 07:55:50AM -0700, Hugh Dickins wrote:
> On Fri, 11 Jul 2014, Sasha Levin wrote:
> > 
> > There's no easy way to see whether a given task is actually holding a lock or
> > is just blocking on it without going through all those tasks one by one and
> > looking at their trace.
> > 
> > I agree with you that "The call trace is very clear on it that its not", but
> > when you have 500 call traces you really want something better than going
> > through it one call trace at a time.
> 
> Points well made, and I strongly agree with Vlastimil and Sasha.
> There is a world of difference between a lock wanted and a lock held,
> and for the display of locks "held" to conceal that difference is unhelpful.
> It just needs one greppable word to distinguish the cases.

So for the actual locking scenario it doesn't make a difference one way
or another. These threads all can/could/will acquire the lock
(eventually), so all their locking chains should be considered.

I realize that 500+ single lock 'chains' can be tedious, otoh they're
easy to dismiss, since singe lock 'chains' are trivial and usually not
interesting in their own right.

> (Though I didn't find "The call trace is very clear on it that its not",
> I thought it too was telling me that the lock was already held somehow.)

The trace is in the middle of the mutex op, if it were really fully
acquired it would not be, it would be doing something else -- while
holding the mutex.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
