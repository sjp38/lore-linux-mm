Date: Tue, 6 May 2003 20:55:55 +0530
From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: 2.5.69-mm1
Message-ID: <20030506152555.GC9875@in.ibm.com>
Reply-To: dipankar@in.ibm.com
References: <20030504231650.75881288.akpm@digeo.com> <20030505210151.GO8978@holomorphy.com> <20030506110907.GB9875@in.ibm.com> <1052222542.983.27.camel@rth.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1052222542.983.27.camel@rth.ninka.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 06, 2003 at 05:02:22AM -0700, David S. Miller wrote:
> On Tue, 2003-05-06 at 04:09, Dipankar Sarma wrote:
> > That brings me to the point - with the fget-speedup patch, we should
> > probably change ->file_lock back to an rwlock again. We now take this
> > lock only when fd table is shared and under such situation the rwlock
> > should help. Andrew, it that ok ?
> 
> rwlocks believe it or not tend not to be superior over spinlocks,
> they actually promote cache line thrashing in the case they
> are actually being effective (>1 parallel reader)

Provided there isn't a very heavy contention among readers for the spin_lock.
There is no evidence that this happens with ->file_lock as
spin_lock, so I guess we are ok for now. We should probably watch out
for some multi-threaded programs (Java->posix-threads ?) on
large smp boxes though.

Thanks
Dipankar
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
