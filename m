Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 094CB6B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 13:45:27 -0500 (EST)
Date: Fri, 18 Dec 2009 19:45:04 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
Message-ID: <20091218184504.GA675@elte.hu>
References: <20091217175338.GL9804@basil.fritz.box>
 <20091217190804.GB6788@linux.vnet.ibm.com>
 <20091217195530.GM9804@basil.fritz.box>
 <alpine.DEB.2.00.0912171356020.4640@router.home>
 <1261080855.27920.807.camel@laptop>
 <alpine.DEB.2.00.0912171439380.4640@router.home>
 <20091218051754.GC417@elte.hu>
 <4B2BB52A.7050103@redhat.com>
 <20091218171240.GB1354@elte.hu>
 <alpine.DEB.2.00.0912181207010.26947@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0912181207010.26947@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Avi Kivity <avi@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>


* Christoph Lameter <cl@linux-foundation.org> wrote:

> > We've been through this many times in the past within the kernel: many 
> > times when we hid some locking primitive within some clever wrapping 
> > scheme the quality of locking started to deteriorate. In most of the 
> > important cases we got rid of the indirection and went with an existing 
> > core kernel locking primitive which are all well known and have clear 
> > semantics and lead to more maintainable code.
> 
> The existing locking APIs are all hiding lock details at various levels. We 
> have various specific APIs for specialized locks already Page locking etc.

You need to loo at the patches. This is simply a step backwards:

-               up_read(&mm->mmap_sem);
+               mm_read_unlock(mm);

because it hides the lock instance.

( You brought up -rt but that example does not apply: it doesnt 'hide' the 
  lock instance in any way, it simply changes the preemption model. It goes to 
  great lengths to keep existing locking patterns and does not obfuscate 
  locking. )

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
