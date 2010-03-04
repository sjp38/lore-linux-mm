Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 47F8B6B0082
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 09:58:31 -0500 (EST)
Received: from e35131.upc-e.chello.nl ([213.93.35.131] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1NnCVP-0008IU-Df
	for linux-mm@kvack.org; Thu, 04 Mar 2010 14:58:27 +0000
Subject: Re: [PATCH 4/4] cpuset,mm: use rwlock to protect task->mempolicy
 and mems_allowed
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100304033017.GN8653@laptop>
References: <4B8E3F77.6070201@cn.fujitsu.com> <20100304033017.GN8653@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 04 Mar 2010 15:58:24 +0100
Message-ID: <1267714704.25158.199.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Miao Xie <miaox@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, tglx <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-03-04 at 14:30 +1100, Nick Piggin wrote:
> 
> Thanks for working on this. However, rwlocks are pretty nasty to use
> when you have short critical sections and hot read-side (they're twice
> as heavy as even spinlocks in that case). 

Should we add a checkpatch.pl warning for them? 

There really rarely is a good case for using rwlock_t, for as you say
they're a pain and often more expensive than a spinlock_t, and if
possible RCU has the best performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
