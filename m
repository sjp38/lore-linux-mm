Date: Wed, 16 Jan 2008 18:55:38 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch] Converting writeback linked lists to a tree based data structure
Message-ID: <20080116075538.GW155407@sgi.com>
References: <20080115080921.70E3810653@localhost> <1200386774.15103.20.camel@twins> <532480950801150953g5a25f041ge1ad4eeb1b9bc04b@mail.gmail.com> <400452490.28636@ustc.edu.cn> <20080115194415.64ba95f2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080115194415.64ba95f2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <wfg@mail.ustc.edu.cn>, Michael Rubin <mrubin@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 15, 2008 at 07:44:15PM -0800, Andrew Morton wrote:
> On Wed, 16 Jan 2008 11:01:08 +0800 Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:
> 
> > On Tue, Jan 15, 2008 at 09:53:42AM -0800, Michael Rubin wrote:
> > > On Jan 15, 2008 12:46 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > > > Just a quick question, how does this interact/depend-uppon etc.. with
> > > > Fengguangs patches I still have in my mailbox? (Those from Dec 28th)
> > > 
> > > They don't. They apply to a 2.6.24rc7 tree. This is a candidte for 2.6.25.
> > > 
> > > This work was done before Fengguang's patches. I am trying to test
> > > Fengguang's for comparison but am having problems with getting mm1 to
> > > boot on my systems.
> > 
> > Yeah, they are independent ones. The initial motivation is to fix the
> > bug "sluggish writeback on small+large files". Michael introduced
> > a new rbtree, and me introduced a new list(s_more_io_wait).
> > 
> > Basically I think rbtree is an overkill to do time based ordering.
> > Sorry, Michael. But s_dirty would be enough for that. Plus, s_more_io
> > provides fair queuing between small/large files, and s_more_io_wait
> > provides waiting mechanism for blocked inodes.
> > 
> > The time ordered rbtree may delay io for a blocked inode simply by
> > modifying its dirtied_when and reinsert it. But it would no longer be
> > that easy if it is to be ordered by location.
> 
> What does the term "ordered by location" mean?  Attemting to sort inodes by
> physical disk address?  By using their i_ino as a key?
> 
> That sounds optimistic.

In XFS, inode number is an encoding of it's location on disk, so
ordering inode writeback by inode number *does* make sense.

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
