Subject: Re: [PATCH] strict VM overcommit for stock 2.4
From: Daniel Gryniewicz <dang@fprintf.net>
In-Reply-To: <Pine.LNX.3.95.1020718152142.1373B-100000@chaos.analogic.com>
References: <Pine.LNX.3.95.1020718152142.1373B-100000@chaos.analogic.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 18 Jul 2002 15:41:40 -0400
Message-Id: <1027021302.3439.8.camel@athena.fprintf.net>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: root@chaos.analogic.com
Cc: Robert Love <rml@tech9.net>, Szakacsits Szabolcs <szaka@sienet.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2002-07-18 at 15:35, Richard B. Johnson wrote:
> On 18 Jul 2002, Robert Love wrote:
> 
> > I should also mention this is demand paging, not overcommit.
> > 
> > Overcommit is the property of succeeded more allocations than their is
> > memory in the address space.  The idea being that allocations are lazy,
> > things often do not use their full allocations, etc. etc. as you
> > mentioned.
> > 
> > It is typical a good thing since it lowers VM pressure.
> > 
> > It is not always a good thing, for numerous reasons, and it becomes
> > important in those scenarios to ensure that all allocations can be met
> > by the backing store and consequently we never find ourselves with more
> > memory committed than available and thus never OOM.
> > 
> > This has nothing to do with paging and resource limits as you say.  Btw,
> > without this it is possible to OOM any machine.  OOM is a by-product of
> > allowing overcommit and poor accounting (and perhaps poor
> > software/users), not an incorrectly configured machine.
> 
> It has everything to do with demand-paging. Since on single CPU
> machines, there is only one task executing at any one time, that
> single task can own and use every bit of RAM on the whole machine
> is virtual memory works correctly. For performance reasons, it
> may not actually use all the RAM but, in principle, it is possible.
> 
> If you don't allow that, the single task can use only the RAM that
> was not allocated to other tasks. At the time an allocation is made,
> the kernel cannot know what resources may be available when the task
> requesting the allocation actually starts to use those allocated
> resources. Instead, the kernel allocates resources based upon what
> it 'knows' at the present time. Since it can't see the future anymore
> than you or I, the fact that N processes just called exit() before
> the requesting task touched a single page can't be known.
> 
> FYI multiple CPU machines have compounded the problems because there
> can be several things happening at the same time. Although the MM
> is locked so it's single-threaded, you have a before/after resource 
> history condition that can't be anticipated.
> 
> Cheers,
> Dick Johnson
> 

Is it possible that you're confusing "backing store" with "physical
RAM"?  I was under the impression that strict overcommit used both RAM
and SWAP when deciding whether an allocation should succeed.  If you've
exceeded all of RAM and all of swap, you are OOM.  Period.

Daniel

-- 
Recursion n.:
        See Recursion.
                        -- Random Shack Data Processing Dictionary


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
