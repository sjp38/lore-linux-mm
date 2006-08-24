Subject: Re: [PATCH] radix-tree:  cleanup radix_tree_deref_slot() and
	_lookup_slot() comments
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20060824052410.GD18961@us.ibm.com>
References: <1156278772.5622.23.camel@localhost>
	 <20060824052410.GD18961@us.ibm.com>
Content-Type: text/plain
Date: Thu, 24 Aug 2006 11:04:41 -0400
Message-Id: <1156431882.5165.31.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: paulmck@us.ibm.com
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-08-23 at 22:24 -0700, Paul E. McKenney wrote:
> On Tue, Aug 22, 2006 at 04:32:52PM -0400, Lee Schermerhorn wrote:
> > Andrew:  here is a second patch that just cleans up [I think] the
> > '_deref_slot() function, and adds more explanation of expected/required
> > locking to the direct slot access functions.  I separated it out,
> > because it doesn't fix a serious bug, like the previous one.
> > 
> > Paul:  do you agree that we don't need rcu_dereference() in the
> > _deref_slot() as it can only be used while the tree is held [probably
> > write] locked?  Do the comments look OK?
> 
> Yep, rcu_dereference() is not needed if the tree is prevented from
> changing.  That said, rcu_dereference() is zero cost on all but
> Alpha, so there is little benefit to be had from removing it.

I wasn't concerned about the cost.  I just thought it would be
"misleading" if, as you have verified, that it's not required, because
the comment on rcu_dereference() says that one important aspect of using
rcu_dereference() is to document which pointers are protected by RCU.  

> 
> The comments look much improved.

Thanks,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
