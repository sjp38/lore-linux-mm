Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 38A8D6B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 11:24:13 -0500 (EST)
Date: Thu, 08 Jan 2009 08:24:13 -0800 (PST)
Message-Id: <20090108.082413.156881254.davem@davemloft.net>
Subject: Re: Increase dirty_ratio and dirty_background_ratio?
From: David Miller <davem@davemloft.net>
In-Reply-To: <20090108030245.e7c8ceaf.akpm@linux-foundation.org>
References: <alpine.LFD.2.00.0901070833430.3057@localhost.localdomain>
	<20090107.125133.214628094.davem@davemloft.net>
	<20090108030245.e7c8ceaf.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, peterz@infradead.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 8 Jan 2009 03:02:45 -0800

> The kernel can't get this right - it doesn't know the usage
> patterns/workloads, etc.

I don't agree with that.

The kernel is watching and gets to see every operation that happens
both to memory and to the disk, so of course it can see what
the "patterns" and the "workload" are.

It also can see how fast or slow the disk technology is.  And I think
that is one of the largest determinants to what these values should
be set to.

So, in fact, the kernel is the place that has all of the information
necessary to try and adjust these settings dynamically.

Userland can only approximate a good setting, at best, because it has
so many fewer pieces of information to work with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
