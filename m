Subject: Re: [patch 02/20] make the inode i_mmap_lock a reader/writer lock
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1198083218.5333.48.camel@localhost>
References: <20071218211539.250334036@redhat.com>
	 <20071218211548.784184591@redhat.com>
	 <200712191148.06506.nickpiggin@yahoo.com.au>
	 <1198079529.5333.12.camel@localhost>
	 <20071219113107.5301f9f0@cuia.boston.redhat.com>
	 <1198083218.5333.48.camel@localhost>
Content-Type: text/plain
Date: Wed, 19 Dec 2007 20:28:23 +0100
Message-Id: <1198092503.6484.21.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-12-19 at 11:53 -0500, Lee Schermerhorn wrote:
> On Wed, 2007-12-19 at 11:31 -0500, Rik van Riel wrote:
> > On Wed, 19 Dec 2007 10:52:09 -0500
> > Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> > 
> > > I keep these patches up to date for testing.  I don't have conclusive
> > > evidence whether they alleviate or exacerbate the problem nor by how
> > > much.  
> > 
> > When the queued locking from Ingo's x86 tree hits mainline,
> > I suspect that spinlocks may end up behaving a lot nicer.
> 
> That would be worth testing with our problematic workloads...
> 
> > 
> > Should I drop the rwlock patches from my tree for now and
> > focus on just the page reclaim stuff?
> 
> That's fine with me.  They're out there is anyone is interested.  I'll
> keep them up to date in my tree [and hope they don't conflict with split
> lru and noreclaim patches too much] for occasional testing.

Of course, someone would need to implement ticket locks for ia64 -
preferably without the 256 cpu limit.

Nick, growing spinlock_t to 64 bits would yield space for 64k cpus,
right? I'm guessing that would be enough for a while, even for SGI.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
