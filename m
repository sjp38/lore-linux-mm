Message-ID: <4191654A.7000407@yahoo.com.au>
Date: Wed, 10 Nov 2004 11:48:10 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
References: <Pine.LNX.4.44.0411081649450.1433-100000@localhost.localdomain> <Pine.LNX.4.58.0411080858400.8212@schroedinger.engr.sgi.com> <41902E14.4080904@yahoo.com.au> <20041109121037.GQ24690@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041109121037.GQ24690@parcelfarce.linux.theplanet.co.uk>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Matthew Wilcox wrote:
> On Tue, Nov 09, 2004 at 01:40:20PM +1100, Nick Piggin wrote:
> 
>>I wonder if a per process flag or something could be used to turn off
>>the statistics counters? I guess statistics could still be gathered for
>>that process by using your lazy counting functions, Christoph.
> 
> 
> I don't get it.  It seems to me that any process that's going to
> experience problems with these statistics counters is going to be
> precisely the one that you want the statistics for!  What was the problem
> with per-cpu counters again?
> 

Not sure if they'd be the ones you want statistics for. If so, then
you're stuck between a rock and a hard place really. However if there
is room for compromise, then this may be a solution.

I think the problem with per-cpu counters is that it wouldn't be a
very good solution for mainline either. It would also penalise all
single threaded tasks for zero gain... quite significantly if you
did a static cacheline aligned array in the mm_struct even with
small CPU counts. Maybe less so resource wise if you used
alloc_percpu, but that would increase complexity. I don't know, maybe
it is an option.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
