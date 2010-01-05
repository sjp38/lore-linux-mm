Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BCC556007BA
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 03:29:18 -0500 (EST)
Subject: Re: [RFC][PATCH 4/8] mm: RCU free vmas
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100105024336.GQ6748@linux.vnet.ibm.com>
References: <20100104182429.833180340@chello.nl>
	 <20100104182813.479668508@chello.nl>
	 <20100105024336.GQ6748@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 05 Jan 2010 09:28:36 +0100
Message-ID: <1262680116.2400.19.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: paulmck@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-01-04 at 18:43 -0800, Paul E. McKenney wrote:
> On Mon, Jan 04, 2010 at 07:24:33PM +0100, Peter Zijlstra wrote:
> > TODO:
> >  - should be SRCU, lack of call_srcu()
> > 
> > In order to allow speculative vma lookups, RCU free the struct
> > vm_area_struct.
> > 
> > We use two means of detecting a vma is still valid:
> >  - firstly, we set RB_CLEAR_NODE once we remove a vma from the tree.
> >  - secondly, we check the vma sequence number.
> > 
> > These two things combined will guarantee that 1) the vma is still
> > present and two, it still covers the same range from when we looked it
> > up.
> 
> OK, I think I see what you are up to here.  I could get you a very crude
> throw-away call_srcu() fairly quickly.  I don't yet have a good estimate
> of how long it will take me to merge SRCU into the treercu infrastructure,
> but am getting there.
> 
> So, which release are you thinking in terms of?

I'm not thinking any release yet, its very early and as Linus has
pointed out, I seem to have forgotten a rather big piece of the
picture :/

So I need to try and fix this glaring hole before we can continue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
