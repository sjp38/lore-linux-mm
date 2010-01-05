Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A1C2C6007E1
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 11:05:46 -0500 (EST)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e3.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o05FtNnR016006
	for <linux-mm@kvack.org>; Tue, 5 Jan 2010 10:55:23 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o05G55Rr119572
	for <linux-mm@kvack.org>; Tue, 5 Jan 2010 11:05:05 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o05G53UL003063
	for <linux-mm@kvack.org>; Tue, 5 Jan 2010 11:05:04 -0500
Date: Tue, 5 Jan 2010 08:05:02 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 4/8] mm: RCU free vmas
Message-ID: <20100105160502.GA8037@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20100104182429.833180340@chello.nl> <20100104182813.479668508@chello.nl> <20100105024336.GQ6748@linux.vnet.ibm.com> <1262680116.2400.19.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1262680116.2400.19.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 05, 2010 at 09:28:36AM +0100, Peter Zijlstra wrote:
> On Mon, 2010-01-04 at 18:43 -0800, Paul E. McKenney wrote:
> > On Mon, Jan 04, 2010 at 07:24:33PM +0100, Peter Zijlstra wrote:
> > > TODO:
> > >  - should be SRCU, lack of call_srcu()
> > > 
> > > In order to allow speculative vma lookups, RCU free the struct
> > > vm_area_struct.
> > > 
> > > We use two means of detecting a vma is still valid:
> > >  - firstly, we set RB_CLEAR_NODE once we remove a vma from the tree.
> > >  - secondly, we check the vma sequence number.
> > > 
> > > These two things combined will guarantee that 1) the vma is still
> > > present and two, it still covers the same range from when we looked it
> > > up.
> > 
> > OK, I think I see what you are up to here.  I could get you a very crude
> > throw-away call_srcu() fairly quickly.  I don't yet have a good estimate
> > of how long it will take me to merge SRCU into the treercu infrastructure,
> > but am getting there.
> > 
> > So, which release are you thinking in terms of?
> 
> I'm not thinking any release yet, its very early and as Linus has
> pointed out, I seem to have forgotten a rather big piece of the
> picture :/
> 
> So I need to try and fix this glaring hole before we can continue.

OK, then I will think in terms of merging SRCU into treercu before
providing any sort of call_srcu().

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
