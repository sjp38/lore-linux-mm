Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7Q5PKQj029125
	for <linux-mm@kvack.org>; Sat, 26 Aug 2006 01:25:20 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7Q5PJla293974
	for <linux-mm@kvack.org>; Sat, 26 Aug 2006 01:25:19 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7Q5PJGc019772
	for <linux-mm@kvack.org>; Sat, 26 Aug 2006 01:25:19 -0400
Date: Fri, 25 Aug 2006 22:25:46 -0700
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: [PATCH] radix-tree:  cleanup radix_tree_deref_slot() and _lookup_slot() comments
Message-ID: <20060826052546.GB25058@us.ibm.com>
Reply-To: paulmck@us.ibm.com
References: <1156278772.5622.23.camel@localhost> <20060824052410.GD18961@us.ibm.com> <1156431882.5165.31.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1156431882.5165.31.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 24, 2006 at 11:04:41AM -0400, Lee Schermerhorn wrote:
> On Wed, 2006-08-23 at 22:24 -0700, Paul E. McKenney wrote:
> > On Tue, Aug 22, 2006 at 04:32:52PM -0400, Lee Schermerhorn wrote:
> > > Andrew:  here is a second patch that just cleans up [I think] the
> > > '_deref_slot() function, and adds more explanation of expected/required
> > > locking to the direct slot access functions.  I separated it out,
> > > because it doesn't fix a serious bug, like the previous one.
> > > 
> > > Paul:  do you agree that we don't need rcu_dereference() in the
> > > _deref_slot() as it can only be used while the tree is held [probably
> > > write] locked?  Do the comments look OK?
> > 
> > Yep, rcu_dereference() is not needed if the tree is prevented from
> > changing.  That said, rcu_dereference() is zero cost on all but
> > Alpha, so there is little benefit to be had from removing it.
> 
> I wasn't concerned about the cost.  I just thought it would be
> "misleading" if, as you have verified, that it's not required, because
> the comment on rcu_dereference() says that one important aspect of using
> rcu_dereference() is to document which pointers are protected by RCU.  

Fair enough!  My hope is that this will eventually be settled by
the needs of RCU-based static-analysis tooling, but we are not there
yet.

						Thanx, Paul

> > The comments look much improved.
> 
> Thanks,
> Lee
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
