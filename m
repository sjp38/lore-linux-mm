Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 5B5716B005A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 18:00:38 -0400 (EDT)
Date: Fri, 5 Oct 2012 15:00:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/8] THP support for Sparc64
Message-Id: <20121005150036.edd3be21.akpm@linux-foundation.org>
In-Reply-To: <20121005.174508.1624534294642226949.davem@davemloft.net>
References: <20121004.154624.923241475790311926.davem@davemloft.net>
	<20121005143644.abb14c2b.akpm@linux-foundation.org>
	<20121005.174508.1624534294642226949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, aarcange@redhat.com, hannes@cmpxchg.org, mingo@elte.hu, a.p.zijlstra@chello.nl, torvalds@linux-foundation.org

On Fri, 05 Oct 2012 17:45:08 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Fri, 5 Oct 2012 14:36:44 -0700
> 
> > David, I don't know what to do until there's some clarity on the
> > numa/sched changes.  Andrea has a new autonuma patchset, Peter's code
> > is in -next and I don't know if it's planned for 3.7 merging.  And I
> > suspect (hope) that it won't be merged if that is indeed planned.
> 
> It doesn't matter from a sparc64 perspective.
> 
> If you remove the autonuma patch, I'll still compile and work.
> I just provide an unused interface. 

ah, OK.

> Please do something instead of stalling these changes further.

OK, I'll add it all to the pile and will restage it against mainline on
Monday.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
