Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 671AE6B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 20:49:42 -0400 (EDT)
Date: Thu, 30 Apr 2009 17:45:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
Message-Id: <20090430174536.d0f438dd.akpm@linux-foundation.org>
In-Reply-To: <20090430072057.GA4663@eskimo.com>
References: <20090428044426.GA5035@eskimo.com>
	<20090428192907.556f3a34@bree.surriel.com>
	<1240987349.4512.18.camel@laptop>
	<20090429114708.66114c03@cuia.bos.redhat.com>
	<20090430072057.GA4663@eskimo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Elladan <elladan@eskimo.com>
Cc: riel@redhat.com, peterz@infradead.org, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 30 Apr 2009 00:20:58 -0700
Elladan <elladan@eskimo.com> wrote:

> > Elladan, does this smaller patch still work as expected?
> 
> Rik, since the third patch doesn't work on 2.6.28 (without disabling a lot of
> code), I went ahead and tested this patch.
> 
> The system does seem relatively responsive with this patch for the most part,
> with occasional lag.  I don't see much evidence at least over the course of a
> few minutes that it pages out applications significantly.  It seems about
> equivalent to the first patch.
> 
> Given Andrew Morton's request that I track the Mapped: field in /proc/meminfo,
> I went ahead and did that with this patch built into a kernel.  Compared to the
> standard Ubuntu kernel, this patch keeps significantly more Mapped memory
> around, and it shrinks at a slower rate after the test runs for a while.
> Eventually, it seems to reach a steady state.
> 
> For example, with your patch, Mapped will often go for 30 seconds without
> changing significantly.  Without your patch, it continuously lost about
> 500-1000K every 5 seconds, and then jumped up again significantly when I
> touched Firefox or other applications.  I do see some of that behavior with
> your patch too, but it's much less significant.

Were you able to tell whether altering /proc/sys/vm/swappiness appropriately
regulated the rate at which the mapped page count decreased?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
