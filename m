Message-ID: <484EF6B2.8010508@firstfloor.org>
Date: Tue, 10 Jun 2008 23:48:34 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
References: <20080606202838.390050172@redhat.com>	<20080606202859.291472052@redhat.com>	<20080606180506.081f686a.akpm@linux-foundation.org>	<20080608163413.08d46427@bree.surriel.com>	<20080608135704.a4b0dbe1.akpm@linux-foundation.org>	<20080608173244.0ac4ad9b@bree.surriel.com>	<20080608162208.a2683a6c.akpm@linux-foundation.org>	<20080608193420.2a9cc030@bree.surriel.com>	<20080608165434.67c87e5c.akpm@linux-foundation.org>	<Pine.LNX.4.64.0806101214190.17798@schroedinger.engr.sgi.com>	<20080610153702.4019e042@cuia.bos.redhat.com> <20080610143334.c53d7d8a.akpm@linux-foundation.org>
In-Reply-To: <20080610143334.c53d7d8a.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, clameter@sgi.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com, Paul Mundt <lethal@linux-sh.org>, Ingo Molnar <mingo@elte.hu>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

> 
> Maybe it's time to bite the bullet and kill i386 NUMA support.  afaik
> it's just NUMAQ and a 2-node NUMAish machine which IBM made (as400?)

Actually much more (most 64bit NUMA systems can run 32bit too), it just
doesn't work well because the code is not very good, undertested, many
bugs, weird design and in general 32bit NUMA has a lot of limitations
that don't make it a good idea.

But you don't need to kill it only for this (although imho there are
lots of other good reasons) Just use a different way to look up the
node. Encoding it into the flags is just an optimization.
But a separate hash or similar would also work. It seemed like a good
idea back then.

In fact there's already a hash for this (the pa->node hash) that
can do it. It' just some more instructions and one cache line
more accessed, but since i386 NUMA is a fringe application
that doesn't seem like a big issue.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
