Subject: Re: Active Memory Defragmentation: Our implementation & problems
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20040204183334.60551.qmail@web9701.mail.yahoo.com>
References: <20040204183334.60551.qmail@web9701.mail.yahoo.com>
Content-Type: text/plain
Message-Id: <1075920386.27981.106.camel@nighthawk>
Mime-Version: 1.0
Date: 04 Feb 2004 10:46:26 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alok Mooley <rangdi@yahoo.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2004-02-04 at 10:33, Alok Mooley wrote:
> > Instead of a daemon
> > > kicking in on a threshold  violation (as proposed
> > by Mr. Daniel
> > > Phillips), we intend to capture idle cpu cycles by
> > inserting a new
> > > process just above the idle process.  
>
> The flexibility & the various levels of aggressiveness
> are fine, but won't the daemon be running when some
> other process could well have been?

I don't think that's too much of a problem.  kswapd runs when something
else might have been, but it's there to *help*.  Your defragger is there
to make things run better, so it doesn't matter if it runs instead of
something else for a bit.  In fact, if I were you, I might just
integrate it into the current kswapd.  

> In this case, won't a process just above the idle
> process be a better proposition, since we know that
> the cpu is now truly idle? This may be at the cost of
> not having control over when this process is
> scheduled,if ever.

I don't think idleness is as big of a deal as you're making it out to
be.  You can always take a look at the load while you're about to start
and make a decision then.  

> If we do allow our preemption (before our work is well
> & truly finished), even a simple page-fault will wreak
> havoc, since it may change the memory state & we have
> to do the same work (gathering the new memory state)
> all over again. This becomes all the more significant
> considering that 2.6.0 is a preemptible kernel.
> Considering this, should we allow our preemption? If
> not, won't this hog the cpu? Is there any way out?

The "work until we get interrupted and restart if something changes
state" approach is very, very common.  Can you give some more examples
of just how a page fault would ruin the defrag process?

--dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
